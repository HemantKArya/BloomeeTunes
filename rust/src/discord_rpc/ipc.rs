//! Discord local IPC transport.
//!
//! Wire format (https://docs.discord.com/developers/topics/rpc):
//! `[opcode: u32 LE][length: u32 LE][utf-8 JSON]`.
//!
//! Every call here is non-blocking on reads: `poll` only returns bytes that
//! have already arrived (Windows: `PeekNamedPipe`, Unix: non-blocking socket)
//! and reports a closed peer as an error, which doubles as the liveness
//! probe. Writes are tiny frames and finish immediately in practice.

use serde_json::Value;
use std::io::{self, Read, Write};
use std::time::{Duration, Instant};

pub const OP_HANDSHAKE: u32 = 0;
pub const OP_FRAME: u32 = 1;
pub const OP_CLOSE: u32 = 2;
pub const OP_PING: u32 = 3;
pub const OP_PONG: u32 = 4;

const MAX_FRAME: usize = 1 << 20;

pub struct Frame {
    pub op: u32,
    pub body: Value,
}

pub struct Connection {
    io: Transport,
    inbox: Vec<u8>,
}

impl Connection {
    /// Tries `discord-ipc-0..9` in every known location. `None` when no
    /// Discord client is listening.
    pub fn open() -> Option<Self> {
        Transport::open().map(|io| Self {
            io,
            inbox: Vec::with_capacity(4096),
        })
    }

    pub fn send(&mut self, op: u32, body: &Value) -> io::Result<()> {
        let json = serde_json::to_vec(body)?;
        let mut frame = Vec::with_capacity(8 + json.len());
        frame.extend_from_slice(&op.to_le_bytes());
        frame.extend_from_slice(&(json.len() as u32).to_le_bytes());
        frame.extend_from_slice(&json);
        self.io.write_all(&frame)
    }

    /// Frames that have arrived so far. `Err` once the peer has gone away.
    pub fn poll(&mut self) -> io::Result<Vec<Frame>> {
        self.io.read_available(&mut self.inbox)?;
        let mut frames = Vec::new();
        let mut offset = 0;
        while self.inbox.len() - offset >= 8 {
            let op = u32::from_le_bytes(self.inbox[offset..offset + 4].try_into().unwrap());
            let len =
                u32::from_le_bytes(self.inbox[offset + 4..offset + 8].try_into().unwrap()) as usize;
            if len > MAX_FRAME {
                return Err(io::Error::new(io::ErrorKind::InvalidData, "oversized frame"));
            }
            if self.inbox.len() - offset - 8 < len {
                break;
            }
            let raw = &self.inbox[offset + 8..offset + 8 + len];
            offset += 8 + len;
            if let Ok(body) = serde_json::from_slice(raw) {
                frames.push(Frame { op, body });
            }
        }
        self.inbox.drain(..offset);
        Ok(frames)
    }

    /// Waits for the first frame matching `pred`, polling cheaply.
    pub fn wait_for(
        &mut self,
        timeout: Duration,
        mut pred: impl FnMut(&Frame) -> bool,
    ) -> io::Result<Option<Frame>> {
        let deadline = Instant::now() + timeout;
        loop {
            for frame in self.poll()? {
                if pred(&frame) {
                    return Ok(Some(frame));
                }
            }
            if Instant::now() >= deadline {
                return Ok(None);
            }
            std::thread::sleep(Duration::from_millis(10));
        }
    }
}

// ── Windows: named pipe ──────────────────────────────────────────────────────

#[cfg(windows)]
struct Transport(std::fs::File);

#[cfg(windows)]
mod win {
    use std::ffi::c_void;
    #[link(name = "kernel32")]
    extern "system" {
        pub fn PeekNamedPipe(
            pipe: *mut c_void,
            buffer: *mut c_void,
            buffer_size: u32,
            bytes_read: *mut u32,
            total_available: *mut u32,
            bytes_left: *mut u32,
        ) -> i32;
    }
}

