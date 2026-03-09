/// Type definitions for the download subsystem.
///
/// The four types with `#[frb(mirror(...))]` attributes (`DownloadTaskState`,
/// `DownloadTaskSnapshot`, `DownloadManagerEvent`, `EnqueueDownloadRequest`)
/// are bridged to Dart by FRB.
///
/// Internal types (`PersistedDownloadTask`, `ManagedTask`, `EventHub`,
/// `TransferOutcome`) carry `#[frb(ignore)]` so FRB skips code-generation
/// for them entirely.
use std::collections::VecDeque;
use std::sync::atomic::AtomicBool;
use std::sync::Arc;

use flutter_rust_bridge::frb;
use serde::{Deserialize, Serialize};

use crate::api::plugin::models::{StreamSource, Track};

// ── Public API types (bridged to Dart by FRB) ─────────────────────────────────

#[frb(mirror(DownloadTaskState))]
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum DownloadTaskState {
    Queued,
    Resolving,
    Downloading,
    Paused,
    Retrying,
    WritingMetadata,
    /// Final state: file is ready, waiting for Dart to acknowledge persistence.
    CompletedPendingAck,
    Failed,
    Cancelled,
}

#[frb(mirror(DownloadTaskSnapshot))]
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DownloadTaskSnapshot {
    pub task_id: String,
    pub track: Track,
    pub file_name: String,
    pub target_path: String,
    pub temp_path: String,
    pub state: DownloadTaskState,
    pub progress: f64,
    pub bytes_downloaded: u64,
    pub total_bytes: Option<u64>,
    pub message: Option<String>,
    pub last_error: Option<String>,
}

#[frb(mirror(DownloadManagerEvent))]
#[derive(Debug, Clone)]
pub enum DownloadManagerEvent {
    /// Emitted on every meaningful state/progress change.
    TaskUpdated(DownloadTaskSnapshot),
    /// Emitted once when the file is fully written. Dart must persist it to
    /// the database then call `acknowledge_persisted`.
    TaskCompletedPendingAck(DownloadTaskSnapshot),
    /// Emitted after a task is fully removed (ack or cancel).
    TaskRemoved { task_id: String },
    /// Emitted once on startup summarising state reconciliation.
    RecoverySummary { restored: u32, cleaned: u32 },
}

#[frb(mirror(EnqueueDownloadRequest))]
#[derive(Debug, Clone)]
pub struct EnqueueDownloadRequest {
    pub track: Track,
    pub download_dir: String,
    pub preferred_quality: String,
}

// ── Internal domain types (FRB-ignored) ──────────────────────────────────────

/// Full task state written to the JSON manifest for crash recovery.
#[frb(ignore)]
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PersistedDownloadTask {
    pub task_id: String,
    pub track: Track,
    pub download_dir: String,
    pub preferred_quality: String,
    pub file_name: String,
    pub target_path: String,
    pub temp_path: String,
    pub state: DownloadTaskState,
    pub progress: f64,
    pub bytes_downloaded: u64,
    pub total_bytes: Option<u64>,
    pub message: Option<String>,
    pub last_error: Option<String>,
    pub retry_attempt: u32,
    /// Cached resolved stream (re-resolved when expired or absent).
    pub selected_stream: Option<StreamSource>,
}

/// Runtime wrapper around a persisted task. Lives in the in-memory HashMap.
#[frb(ignore)]
pub struct ManagedTask {
    pub persisted: PersistedDownloadTask,
    /// `true` while a worker tokio task holds the semaphore permit.
    pub running: bool,
    pub pause_requested: Arc<AtomicBool>,
    pub cancel_requested: Arc<AtomicBool>,
    /// When `true` a cancel also deletes the partial file.
    pub delete_partial_on_cancel: Arc<AtomicBool>,
}

/// Outcome returned by the blocking HTTP transfer loop.
#[frb(ignore)]
pub enum TransferOutcome {
    Completed,
    Paused,
    Cancelled,
}

impl ManagedTask {
    pub fn from_persisted(persisted: PersistedDownloadTask) -> Self {
        Self {
            persisted,
            running: false,
            pause_requested: Arc::new(AtomicBool::new(false)),
            cancel_requested: Arc::new(AtomicBool::new(false)),
            delete_partial_on_cancel: Arc::new(AtomicBool::new(false)),
        }
    }
}

impl DownloadTaskSnapshot {
    #[frb(ignore)]
    pub fn from_persisted(p: &PersistedDownloadTask) -> Self {
        Self {
            task_id: p.task_id.clone(),
            track: p.track.clone(),
            file_name: p.file_name.clone(),
            target_path: p.target_path.clone(),
            temp_path: p.temp_path.clone(),
            state: p.state.clone(),
            progress: p.progress,
            bytes_downloaded: p.bytes_downloaded,
            total_bytes: p.total_bytes,
            message: p.message.clone(),
            last_error: p.last_error.clone(),
        }
    }
}

// ── Event-sink wrapper ────────────────────────────────────────────────────────

use crate::frb_generated::StreamSink;

/// Bundles the optional FRB event sink with a bounded pre-attach buffer.
#[frb(ignore)]
pub struct EventHub {
    pub sink: Option<StreamSink<DownloadManagerEvent>>,
    /// Events queued before `init_event_stream` is called.
    pub pending: VecDeque<DownloadManagerEvent>,
}

impl EventHub {
    pub const MAX_PENDING: usize = 1024;

    pub fn new() -> Self {
        Self {
            sink: None,
            pending: VecDeque::with_capacity(64),
        }
    }

    /// Send an event to the sink, or buffer it if the sink is not yet attached.
    pub fn emit(&mut self, event: DownloadManagerEvent) {
        if let Some(sink) = &self.sink {
            let _ = sink.add(event);
        } else {
            if self.pending.len() >= Self::MAX_PENDING {
                self.pending.pop_front();
            }
            self.pending.push_back(event);
        }
    }

    /// Attach the FRB sink and immediately drain any buffered events.
    pub fn attach(&mut self, sink: StreamSink<DownloadManagerEvent>) {
        self.sink = Some(sink);
        for event in self.pending.drain(..) {
            if let Some(s) = &self.sink {
                let _ = s.add(event);
            }
        }
    }
}
