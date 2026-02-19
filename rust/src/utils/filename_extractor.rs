use reqwest::Client;
use std::time::Duration;
use url::Url;

pub async fn extract_filename(
    url: &str,
) -> Result<String, Box<dyn std::error::Error + Send + Sync>> {
    let parsed_url = Url::parse(url)?;

    // 1. Check for "file" query parameter (fastest, no network request)
    if let Some(file_param) = parsed_url.query_pairs().find(|(k, _)| k == "file") {
        return Ok(file_param.1.to_string());
    }

    // 2. Make HEAD request to get Content-Disposition (safeguarded: only headers, no body download)
    // Industry standard: Use HEAD to avoid downloading large files
    // Safeguards: Timeout to prevent hanging, check response status
    static CLIENT: std::sync::OnceLock<Client> = std::sync::OnceLock::new();
    let client = CLIENT.get_or_init(|| {
        Client::builder()
            .timeout(Duration::from_secs(10)) // Prevent long waits
            .build()
            .expect("Failed to build HTTP client")
    });

    let response = client.head(url).send().await?;

    // Check if request was successful
    if !response.status().is_success() {
        return Err(format!("HTTP request failed with status: {}", response.status()).into());
    }

    // Optional: Check content-length to avoid potential issues with very large files (though HEAD doesn't download)
    if let Some(content_length) = response.content_length() {
        const MAX_SAFE_SIZE: u64 = 100 * 1024 * 1024; // 100MB threshold as example
        if content_length > MAX_SAFE_SIZE {
            eprintln!("Warning: Content-Length is large ({} bytes), but proceeding with header-only check", content_length);
        }
    }

    if let Some(content_disposition) = response.headers().get("content-disposition") {
        if let Ok(cd) = content_disposition.to_str() {
            if let Some(filename) = parse_content_disposition(cd) {
                return Ok(filename);
            }
        }
    }

    // 3. Fallback to URL path
    if let Some(path) = parsed_url.path_segments() {
        if let Some(last_segment) = path.last() {
            if !last_segment.is_empty() {
                return Ok(last_segment.to_string());
            }
        }
    }

    Err("No filename found in any method".into())
}

fn parse_content_disposition(header: &str) -> Option<String> {
    // Simple parser for Content-Disposition: attachment; filename="file.mp4"
    // Handles quoted and unquoted filenames
    if header.to_lowercase().contains("filename") {
        let parts: Vec<&str> = header.split(';').collect();
        for part in parts {
            let part = part.trim();
            if part.to_lowercase().starts_with("filename=") {
                let filename = part[9..].trim_matches('"').trim_matches('\'');
                // Basic validation: ensure it's not empty and doesn't contain path separators
                if !filename.is_empty() && !filename.contains('/') && !filename.contains('\\') {
                    return Some(filename.to_string());
                }
            }
        }
    }
    None
}
