/// Download manager: public API + task lifecycle orchestration.
///
/// Internal implementation is split across:
/// - `types`    – all type definitions
/// - `utils`    – pure utility functions
/// - `resolver` – stream resolution via the plugin manager
/// - `transfer` – HTTP download loop + metadata writing
///
/// All sub-modules are `pub(crate)` so `frb_generated.rs` (at the crate root)
/// can reach them via its auto-generated glob imports. The internal types
/// carry no FRB attributes, so no codecs are generated for them.
pub(crate) mod types;
/// flutter_rust_bridge:ignore
pub(crate) mod utils;
/// flutter_rust_bridge:ignore
pub(crate) mod resolver;
/// flutter_rust_bridge:ignore
pub(crate) mod transfer;

pub use types::{
    DownloadManagerEvent, DownloadTaskSnapshot, DownloadTaskState, EnqueueDownloadRequest,
};

use std::collections::{HashMap, HashSet};
use std::path::Path;
use std::sync::{Arc, Mutex, RwLock};
use std::sync::atomic::Ordering;

use reqwest::blocking::Client;
use tokio::runtime::Handle;
use tokio::sync::Semaphore;
use tokio::time::{sleep, Duration};

use crate::api::plugin::plugin::PluginManager;
use crate::frb_generated::StreamSink;

use types::{EventHub, ManagedTask, PersistedDownloadTask, TransferOutcome};
use utils::{atomic_write, generate_task_id, normalize_quality, remove_if_exists};
use resolver::resolve_stream;
use transfer::{download_task_blocking, ProgressUpdate};

// ── DownloadManager ───────────────────────────────────────────────────────────

/// Opaque, Clone-able handle to the download subsystem.
/// All internal state is Arc-wrapped so clones share the same backing store.
#[derive(Clone)]
#[flutter_rust_bridge::frb(opaque)]
pub struct DownloadManager {
    plugin_manager: PluginManager,
    /// All in-flight and persisted tasks keyed by task_id.
    tasks: Arc<RwLock<HashMap<String, Arc<Mutex<ManagedTask>>>>>,
    /// FRB event sink + pre-attach buffer.
    event_hub: Arc<Mutex<EventHub>>,
    state_dir: String,
    temp_dir: String,
    /// Absolute path to `downloads_state.json`.
    manifest_path: String,
    /// Limits the number of concurrently downloading tasks.
    semaphore: Arc<Semaphore>,
    /// Shared HTTP client — reusing the connection pool across downloads.
    /// Wrapped in `Option` so `Drop` can take ownership of the `Arc<Client>`
    /// and move it to a non-async thread for safe destruction (the blocking
    /// client owns an internal tokio runtime that panics on drop inside an
    /// async context).
    http_client: Option<Arc<Client>>,
    runtime_handle: Handle,
}

impl DownloadManager {
    const MAX_RETRIES: u32 = 3;

    // ── Constructor ───────────────────────────────────────────────────────────

    pub async fn new(
        plugin_manager: PluginManager,
        state_dir: String,
        temp_dir: String,
        max_concurrent_tasks: u32,
    ) -> Result<Self, String> {
        tokio::fs::create_dir_all(&state_dir)
            .await
            .map_err(|e| format!("Failed to create download state dir: {e}"))?;
        tokio::fs::create_dir_all(&temp_dir)
            .await
            .map_err(|e| format!("Failed to create download temp dir: {e}"))?;

        let manifest_path = Path::new(&state_dir)
            .join("downloads_state.json")
            .to_string_lossy()
            .into_owned();

        // reqwest::blocking::Client creates an internal tokio runtime.
        // Building it inside an async context causes "Cannot drop a runtime
        // in a context where blocking is not allowed" panics when it is
        // eventually dropped.  Build it on a blocking thread instead.
        let http_client = tokio::task::spawn_blocking(|| {
            Client::builder()
                .build()
                .map_err(|e| format!("Failed to build HTTP client: {e}"))
        })
        .await
        .map_err(|e| format!("HTTP client builder thread panicked: {e}"))??;

        let runtime_handle = Handle::current();

        Ok(Self {
            plugin_manager,
            tasks: Arc::new(RwLock::new(HashMap::new())),
            event_hub: Arc::new(Mutex::new(EventHub::new())),
            state_dir,
            temp_dir,
            manifest_path,
            semaphore: Arc::new(Semaphore::new(max_concurrent_tasks.max(1) as usize)),
            http_client: Some(Arc::new(http_client)),
            runtime_handle,
        })
    }