#[cfg(windows)]
impl Transport {
    fn open() -> Option<Self> {
        (0..10).find_map(|i| {
            std::fs::OpenOptions::new()
                .read(true)
                .write(true)
                .open(format!(r"\\?\pipe\discord-ipc-{i}"))
                .ok()
                .map(Transport)
        })
    }

    fn write_all(&mut self, bytes: &[u8]) -> io::Result<()> {
        self.0.write_all(bytes)?;
        self.0.flush()
    }

    fn read_available(&mut self, out: &mut Vec<u8>) -> io::Result<()> {
        use std::os::windows::io::AsRawHandle;
        loop {
            let mut available: u32 = 0;
            // SAFETY: valid pipe handle owned by `self.0`; only the count
            // out-pointer is written.
            let ok = unsafe {
                win::PeekNamedPipe(
                    self.0.as_raw_handle() as _,
                    std::ptr::null_mut(),
                    0,
                    std::ptr::null_mut(),
                    &mut available,
                    std::ptr::null_mut(),
                )
            };
            if ok == 0 {
                return Err(io::Error::last_os_error());
            }
            if available == 0 {
                return Ok(());
            }
            // Data is already buffered, so this read cannot block.
            let start = out.len();
            out.resize(start + available as usize, 0);
            let n = self.0.read(&mut out[start..])?;
            out.truncate(start + n);
            if n == 0 {
                return Err(io::ErrorKind::UnexpectedEof.into());
            }
        }
    }
}

// ── Linux / macOS: unix domain socket ────────────────────────────────────────

#[cfg(unix)]
struct Transport(std::os::unix::net::UnixStream);

#[cfg(unix)]
impl Transport {
    fn candidates() -> Vec<std::path::PathBuf> {
        let mut roots: Vec<String> = ["XDG_RUNTIME_DIR", "TMPDIR", "TMP", "TEMP"]
            .iter()
            .filter_map(|k| std::env::var(k).ok())
            .filter(|v| !v.is_empty())
            .collect();
        roots.push("/tmp".into());
        roots.dedup();
        let mut out = Vec::new();
        for root in roots {
            // Native, Flatpak and Snap Discord builds.
            for sub in ["", "app/com.discordapp.Discord/", "snap.discord/"] {
                for i in 0..10 {
                    out.push(std::path::PathBuf::from(format!("{root}/{sub}discord-ipc-{i}")));
                }
            }
        }
        out
    }

    fn open() -> Option<Self> {
        use std::os::unix::fs::FileTypeExt;
        Self::candidates().into_iter().find_map(|path| {
            let is_socket = std::fs::symlink_metadata(&path)
                .map(|m| m.file_type().is_socket())
                .unwrap_or(false);
            if !is_socket {
                return None;
            }
            let stream = std::os::unix::net::UnixStream::connect(&path).ok()?;
            stream.set_nonblocking(true).ok()?;
            Some(Transport(stream))
        })
    }

    fn write_all(&mut self, mut bytes: &[u8]) -> io::Result<()> {
        let deadline = Instant::now() + Duration::from_secs(2);
        while !bytes.is_empty() {
            match self.0.write(bytes) {
                Ok(0) => return Err(io::ErrorKind::WriteZero.into()),
                Ok(n) => bytes = &bytes[n..],
                Err(e) if e.kind() == io::ErrorKind::WouldBlock => {
                    if Instant::now() >= deadline {
                        return Err(io::ErrorKind::TimedOut.into());
                    }
                    std::thread::sleep(Duration::from_millis(5));
                }
                Err(e) if e.kind() == io::ErrorKind::Interrupted => {}
                Err(e) => return Err(e),
            }
        }
        Ok(())
    }

    fn read_available(&mut self, out: &mut Vec<u8>) -> io::Result<()> {
        let mut chunk = [0u8; 4096];
        loop {
            match self.0.read(&mut chunk) {
                Ok(0) => return Err(io::ErrorKind::UnexpectedEof.into()),
                Ok(n) => out.extend_from_slice(&chunk[..n]),
                Err(e) if e.kind() == io::ErrorKind::WouldBlock => return Ok(()),
                Err(e) if e.kind() == io::ErrorKind::Interrupted => {}
                Err(e) => return Err(e),
            }
        }
    }
}
