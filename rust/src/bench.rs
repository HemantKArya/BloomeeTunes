//! Plugin host benchmarks against the plugins installed on this machine.
//!
//!   cargo test --release --lib bench -- --ignored --nocapture --test-threads 1
//!
//! BLOOMEE_PLUGINS_DIR overrides the plugins folder.

use crate::api::plugin::commands::{
    ChartProviderCommand, ContentResolverCommand, ContentSearchFilter, PluginRequest,
    SearchSuggestionCommand,
};
use crate::api::plugin::plugin::PluginManager;
use crate::api::plugin::types::PluginType;
use std::time::Instant;

fn plugins_dir() -> String {
    std::env::var("BLOOMEE_PLUGINS_DIR").unwrap_or_else(|_| {
        let appdata = std::env::var("APPDATA").expect("APPDATA");
        format!("{appdata}/Bloomee/bloomee/plugins")
    })
}

fn mb(bytes: usize) -> f64 {
    bytes as f64 / (1024.0 * 1024.0)
}

fn memory() -> (f64, f64) {
    let m = memory_stats::memory_stats().expect("memory stats");
    (mb(m.physical_mem), mb(m.virtual_mem))
}

fn threads() -> usize {
    let pid = std::process::id().to_string();
    std::process::Command::new("powershell")
        .args(["-NoProfile", "-Command", &format!("(Get-Process -Id {pid}).Threads.Count")])
        .output()
        .ok()
        .and_then(|o| String::from_utf8_lossy(&o.stdout).trim().parse().ok())
        .unwrap_or(0)
}

fn report(label: &str, base: (f64, f64)) {
    let (ws, private) = memory();
    println!(
        "{label:<28} working set {ws:7.1} MB (+{:6.1})   private {private:7.1} MB (+{:6.1})   threads {}",
        ws - base.0,
        private - base.1,
        threads()
    );
}

async fn load_all(manager: &PluginManager) -> Vec<(String, PluginType)> {
    let mut loaded = Vec::new();
    let started = Instant::now();
    for info in manager.get_available_plugins().await {
        let t = Instant::now();
        match manager.load_plugin(&info).await {
            Ok(()) => {
                println!("  load {:<60} {:6.1} ms", info.id(), t.elapsed().as_secs_f64() * 1e3);
                loaded.push((info.id().to_string(), info.plugin_type.clone()));
            }
            Err(e) => println!("  load {} failed: {e}", info.id()),
        }
    }
    println!("  all plugins loaded in {:.1} ms", started.elapsed().as_secs_f64() * 1e3);
    loaded
}

fn workload(plugin_type: &PluginType) -> Vec<PluginRequest> {
    match plugin_type {
        PluginType::ContentResolver => vec![
            PluginRequest::ContentResolver(ContentResolverCommand::GetHomeSections),
            PluginRequest::ContentResolver(ContentResolverCommand::Search {
                query: "believer".into(),
                filter: ContentSearchFilter::All,
                page_token: None,
            }),
        ],
        PluginType::ChartProvider => {
            vec![PluginRequest::ChartProvider(ChartProviderCommand::GetCharts)]
        }
        PluginType::SearchSuggestionProvider => vec![PluginRequest::SearchSuggestionProvider(
            SearchSuggestionCommand::GetSuggestions {
                query: "arijit".into(),
                limit: Some(10),
                include_entities: true,
            },
        )],
        _ => Vec::new(),
    }
}

/// Runs on the runtime the app uses for bridge calls.
#[test]
#[ignore]
fn bench_plugins() {
    let runtime = &crate::api::runtime::FLUTTER_RUST_BRIDGE_HANDLER.async_runtime().0;
    runtime.block_on(run());
}

async fn run() {
    let base = memory();
    report("start", base);

    let manager = PluginManager::new(plugins_dir()).await;
    manager.refresh_available_plugins().await;
    let loaded = load_all(&manager).await;
    report("after loading plugins", base);

    if std::env::var("BLOOMEE_BENCH_OFFLINE").is_ok() {
        return;
    }

    for round in 1..=3 {
        let started = Instant::now();
        let mut calls = Vec::new();
        for (id, plugin_type) in &loaded {
            for request in workload(plugin_type) {
                let manager = manager.clone();
                let id = id.clone();
                calls.push(tokio::spawn(async move {
                    let t = Instant::now();
                    let ok = manager.handle_plugin_request(&id, request).await.is_ok();
                    (id, ok, t.elapsed())
                }));
            }
        }
        for call in calls {
            let (id, ok, took) = call.await.unwrap();
            if round == 1 {
                println!(
                    "  call {:<60} {:>4} {:7.1} ms",
                    id,
                    if ok { "ok" } else { "err" },
                    took.as_secs_f64() * 1e3
                );
            }
        }
        println!("  round {round}: {:.1} ms", started.elapsed().as_secs_f64() * 1e3);
        report(&format!("after round {round}"), base);
    }

    manager.shutdown().await;
    report("after unloading", base);
}
