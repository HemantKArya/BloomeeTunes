//! Discord Rich Presence over the local IPC socket/pipe.
//!
//! All calls are `sync` and return in microseconds: they only push a
//! command to the `discord-rpc` thread (see `crate::discord_rpc::worker`).
//! Desktop only (Windows named pipe, Linux/macOS unix socket incl. Flatpak
//! and Snap Discord); on other targets the worker simply never finds Discord.

use crate::discord_rpc::worker::{Command, Hub, StatusHub, Worker};
use crate::frb_generated::StreamSink;
use flutter_rust_bridge::frb;
use once_cell::sync::Lazy;
use std::sync::mpsc::{channel, Sender};
use std::sync::{Arc, Mutex};

/// How the activity line reads in Discord ("Listening to …", "Playing …").
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum DiscordActivityKind {
    Listening,
    Playing,
    Watching,
}

impl DiscordActivityKind {
    pub(crate) fn wire(self) -> i32 {
        match self {
            Self::Playing => 0,
            Self::Listening => 2,
            Self::Watching => 3,
        }
    }
}

/// Which field Discord shows in the member list / status line.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum DiscordStatusDisplay {
    /// The app name, e.g. "Listening to Bloomee".
    AppName,
    /// The `state` field (artist).
    State,
    /// The `details` field (song title).
    Details,
}

impl DiscordStatusDisplay {
    pub(crate) fn wire(self) -> i32 {
        match self {
            Self::AppName => 0,
            Self::State => 1,
            Self::Details => 2,
        }
    }
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct DiscordButton {
    pub label: String,
    pub url: String,
}

/// Playback position used to draw Discord's live progress bar. Discord
/// advances the bar itself, so this only needs re-sending on seek/resume.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct DiscordProgress {
    pub position_ms: u32,
    pub duration_ms: Option<u32>,
}

/// Desired presence. Field limits (lengths, URL schemes, button count) are
/// enforced on the Rust side, so callers can pass raw metadata.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct DiscordActivity {
    pub kind: DiscordActivityKind,
    pub status_display: DiscordStatusDisplay,
    pub details: String,
    pub details_url: Option<String>,
    pub state: Option<String>,
    pub state_url: Option<String>,
    /// Uploaded asset key or an `https://` image URL.
    pub large_image: Option<String>,
    pub large_text: Option<String>,
    pub large_url: Option<String>,
    pub small_image: Option<String>,
    pub small_text: Option<String>,
    /// `None` hides the time bar (e.g. while paused).
    pub progress: Option<DiscordProgress>,
    pub buttons: Vec<DiscordButton>,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum DiscordConnectionState {
    /// Not connected and nothing to show.
    Idle,
    Connecting,
    Connected,
    /// Wants to show a presence but Discord isn't running; retrying.
    NotFound,
    /// Discord refused us (e.g. invalid application id); retrying slowly.
    Error,
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct DiscordUser {
    pub id: String,
    pub username: String,
    pub display_name: Option<String>,
    pub avatar_url: Option<String>,
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct DiscordStatus {
    pub state: DiscordConnectionState,
    pub user: Option<DiscordUser>,
    /// Last error/notice from Discord, if any.
    pub message: Option<String>,
    /// Seconds until the next connection attempt.
    pub retry_in_secs: Option<u32>,
}

impl DiscordStatus {
    pub(crate) fn new(
        state: DiscordConnectionState,
        user: Option<DiscordUser>,
        message: Option<String>,
        retry_in_secs: Option<u32>,
    ) -> Self {
        Self {
            state,
            user,
            message,
            retry_in_secs,
        }
    }

    pub(crate) fn idle() -> Self {
        Self::new(DiscordConnectionState::Idle, None, None, None)
    }
}

struct Running {
    client_id: String,
    tx: Sender<Command>,
}

static RUNNING: Lazy<Mutex<Option<Running>>> = Lazy::new(|| Mutex::new(None));
static HUB: Lazy<Hub> = Lazy::new(|| Arc::new(Mutex::new(StatusHub::new())));

/// Starts the presence thread (idempotent; restarts on a new client id).
#[frb(sync)]
pub fn discord_start(client_id: String) {
    let Ok(mut running) = RUNNING.lock() else { return };
    if running.as_ref().is_some_and(|r| r.client_id == client_id) {
        return;
    }
    if let Some(old) = running.take() {
        let _ = old.tx.send(Command::Shutdown);
    }
    let (tx, rx) = channel();
    let worker = Worker::new(client_id.clone(), rx, HUB.clone());
    let spawned = std::thread::Builder::new()
        .name("discord-rpc".into())
        .stack_size(256 * 1024)
        .spawn(move || worker.run());
    if spawned.is_ok() {
        *running = Some(Running { client_id, tx });
    }
}

/// Sets (or with `None`, clears) the presence. Coalesced and deduplicated
/// on the worker, so calling this often is cheap.
#[frb(sync)]
pub fn discord_set_activity(activity: Option<DiscordActivity>) {
    send(Command::Activity(activity.map(Box::new)));
}

/// Drops the current connection and reconnects now.
#[frb(sync)]
pub fn discord_reconnect() {
    send(Command::Reconnect);
}

/// Clears the presence, disconnects and ends the thread.
#[frb(sync)]
pub fn discord_stop() {
    if let Ok(mut running) = RUNNING.lock() {
        if let Some(r) = running.take() {
            let _ = r.tx.send(Command::Shutdown);
        }
    }
}

/// Connection status updates (emits the current status immediately).
pub fn discord_status_stream(sink: StreamSink<DiscordStatus>) {
    if let Ok(mut hub) = HUB.lock() {
        hub.attach(sink);
    }
}

fn send(cmd: Command) {
    if let Ok(running) = RUNNING.lock() {
        if let Some(r) = running.as_ref() {
            let _ = r.tx.send(cmd);
        }
    }
}
