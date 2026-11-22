//! Single background thread that owns the Discord connection.
//!
//! Dart only ever pushes the *desired* presence into a channel (a few
//! microseconds, never blocks). This thread:
//! - coalesces bursts (latest wins) and skips no-op updates,
//! - honours Discord's SET_ACTIVITY limit (5 per 20 s),
//! - connects lazily, reconnects with backoff and restores the presence
//!   after Discord restarts,
//! - retries once without artwork when Discord rejects an image,
//! - sleeps on the channel with no timers at all while there is nothing to
//!   do, and wakes every 15 s only while connected (liveness probe).

use super::ipc::{Connection, Frame, OP_CLOSE, OP_FRAME, OP_HANDSHAKE, OP_PING, OP_PONG};
use crate::api::discord::{
    DiscordActivity, DiscordButton, DiscordConnectionState, DiscordStatus, DiscordUser,
};
use crate::frb_generated::StreamSink;
use serde_json::{json, Map, Value};
use std::collections::VecDeque;
use std::sync::mpsc::{Receiver, RecvTimeoutError};
use std::sync::{Arc, Mutex};
use std::time::{Duration, Instant, SystemTime, UNIX_EPOCH};

const RATE_WINDOW: Duration = Duration::from_secs(20);
const RATE_MAX: usize = 5;
const HEARTBEAT: Duration = Duration::from_secs(15);
const ACK_CHECK: Duration = Duration::from_millis(1500);
const HANDSHAKE_TIMEOUT: Duration = Duration::from_secs(3);
/// Close an idle connection (nothing shown) after this long.
const IDLE_DISCONNECT: Duration = Duration::from_secs(90);
/// Timestamps within this tolerance are "the same" (playback jitter).
const TIMESTAMP_SLACK_MS: i64 = 2000;

pub enum Command {
    Activity(Option<Box<DiscordActivity>>),
    Reconnect,
    Shutdown,
}

// ── Status fan-out to Dart ───────────────────────────────────────────────────

pub struct StatusHub {
    sink: Option<StreamSink<DiscordStatus>>,
    last: DiscordStatus,
}

impl StatusHub {
    pub fn new() -> Self {
        Self {
            sink: None,
            last: DiscordStatus::idle(),
        }
    }

    pub fn attach(&mut self, sink: StreamSink<DiscordStatus>) {
        let _ = sink.add(self.last.clone());
        self.sink = Some(sink);
    }

    pub fn publish(&mut self, status: DiscordStatus) {
        if status == self.last {
            return;
        }
        self.last = status.clone();
        if let Some(sink) = &self.sink {
            if sink.add(status).is_err() {
                self.sink = None;
            }
        }
    }
}

pub type Hub = Arc<Mutex<StatusHub>>;

fn publish(hub: &Hub, status: DiscordStatus) {
    if let Ok(mut hub) = hub.lock() {
        hub.publish(status);
    }
}

// ── Presence snapshot ────────────────────────────────────────────────────────

#[derive(Clone, PartialEq)]
struct Presence {
    /// Activity with `progress` stripped; compared exactly.
    base: DiscordActivity,
    start_ms: Option<i64>,
    end_ms: Option<i64>,
}

impl Presence {
    fn new(mut activity: DiscordActivity) -> Self {
        let (start_ms, end_ms) = match activity.progress.take() {
            Some(p) => {
                let start = now_ms() - p.position_ms as i64;
                let end = p
                    .duration_ms
                    .filter(|d| *d > p.position_ms)
                    .map(|d| start + d as i64);
                (Some(start), end)
            }
            None => (None, None),
        };
        Self {
            base: activity,
            start_ms,
            end_ms,
        }
    }

    fn same_as(&self, other: &Self) -> bool {
        fn close(a: Option<i64>, b: Option<i64>) -> bool {
            match (a, b) {
                (None, None) => true,
                (Some(a), Some(b)) => (a - b).abs() <= TIMESTAMP_SLACK_MS,
                _ => false,
            }
        }
        self.base == other.base
            && close(self.start_ms, other.start_ms)
            && close(self.end_ms, other.end_ms)
    }

    fn has_images(&self) -> bool {
        self.base.large_image.is_some() || self.base.small_image.is_some()
    }