    // ── Public API ────────────────────────────────────────────────────────────

    /// Attach the FRB event sink. Call this once from Dart after creating the
    /// manager. Any events buffered before this call are drained immediately.
    pub async fn init_event_stream(&self, sink: StreamSink<DownloadManagerEvent>) {
        if let Ok(mut hub) = self.event_hub.lock() {
            hub.attach(sink);
        }
    }

    /// Restore tasks persisted from a previous run.
    /// Emits `RecoverySummary` after reconciling state.
    pub async fn restore_tasks(&self) -> Result<Vec<DownloadTaskSnapshot>, String> {
        let path = Path::new(&self.manifest_path);
        if !path.exists() {
            self.emit(DownloadManagerEvent::RecoverySummary { restored: 0, cleaned: 0 });
            return Ok(Vec::new());
        }

        let raw = tokio::fs::read_to_string(path)
            .await
            .map_err(|e| format!("Failed to read download manifest: {e}"))?;

        let all_raw: Vec<PersistedDownloadTask> = serde_json::from_str(&raw)
            .map_err(|e| format!("Corrupt download manifest: {e}"))?;

        // Deduplicate by task_id (first occurrence wins) to guard against
        // any manifest corruption that might produce repeated entries.
        let mut seen_ids = HashSet::new();
        let mut all: Vec<PersistedDownloadTask> = Vec::with_capacity(all_raw.len());
        for t in all_raw {
            if seen_ids.insert(t.task_id.clone()) {
                all.push(t);
            }
        }

        let mut restored = 0u32;
        let mut cleaned = 0u32;
        let mut snapshots = Vec::new();

        for mut p in all {
            let target_ok = !p.target_path.is_empty() && Path::new(&p.target_path).exists();
            let temp_ok = !p.temp_path.is_empty() && Path::new(&p.temp_path).exists();

            match p.state {
                // Already completed — re-emit so Dart can persist it.
                DownloadTaskState::CompletedPendingAck if target_ok => {}

                // File is completely gone and task is terminal — clean up.
                DownloadTaskState::CompletedPendingAck
                | DownloadTaskState::Cancelled
                    if !target_ok && !temp_ok =>
                {
                    cleaned += 1;
                    continue;
                }

                // File was partially downloaded — resume from pause.
                _ if !target_ok && temp_ok => {
                    p.state = DownloadTaskState::Paused;
                    p.message = Some("Paused after restart".to_string());
                    restored += 1;
                }

                // Target exists but task state was wrong — fix it.
                _ if target_ok && p.state != DownloadTaskState::CompletedPendingAck => {
                    p.state = DownloadTaskState::CompletedPendingAck;
                    p.progress = 1.0;
                    p.message = Some("Ready to finalize".to_string());
                }

                // Active/in-progress task lost across restart.
                DownloadTaskState::Downloading
                | DownloadTaskState::Resolving
                | DownloadTaskState::Retrying
                | DownloadTaskState::WritingMetadata
                    if !target_ok && !temp_ok =>
                {
                    p.state = DownloadTaskState::Failed;
                    p.message = Some("Partial data was lost after restart".to_string());
                    p.last_error = Some("Download could not be recovered".to_string());
                }

                _ => {}
            }

            let task = Arc::new(Mutex::new(ManagedTask::from_persisted(p.clone())));
            snapshots.push(DownloadTaskSnapshot::from_persisted(&p));
            if let Ok(mut guard) = self.tasks.write() {
                guard.insert(p.task_id.clone(), task);
            }
        }

        self.persist_manifest();

        for snapshot in &snapshots {
            match snapshot.state {
                DownloadTaskState::CompletedPendingAck => {
                    self.emit(DownloadManagerEvent::TaskCompletedPendingAck(snapshot.clone()));
                }
                _ => self.emit(DownloadManagerEvent::TaskUpdated(snapshot.clone())),
            }
        }
        self.emit(DownloadManagerEvent::RecoverySummary { restored, cleaned });

        Ok(snapshots)
    }

