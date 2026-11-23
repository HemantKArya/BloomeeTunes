//! The one HTTP client for the whole library: plugin host calls, downloads
//! and artwork share a connection pool, TLS configuration and DNS cache.

use std::sync::LazyLock;
use std::time::Duration;

use reqwest::header::{HeaderName, HeaderValue, USER_AGENT};
use reqwest::Method;

const PLUGIN_USER_AGENT: &str = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36";
const PLUGIN_TIMEOUT: Duration = Duration::from_secs(30);

static CLIENT: LazyLock<reqwest::Client> = LazyLock::new(|| {
    reqwest::Client::builder()
        .connect_timeout(Duration::from_secs(15))
        .read_timeout(Duration::from_secs(30))
        .pool_idle_timeout(Duration::from_secs(60))
        .pool_max_idle_per_host(4)
        .tcp_keepalive(Duration::from_secs(60))
        .build()
        .expect("TLS backend is compiled in")
});

pub fn client() -> &'static reqwest::Client {
    &CLIENT
}

pub struct Request {
    pub method: Method,
    pub url: String,
    pub headers: Vec<(String, String)>,
    pub body: Option<Vec<u8>>,
    pub timeout_seconds: Option<u32>,
}

pub struct Response {
    pub status: u16,
    pub headers: Vec<(String, String)>,
    pub body: Vec<u8>,
}

/// Performs a plugin's request from inside a WASM host call. Plugin calls run
/// on the runtime's blocking pool, so the request is driven to completion on
/// that thread while the pool's IO driver does the socket work.
pub fn send_blocking(request: Request) -> Result<Response, String> {
    tokio::runtime::Handle::try_current()
        .map_err(|_| "plugin HTTP call made outside the runtime".to_string())?
        .block_on(send(&request))
}

async fn send(request: &Request) -> Result<Response, String> {
    let timeout = request
        .timeout_seconds
        .map(|s| Duration::from_secs(u64::from(s)).min(PLUGIN_TIMEOUT))
        .unwrap_or(PLUGIN_TIMEOUT);

    let mut builder = CLIENT
        .request(request.method.clone(), &request.url)
        .timeout(timeout);
    let mut has_agent = false;
    for (name, value) in &request.headers {
        let name = HeaderName::from_bytes(name.as_bytes()).map_err(|e| e.to_string())?;
        let value = HeaderValue::from_str(value).map_err(|e| e.to_string())?;
        has_agent |= name == USER_AGENT;
        builder = builder.header(name, value);
    }
    if !has_agent {
        builder = builder.header(USER_AGENT, PLUGIN_USER_AGENT);
    }
    if let Some(body) = &request.body {
        builder = builder.body(body.clone());
    }

    let response = builder.send().await.map_err(|e| e.to_string())?;
    let status = response.status().as_u16();
    let headers = response
        .headers()
        .iter()
        .map(|(k, v)| (k.as_str().to_owned(), v.to_str().unwrap_or("").to_owned()))
        .collect();
    let body = response.bytes().await.map_err(|e| e.to_string())?.into();
    Ok(Response {
        status,
        headers,
        body,
    })
}