    /// Builds the SET_ACTIVITY `activity` object, enforcing Discord's field
    /// limits so a single long string can never get the whole update
    /// rejected.
    fn to_json(&self, strip_images: bool) -> Value {
        let a = &self.base;
        let mut out = Map::new();
        out.insert("type".into(), json!(a.kind.wire()));
        out.insert("status_display_type".into(), json!(a.status_display.wire()));
        out.insert("details".into(), json!(text(&a.details)));
        put_opt(&mut out, "details_url", a.details_url.as_deref().and_then(link));
        put_opt(&mut out, "state", a.state.as_deref().map(text));
        put_opt(&mut out, "state_url", a.state_url.as_deref().and_then(link));

        let mut ts = Map::new();
        put_opt(&mut ts, "start", self.start_ms.map(Value::from));
        put_opt(&mut ts, "end", self.end_ms.map(Value::from));
        if !ts.is_empty() {
            out.insert("timestamps".into(), Value::Object(ts));
        }

        let mut assets = Map::new();
        if !strip_images {
            put_opt(&mut assets, "large_image", a.large_image.as_deref().and_then(image));
            put_opt(&mut assets, "small_image", a.small_image.as_deref().and_then(image));
        }
        put_opt(&mut assets, "large_text", a.large_text.as_deref().map(text));
        put_opt(&mut assets, "large_url", a.large_url.as_deref().and_then(link));
        put_opt(&mut assets, "small_text", a.small_text.as_deref().map(text));
        if assets.contains_key("large_image") || assets.contains_key("small_image") {
            out.insert("assets".into(), Value::Object(assets));
        }

        let buttons: Vec<Value> = a.buttons.iter().filter_map(button).take(2).collect();
        if !buttons.is_empty() {
            out.insert("buttons".into(), Value::Array(buttons));
        }
        out.insert("instance".into(), json!(false));
        Value::Object(out)
    }
}

fn put_opt(map: &mut Map<String, Value>, key: &str, value: Option<impl Into<Value>>) {
    if let Some(v) = value {
        map.insert(key.into(), v.into());
    }
}

/// Discord text fields: 2..=128 UTF-16 units.
fn text(s: &str) -> String {
    clamp_utf16(s.trim(), 128, 2)
}

fn clamp_utf16(s: &str, max: usize, min: usize) -> String {
    let mut out = if s.encode_utf16().count() <= max {
        s.to_owned()
    } else {
        // Leave one unit for the ellipsis.
        let mut cut = String::with_capacity(max * 2);
        let mut units = 0;
        for ch in s.chars() {
            units += ch.len_utf16();
            if units > max - 1 {
                break;
            }
            cut.push(ch);
        }
        cut.push('…');
        cut
    };
    while out.encode_utf16().count() < min {
        out.push('\u{200B}');
    }
    out
}

fn link(url: &str) -> Option<String> {
    let url = url.trim();
    ((url.starts_with("https://") || url.starts_with("http://")) && url.len() <= 256)
        .then(|| url.to_owned())
}

/// Asset key (uploaded art name) or an external https image.
fn image(key: &str) -> Option<String> {
    let key = key.trim();
    if key.is_empty() || key.len() > 256 {
        return None;
    }
    if key.contains("://") && !key.starts_with("https://") {
        return None;
    }
    Some(key.to_owned())
}

fn button(b: &DiscordButton) -> Option<Value> {
    let label = b.label.trim();
    let url = b.url.trim();
    if label.is_empty()
        || url.len() > 512
        || !(url.starts_with("https://") || url.starts_with("http://"))
    {
        return None;
    }
    Some(json!({ "label": clamp_utf16(label, 32, 1), "url": url }))
}

fn now_ms() -> i64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|d| d.as_millis() as i64)
        .unwrap_or(0)
}

// ── Worker ───────────────────────────────────────────────────────────────────

pub struct Worker {
    client_id: String,
    rx: Receiver<Command>,
    hub: Hub,
    conn: Option<Connection>,
    user: Option<DiscordUser>,
    notice: Option<String>,
    desired: Option<Presence>,
    shown: Option<Presence>,
    strip_images: bool,
    failures: u32,
    retry_at: Option<Instant>,
    blocked_until: Option<Instant>,
    sends: VecDeque<Instant>,
    next_poll: Option<Instant>,
    idle_since: Option<Instant>,
    nonce: u64,
    pending: Option<(String, bool)>,
}