    /// Enqueue a new download. Returns the task ID.
    pub async fn enqueue(&self, request: EnqueueDownloadRequest) -> Result<String, String> {
        let task_id = generate_task_id();
        let temp_path = Path::new(&self.temp_dir)
            .join(format!("{task_id}.part"))
            .to_string_lossy()
            .into_owned();

        let p = PersistedDownloadTask {
            task_id: task_id.clone(),
            track: request.track,
            download_dir: request.download_dir,
            preferred_quality: normalize_quality(&request.preferred_quality).to_string(),
            file_name: String::new(),
            target_path: String::new(),
            temp_path,
            state: DownloadTaskState::Queued,
            progress: 0.0,
            bytes_downloaded: 0,
            total_bytes: None,
            message: Some("Queued".to_string()),
            last_error: None,
            retry_attempt: 0,
            selected_stream: None,
        };

        let snapshot = DownloadTaskSnapshot::from_persisted(&p);

        if let Ok(mut guard) = self.tasks.write() {
            guard.insert(task_id.clone(), Arc::new(Mutex::new(ManagedTask::from_persisted(p))));
        }
        self.persist_manifest();
        self.emit(DownloadManagerEvent::TaskUpdated(snapshot));
        self.spawn_worker(task_id.clone());
        Ok(task_id)
    }

    /// Snapshot all current tasks.
    pub fn get_snapshots(&self) -> Vec<DownloadTaskSnapshot> {
        let Ok(guard) = self.tasks.read() else { return Vec::new() };
        guard
            .values()
            .filter_map(|t| t.lock().ok())
            .map(|g| DownloadTaskSnapshot::from_persisted(&g.persisted))
            .collect()
    }

    /// Signal a running download to pause. Returns `false` if the task does not exist.
    pub async fn pause_task(&self, task_id: String) -> bool {
        let Some(task) = self.get_task(&task_id) else { return false };
        if let Ok(g) = task.lock() {
            g.pause_requested.store(true, Ordering::Release);
        }
        true
    }

    /// Queue a paused/failed task for another download attempt.
    pub async fn resume_task(&self, task_id: String) -> bool {
        let Some(task) = self.get_task(&task_id) else { return false };

        let should_spawn = {
            let mut g = match task.lock() {
                Ok(g) => g,
                Err(_) => return false,
            };
            let resumable = matches!(
                g.persisted.state,
                DownloadTaskState::Paused | DownloadTaskState::Failed | DownloadTaskState::Queued
            );
            if resumable {
                g.pause_requested.store(false, Ordering::Release);
                g.cancel_requested.store(false, Ordering::Release);
                g.delete_partial_on_cancel.store(false, Ordering::Release);
                g.persisted.state = DownloadTaskState::Queued;
                g.persisted.message = Some("Queued".to_string());
                g.persisted.last_error = None;
            }
            resumable
        };

        if should_spawn {
            self.persist_manifest();
            if let Some(snap) = self.snapshot_for(&task_id) {
                self.emit(DownloadManagerEvent::TaskUpdated(snap));
            }
            self.spawn_worker(task_id);
        }
        should_spawn
    }

    /// Request cancellation of a task.
    /// `delete_partial`: if `true`, remove the .part file too.
    pub async fn cancel_task(&self, task_id: String, delete_partial: bool) -> bool {
        let Some(task) = self.get_task(&task_id) else { return false };

        let (remove_now, temp_path, target_path) = {
            let mut g = match task.lock() {
                Ok(g) => g,
                Err(_) => return false,
            };
            g.cancel_requested.store(true, Ordering::Release);
            g.delete_partial_on_cancel.store(delete_partial, Ordering::Release);

            let remove_now = !g.running;
            if remove_now {
                g.persisted.state = DownloadTaskState::Cancelled;
                g.persisted.message = Some("Cancelled".to_string());
            }
            (remove_now, g.persisted.temp_path.clone(), g.persisted.target_path.clone())
        };

        if remove_now {
            if delete_partial {
                let _ = remove_if_exists(&temp_path);
                let _ = remove_if_exists(&target_path);
            }
            self.remove_task(&task_id);
        }
        true
    }

    /// Called by Dart after successfully persisting a completed download to its
    /// database. Removes the task from the manager.
    pub async fn acknowledge_persisted(&self, task_id: String) -> bool {
        self.remove_task(&task_id)
    }

    // ── Internal: task spawning / execution ───────────────────────────────────

