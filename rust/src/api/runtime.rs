//! Bridge handler with thread pools sized to the device. The default handler
//! starts one async worker and one sync worker per core and lets the blocking
//! pool grow to 512 threads; a music app never needs that many.

use std::panic::AssertUnwindSafe;
use std::sync::LazyLock;
use std::time::Duration;

use flutter_rust_bridge::for_generated::{NoOpErrorListener, SimpleExecutor};
use flutter_rust_bridge::{DefaultHandler, SimpleAsyncRuntime, SimpleThreadPool};

/// Plugin calls, file work and downloads each hold a blocking thread while
/// they run; anything beyond this waits its turn.
const MAX_BLOCKING_THREADS: usize = 16;

fn workers() -> usize {
    std::thread::available_parallelism()
        .map(|n| n.get())
        .unwrap_or(2)
        .clamp(2, 4)
}

pub static FLUTTER_RUST_BRIDGE_HANDLER: LazyLock<DefaultHandler<SimpleThreadPool>> =
    LazyLock::new(|| {
        let runtime = tokio::runtime::Builder::new_multi_thread()
            .worker_threads(workers())
            .max_blocking_threads(MAX_BLOCKING_THREADS)
            .thread_keep_alive(Duration::from_secs(20))
            .thread_name("bloomee-async")
            .enable_all()
            .build()
            .expect("async runtime");
        let pool = threadpool::Builder::new()
            .num_threads(workers())
            .thread_name("bloomee-sync".into())
            .build();
        DefaultHandler::new(
            SimpleExecutor::new(
                NoOpErrorListener,
                SimpleThreadPool(pool),
                SimpleAsyncRuntime(AssertUnwindSafe(runtime)),
            ),
            NoOpErrorListener,
        )
    });