impl Worker {
    pub fn new(client_id: String, rx: Receiver<Command>, hub: Hub) -> Self {
        Self {
            client_id,
            rx,
            hub,
            conn: None,
            user: None,
            notice: None,
            desired: None,
            shown: None,
            strip_images: false,
            failures: 0,
            retry_at: None,
            blocked_until: None,
            sends: VecDeque::with_capacity(RATE_MAX + 1),
            next_poll: None,
            idle_since: None,
            nonce: 0,
            pending: None,
        }
    }

    pub fn run(mut self) {
        self.report();
        'outer: loop {
            let received = match self.next_wake() {
                Some(at) => self
                    .rx
                    .recv_timeout(at.saturating_duration_since(Instant::now())),
                None => self.rx.recv().map_err(|_| RecvTimeoutError::Disconnected),
            };
            match received {
                Ok(cmd) => {
                    if !self.handle(cmd) {
                        break;
                    }
                    // Coalesce a burst: only the latest presence matters.
                    while let Ok(cmd) = self.rx.try_recv() {
                        if !self.handle(cmd) {
                            break 'outer;
                        }
                    }
                }
                Err(RecvTimeoutError::Timeout) => {}
                Err(RecvTimeoutError::Disconnected) => break,
            }
            self.tick();
        }
        self.shutdown();
    }

    fn handle(&mut self, cmd: Command) -> bool {
        match cmd {
            Command::Activity(activity) => {
                let next = activity.map(|a| Presence::new(*a));
                let changed = match (&next, &self.desired) {
                    (Some(a), Some(b)) => !a.same_as(b),
                    (None, None) => false,
                    _ => true,
                };
                if changed {
                    if next.as_ref().map(|p| &p.base) != self.desired.as_ref().map(|p| &p.base) {
                        self.strip_images = false;
                    }
                    self.desired = next;
                }
            }
            Command::Reconnect => {
                self.drop_connection();
                self.failures = 0;
                self.retry_at = None;
                self.notice = None;
                // Fresh connection; tick() re-sends the wanted presence.
                self.connect_now();
            }
            Command::Shutdown => return false,
        }
        true
    }

    fn in_sync(&self) -> bool {
        match (&self.desired, &self.shown) {
            (None, None) => true,
            (Some(a), Some(b)) => a.same_as(b),
            _ => false,
        }
    }

    fn next_wake(&self) -> Option<Instant> {
        let mut wake: Option<Instant> = None;
        let mut consider = |t: Option<Instant>| {
            if let Some(t) = t {
                wake = Some(wake.map_or(t, |w| w.min(t)));
            }
        };
        if self.conn.is_some() {
            consider(self.next_poll);
            if self.desired.is_none() {
                consider(self.idle_since.map(|t| t + IDLE_DISCONNECT));
            }
        }
        if !self.in_sync() {
            if self.conn.is_some() {
                consider(Some(self.blocked_until.unwrap_or_else(Instant::now)));
            } else if self.desired.is_some() {
                consider(Some(self.retry_at.unwrap_or_else(Instant::now)));
            }
        }
        wake
    }

    fn tick(&mut self) {
        let now = Instant::now();
        if self.conn.is_some() && self.next_poll.is_none_or(|t| now >= t) {
            self.poll();
        }

        if self.in_sync() {
            self.maybe_idle_disconnect(now);
            return;
        }

        if self.conn.is_none() {
            if self.desired.is_none() {
                self.shown = None;
                return;
            }
            if self.retry_at.is_some_and(|t| now < t) || !self.connect_now() {
                return;
            }
        }

        if let Some(until) = self.rate_limited(now) {
            self.blocked_until = Some(until);
            return;
        }
        self.blocked_until = None;
        self.send_desired();
    }

    fn maybe_idle_disconnect(&mut self, now: Instant) {
        if self.desired.is_some() || self.conn.is_none() {
            self.idle_since = None;
            return;
        }
        let since = *self.idle_since.get_or_insert(now);
        if now.duration_since(since) >= IDLE_DISCONNECT {
            self.drop_connection();
            self.report();
        }
    }

    fn rate_limited(&mut self, now: Instant) -> Option<Instant> {
        while self.sends.front().is_some_and(|t| now.duration_since(*t) >= RATE_WINDOW) {
            self.sends.pop_front();
        }
        (self.sends.len() >= RATE_MAX).then(|| self.sends[0] + RATE_WINDOW)
    }

    fn connect_now(&mut self) -> bool {
        if self.conn.is_some() {
            return true;
        }
        if self.failures == 0 {
            publish(
                &self.hub,
                DiscordStatus::new(DiscordConnectionState::Connecting, None, None, None),
            );
        }
        let Some(mut conn) = Connection::open() else {
            return self.fail(None);
        };
        let hello = json!({ "v": 1, "client_id": self.client_id });
        if conn.send(OP_HANDSHAKE, &hello).is_err() {
            return self.fail(None);
        }
        let reply = conn.wait_for(HANDSHAKE_TIMEOUT, |f| {
            f.op == OP_CLOSE || (f.op == OP_FRAME && f.body["evt"] == "READY")
        });
        match reply {
            Ok(Some(frame)) if frame.op == OP_FRAME => {
                self.user = parse_user(&frame.body["data"]["user"]);
                self.conn = Some(conn);
                self.failures = 0;
                self.retry_at = None;
                self.shown = None;
                self.idle_since = None;
                self.next_poll = Some(Instant::now() + HEARTBEAT);
                self.report();
                true
            }
            Ok(Some(frame)) => {
                // Discord refused the handshake (e.g. unknown client id).
                let msg = frame.body["message"]
                    .as_str()
                    .unwrap_or("Discord refused the connection")
                    .to_owned();
                self.failures = self.failures.max(6);
                self.fail(Some(msg))
            }
            _ => self.fail(None),
        }
    }

    fn fail(&mut self, error: Option<String>) -> bool {
        self.failures = self.failures.saturating_add(1);
        let backoff = match self.failures {
            1 => 2,
            2 => 5,
            3 => 10,
            4 => 20,
            5 => 40,
            _ => 60,
        };
        self.retry_at = Some(Instant::now() + Duration::from_secs(backoff));
        let state = if error.is_some() {
            DiscordConnectionState::Error
        } else {
            DiscordConnectionState::NotFound
        };
        publish(
            &self.hub,
            DiscordStatus::new(state, None, error, Some(backoff as u32)),
        );
        false
    }

    fn send_desired(&mut self) {
        let Some(conn) = self.conn.as_mut() else { return };
        self.nonce += 1;
        let nonce = self.nonce.to_string();
        let mut args = Map::new();
        args.insert("pid".into(), json!(std::process::id()));
        let has_images = match &self.desired {
            Some(p) => {
                args.insert("activity".into(), p.to_json(self.strip_images));
                p.has_images() && !self.strip_images
            }
            None => false,
        };
        let frame = json!({ "cmd": "SET_ACTIVITY", "args": args, "nonce": nonce });
        if conn.send(OP_FRAME, &frame).is_err() {
            self.lost();
            return;
        }
        self.sends.push_back(Instant::now());
        self.shown = self.desired.clone();
        self.pending = Some((nonce, has_images));
        // Pick up Discord's ack/error quickly, then fall back to heartbeat.
        self.next_poll = Some(Instant::now() + ACK_CHECK);
    }

    fn poll(&mut self) {
        let Some(conn) = self.conn.as_mut() else { return };
        let frames = match conn.poll() {
            Ok(frames) => frames,
            Err(_) => {
                self.lost();
                return;
            }
        };
        self.next_poll = Some(Instant::now() + HEARTBEAT);
        for frame in frames {
            self.on_frame(frame);
        }
    }

    fn on_frame(&mut self, frame: Frame) {
        match frame.op {
            OP_PING => {
                if let Some(conn) = self.conn.as_mut() {
                    if conn.send(OP_PONG, &frame.body).is_err() {
                        self.lost();
                    }
                }
            }
            OP_CLOSE => self.lost(),
            OP_FRAME => {
                let nonce = frame.body["nonce"].as_str().map(str::to_owned);
                let Some((pending, had_images)) = self.pending.clone() else { return };
                if nonce.as_deref() != Some(pending.as_str()) {
                    return;
                }
                self.pending = None;
                if frame.body["evt"] == "ERROR" {
                    let msg = frame.body["data"]["message"]
                        .as_str()
                        .unwrap_or("Discord rejected the update")
                        .to_owned();
                    if had_images && !self.strip_images {
                        // Most rejections are artwork the proxy can't fetch;
                        // show the rest of the presence instead of nothing.
                        self.strip_images = true;
                        self.shown = None;
                    }
                    self.notice = Some(msg);
                } else {
                    self.notice = None;
                }
                self.report();
            }
            _ => {}
        }
    }

    fn lost(&mut self) {
        self.drop_connection();
        // Reconnect right away (backoff kicks in if that fails).
        self.retry_at = None;
        self.report();
    }

    fn drop_connection(&mut self) {
        self.conn = None;
        self.shown = None;
        self.pending = None;
        self.next_poll = None;
        self.idle_since = None;
        self.blocked_until = None;
    }

    fn report(&mut self) {
        let status = if self.conn.is_some() {
            DiscordStatus::new(
                DiscordConnectionState::Connected,
                self.user.clone(),
                self.notice.clone(),
                None,
            )
        } else {
            DiscordStatus::idle()
        };
        publish(&self.hub, status);
    }

    fn shutdown(&mut self) {
        if let Some(conn) = self.conn.as_mut() {
            if self.shown.is_some() {
                let clear = json!({
                    "cmd": "SET_ACTIVITY",
                    "args": { "pid": std::process::id() },
                    "nonce": "shutdown",
                });
                let _ = conn.send(OP_FRAME, &clear);
            }
        }
        self.conn = None;
        publish(&self.hub, DiscordStatus::idle());
    }
}