    fn spawn_worker(&self, task_id: String) {
        let Some(task) = self.get_task(&task_id) else { return };

        {
            let Ok(mut g) = task.lock() else { return };
            if g.running || matches!(g.persisted.state, DownloadTaskState::CompletedPendingAck) {
                return;
            }
            g.running = true;
            g.pause_requested.store(false, Ordering::Release);
            g.cancel_requested.store(false, Ordering::Release);
            if matches!(g.persisted.state, DownloadTaskState::Failed | DownloadTaskState::Paused) {
                g.persisted.retry_attempt = 0;
            }
        }

        let manager = self.clone();
        self.runtime_handle.spawn(async move {
            let Ok(_permit) = manager.semaphore.clone().acquire_owned().await else { return };
            manager.run_task(task_id.clone()).await;
            if let Some(t) = manager.get_task(&task_id) {
                if let Ok(mut g) = t.lock() {
                    g.running = false;
                }
            }
        });
    }

    async fn run_task(&self, task_id: String) {
        for attempt in 0..=Self::MAX_RETRIES {
            let Some(task) = self.get_task(&task_id) else { return };

            self.set_task_state(
                &task_id,
                DownloadTaskState::Resolving,
                Some("Resolving stream".to_string()),
                None,
            );

            let stream = match resolve_stream(&task, &self.plugin_manager).await {
                Ok(s) => s,
                Err(e) => {
                    self.fail_task(&task_id, e);
                    return;
                }
            };

            // Persist the resolved file name / target path before starting I/O.
            self.persist_manifest();
            if let Some(snap) = self.snapshot_for(&task_id) {
                self.emit(DownloadManagerEvent::TaskUpdated(snap));
            }

            let manager = self.clone();
            let task_arc = task.clone();
            let stream_clone = stream.clone();
            // Own the task_id so the 'static closure can borrow it.
            let tid = task_id.clone();

            let transfer_result = tokio::task::spawn_blocking(move || {
                let client = manager
                    .http_client
                    .as_ref()
                    .expect("http_client is None — DownloadManager already dropped");
                download_task_blocking(
                    &task_arc,
                    &stream_clone,
                    client,
                    |update| manager.handle_progress_update(&tid, update),
                )
            })
            .await;

            match transfer_result {
                Ok(Ok(TransferOutcome::Completed)) => {
                    // Progress callback already updated in-memory state.
                    // Persist once and emit the completion event.
                    self.persist_manifest();
                    if let Some(snap) = self.snapshot_for(&task_id) {
                        self.emit(DownloadManagerEvent::TaskCompletedPendingAck(snap));
                    }
                    return;
                }
                Ok(Ok(TransferOutcome::Paused)) => {
                    self.persist_manifest();
                    return;
                }
                Ok(Ok(TransferOutcome::Cancelled)) => {
                    self.remove_task(&task_id);
                    return;
                }
                Ok(Err(e)) => {
                    if attempt < Self::MAX_RETRIES {
                        self.update_retrying(&task_id, attempt + 1, e);
                        sleep(Duration::from_secs(1u64 << (attempt + 1))).await;
                        continue;
                    }
                    self.fail_task(&task_id, e);
                    return;
                }
                Err(e) => {
                    self.fail_task(&task_id, format!("Worker thread panicked: {e}"));
                    return;
                }
            }
        }
    }

    // ── Internal: progress callback used by transfer ──────────────────────────

    fn handle_progress_update(&self, task_id: &str, update: ProgressUpdate) {
        // Progress events during the download loop do NOT persist to disk
        // (would cause disk thrash at 250ms intervals). We persist only on
        // state transitions and at completion.
        let persist = !matches!(update.state, DownloadTaskState::Downloading);

        if let Some(task) = self.get_task(task_id) {
            if let Ok(mut g) = task.lock() {
                let total = update.total_bytes;
                let bytes = update.bytes_downloaded;
                g.persisted.state = update.state.clone();
                g.persisted.bytes_downloaded = bytes;
                g.persisted.total_bytes = total;
                g.persisted.progress = total
                    .filter(|&t| t > 0)
                    .map(|t| (bytes as f64 / t as f64).clamp(0.0, 1.0))
                    .unwrap_or_else(|| match update.state {
                        DownloadTaskState::CompletedPendingAck => 1.0,
                        _ => 0.0,
                    });
                g.persisted.message = Some(update.message.clone());
                if let Some(w) = &update.warning {
                    g.persisted.last_error = Some(w.clone());
                }
            }
        }

        if persist {
            self.persist_manifest();
        }
        if let Some(snap) = self.snapshot_for(task_id) {
            // CompletedPendingAck is emitted from run_task after persist, not here.
            if !matches!(snap.state, DownloadTaskState::CompletedPendingAck) {
                self.emit(DownloadManagerEvent::TaskUpdated(snap));
            }
        }
    }