fn parse_user(v: &Value) -> Option<DiscordUser> {
    let id = v["id"].as_str()?.to_owned();
    let username = v["username"].as_str().unwrap_or_default().to_owned();
    let display_name = v["global_name"].as_str().map(str::to_owned);
    let avatar_url = v["avatar"]
        .as_str()
        .map(|hash| format!("https://cdn.discordapp.com/avatars/{id}/{hash}.png?size=128"));
    Some(DiscordUser {
        id,
        username,
        display_name,
        avatar_url,
    })
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::api::discord::{DiscordActivityKind, DiscordProgress, DiscordStatusDisplay};

    fn activity(position_ms: u32) -> DiscordActivity {
        DiscordActivity {
            kind: DiscordActivityKind::Listening,
            status_display: DiscordStatusDisplay::State,
            details: "x".into(),
            details_url: Some("ftp://nope".into()),
            state: Some("a".repeat(300)),
            state_url: None,
            large_image: Some(format!("https://e.com/{}", "p".repeat(300))),
            large_text: None,
            large_url: None,
            small_image: Some("play".into()),
            small_text: Some("Playing".into()),
            progress: Some(DiscordProgress { position_ms, duration_ms: Some(200_000) }),
            buttons: vec![
                DiscordButton { label: "Open".into(), url: "https://e.com".into() },
                DiscordButton { label: "Bad".into(), url: "javascript:1".into() },
            ],
        }
    }

    #[test]
    fn enforces_discord_field_limits() {
        let json = Presence::new(activity(10_000)).to_json(false);
        assert_eq!(json["type"], 2);
        assert_eq!(json["status_display_type"], 1);
        assert_eq!(json["details"].as_str().unwrap().encode_utf16().count(), 2);
        assert_eq!(json["state"].as_str().unwrap().encode_utf16().count(), 128);
        assert!(json["state"].as_str().unwrap().ends_with('…'));
        assert!(json.get("details_url").is_none());
        // Over-long image URL is dropped, asset key kept.
        assert!(json["assets"].get("large_image").is_none());
        assert_eq!(json["assets"]["small_image"], "play");
        assert_eq!(json["buttons"].as_array().unwrap().len(), 1);
        let ts = &json["timestamps"];
        assert_eq!(ts["end"].as_i64().unwrap() - ts["start"].as_i64().unwrap(), 200_000);
    }

    #[test]
    fn playback_jitter_is_not_a_change_but_seek_is() {
        let a = Presence::new(activity(10_000));
        let mut jitter = a.clone();
        jitter.start_ms = a.start_ms.map(|s| s + 900);
        jitter.end_ms = a.end_ms.map(|s| s + 900);
        assert!(a.same_as(&jitter));
        let seek = Presence::new(activity(60_000));
        assert!(!a.same_as(&seek));
        assert!(Presence::new(activity(0)).to_json(true)["assets"].get("small_image").is_none());
    }
}