    // ── Internal: state helpers ───────────────────────────────────────────────

    fn set_task_state(
        &self,
        task_id: &str,
        state: DownloadTaskState,
        message: Option<String>,
        last_error: Option<String>,
    ) {
        if let Some(task) = self.get_task(task_id) {
            if let Ok(mut g) = task.lock() {
                g.persisted.state = state;
                g.persisted.message = message;
                g.persisted.last_error = last_error;
            }
        }
        self.persist_manifest();
        if let Some(snap) = self.snapshot_for(task_id) {
            self.emit(DownloadManagerEvent::TaskUpdated(snap));
        }
    }

    fn update_retrying(&self, task_id: &str, attempt: u32, error: String) {
        if let Some(task) = self.get_task(task_id) {
            if let Ok(mut g) = task.lock() {
                g.persisted.retry_attempt = attempt;
                g.persisted.state = DownloadTaskState::Retrying;
                g.persisted.message = Some(format!("Retrying ({attempt}/{})", Self::MAX_RETRIES));
                g.persisted.last_error = Some(error);
            }
        }
        self.persist_manifest();
        if let Some(snap) = self.snapshot_for(task_id) {
            self.emit(DownloadManagerEvent::TaskUpdated(snap));
        }
    }

    fn fail_task(&self, task_id: &str, error: String) {
        self.set_task_state(
            task_id,
            DownloadTaskState::Failed,
            Some("Download failed".to_string()),
            Some(error),
        );
    }

    fn remove_task(&self, task_id: &str) -> bool {
        let removed = if let Ok(mut g) = self.tasks.write() {
            g.remove(task_id).is_some()
        } else {
            false
        };
        if removed {
            self.persist_manifest();
            self.emit(DownloadManagerEvent::TaskRemoved { task_id: task_id.to_string() });
        }
        removed
    }

    // ── Internal: accessors ───────────────────────────────────────────────────

    fn get_task(&self, task_id: &str) -> Option<Arc<Mutex<ManagedTask>>> {
        self.tasks.read().ok()?.get(task_id).cloned()
    }

    fn snapshot_for(&self, task_id: &str) -> Option<DownloadTaskSnapshot> {
        let task = self.get_task(task_id)?;
        let g = task.lock().ok()?;
        Some(DownloadTaskSnapshot::from_persisted(&g.persisted))
    }

    // ── Internal: event emission ──────────────────────────────────────────────

    fn emit(&self, event: DownloadManagerEvent) {
        if let Ok(mut hub) = self.event_hub.lock() {
            hub.emit(event);
        }
    }

    // ── Internal: manifest persistence ───────────────────────────────────────

    /// Serialize all tasks and write atomically (temp-rename pattern).
    /// Failures are silently swallowed — a missing manifest is handled on the
    /// next `restore_tasks` call.
    fn persist_manifest(&self) {
        let tasks: Vec<PersistedDownloadTask> = match self.tasks.read() {
            Ok(g) => g.values().filter_map(|t| t.lock().ok()).map(|g| g.persisted.clone()).collect(),
            Err(_) => return,
        };

        if let Ok(json) = serde_json::to_string_pretty(&tasks) {
            let _ = std::fs::create_dir_all(&self.state_dir);
            let _ = atomic_write(&self.manifest_path, json.as_bytes());
        }
    }
}

/// Safety net: `reqwest::blocking::Client` owns an internal tokio runtime.
/// When FRB drops the opaque `DownloadManager` it does so from an async
/// worker thread.  Dropping the runtime inside another runtime panics with
/// "Cannot drop a runtime in a context where blocking is not allowed."
///
/// If we hold the last `Arc` reference to the client **and** we are inside
/// a tokio context, move it to a plain OS thread for destruction.
impl Drop for DownloadManager {
    fn drop(&mut self) {
        if let Some(client) = self.http_client.take() {
            // Only the last Arc holder actually drops the inner Client.
            // If there are other clones alive, `drop(client)` just decrements
            // the reference count — no inner runtime is touched.
            if Arc::strong_count(&client) == 1 && Handle::try_current().is_ok() {
                // We are the last owner *and* inside an async context.
                // Move destruction off the async runtime.
                std::thread::spawn(move || drop(client));
            }
            // else: either there are other clones (no inner drop) or we are
            // not in an async context (safe to drop normally — implicit).
        }
    }
}

