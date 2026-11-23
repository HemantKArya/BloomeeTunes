//! Track matching across plugins: how closely a search result matches a
//! track we want (charts, imports, replacements, lyrics).
//!
//! Scores are identical to the former Dart implementation: text is compared
//! in UTF-16 code units with python-Levenshtein's ratio, partial ratio and
//! token sort ratio, and normalisation follows Dart's regular expressions
//! (JavaScript whitespace, ASCII word boundaries).

use flutter_rust_bridge::frb;

/// The parts of a track that matching looks at.
pub struct MatchTrack {
    pub title: String,
    pub artists: Vec<String>,
    pub album: Option<String>,
    pub duration_ms: Option<u64>,
}

/// Scores each candidate against `target`, in [0, 1].
#[frb(sync)]
pub fn score_tracks(target: MatchTrack, candidates: Vec<MatchTrack>) -> Vec<f64> {
    let target = Prepared::new(&target);
    candidates
        .iter()
        .map(|c| score(&target, &Prepared::new(c)))
        .collect()
}

/// True when titles match exactly (or after simplification) and the artists
/// agree closely.
#[frb(sync)]
pub fn is_strong_match(target: MatchTrack, candidate: MatchTrack) -> bool {
    strong(&Prepared::new(&target), &Prepared::new(&candidate))
}

/// Blend of ratio, partial ratio, token sort ratio and token overlap.
#[frb(sync)]
pub fn text_similarity(left: String, right: String) -> f64 {
    similarity(&Text::new(&left), &Text::new(&right))
}

/// Bidirectional best-match similarity of two artist name lists.
#[frb(sync)]
pub fn artist_similarity(left: Vec<String>, right: Vec<String>) -> f64 {
    artists_similarity(&Artists::new(&left), &Artists::new(&right))
}

#[frb(sync)]
pub fn duration_similarity(left: Option<u64>, right: Option<u64>) -> f64 {
    duration_score(left, right)
}

/// Lowercase, `&` as "and", ASCII punctuation as spaces, whitespace
/// collapsed. Keeps non-ASCII letters so international titles survive.
#[frb(sync)]
pub fn normalize_text(value: String) -> String {
    normalized(&value)
}

/// [normalize_text] plus parentheticals, "feat." credits and
/// version/edition words removed.
#[frb(sync)]
pub fn simplify_title(value: String) -> String {
    simplified(&value)
}

// ── Scoring ──────────────────────────────────────────────────────────────

/// A string prepared once for any number of comparisons.
struct Text {
    norm: String,
    units: Vec<u16>,
    sorted: Vec<u16>,
    tokens: Vec<String>,
}

impl Text {
    fn new(raw: &str) -> Self {
        let norm = normalized(raw);
        let mut tokens: Vec<String> = norm
            .split(' ')
            .filter(|t| !t.is_empty())
            .map(str::to_owned)
            .collect();
        tokens.sort_unstable();
        tokens.dedup();
        Self {
            units: utf16(&norm),
            sorted: utf16(&token_sort(&norm)),
            tokens,
            norm,
        }
    }
}

struct Artists {
    each: Vec<Text>,
    joined: Text,
}

impl Artists {
    fn new(names: &[String]) -> Self {
        let names: Vec<&str> = names
            .iter()
            .map(|n| dart_trim(n))
            .filter(|n| !n.is_empty())
            .collect();
        Self {
            each: names.iter().map(|n| Text::new(n)).collect(),
            joined: Text::new(&names.join(" ")),
        }
    }
}

struct Prepared<'a> {
    track: &'a MatchTrack,
    title: Text,
    simple: Text,
    album: Option<Text>,
    artists: Artists,
    artist_key: String,
    tags: Vec<&'static str>,
}

impl<'a> Prepared<'a> {
    fn new(track: &'a MatchTrack) -> Self {
        let album = track.album.as_deref().map(dart_trim).filter(|a| !a.is_empty());
        Self {
            track,
            title: Text::new(&track.title),
            simple: Text::new(&simplified(&track.title)),
            album: album.map(Text::new),
            artists: Artists::new(&track.artists),
            artist_key: artist_key(&track.artists),
            tags: version_tags(&join_non_empty(&[Some(&track.title), track.album.as_deref()])),
        }
    }
}

fn score(t: &Prepared, c: &Prepared) -> f64 {
    let dur = duration_score(t.track.duration_ms, c.track.duration_ms);
    let same_title = !t.title.norm.is_empty() && t.title.norm == c.title.norm;
    let same_artists = !t.artist_key.is_empty() && t.artist_key == c.artist_key;
    if same_title && same_artists {
        return (0.92 + dur * 0.08).clamp(0.0, 1.0);
    }

    let title_score = similarity(&t.title, &c.title);
    let simplified_score = similarity(&t.simple, &c.simple);
    let artist_score = artists_similarity(&t.artists, &c.artists);
    let (album_score, has_album) = match (&t.album, &c.album) {
        (Some(ta), Some(ca)) => (similarity(ta, ca), true),
        _ => (0.0, false),
    };

    let (w_title, w_simplified, w_artist, w_album) = if has_album {
        (0.32, 0.12, 0.28, 0.10)
    } else {
        (0.36, 0.14, 0.32, 0.00)
    };
    let mut score = title_score * w_title
        + simplified_score * w_simplified
        + artist_score * w_artist
        + album_score * w_album
        + dur * 0.13;

    if same_title {
        score += 0.06;
    }
    if !t.simple.norm.is_empty() && t.simple.norm == c.simple.norm {
        score += 0.04;
    }
    if same_artists {
        score += 0.05;
    }
    (score - version_penalty(&t.tags, &c.tags)).clamp(0.0, 1.0)
}

fn strong(t: &Prepared, c: &Prepared) -> bool {
    let title_match = (!t.title.norm.is_empty() && t.title.norm == c.title.norm)
        || (!t.simple.norm.is_empty() && t.simple.norm == c.simple.norm);
    if !title_match {
        return false;
    }
    if t.track.artists.is_empty() || c.artists.each.is_empty() {
        return true;
    }
    artists_similarity(&t.artists, &c.artists) >= 0.7
}

fn similarity(l: &Text, r: &Text) -> f64 {
    if l.norm.is_empty() || r.norm.is_empty() {
        return 0.0;
    }
    if l.norm == r.norm {
        return 1.0;
    }
    let direct = simple_ratio(&l.units, &r.units) as f64 / 100.0;
    let partial = partial_ratio(&l.units, &r.units) as f64 / 100.0;
    let sorted = simple_ratio(&l.sorted, &r.sorted) as f64 / 100.0;
    let overlap = token_overlap(&l.tokens, &r.tokens);
    (direct * 0.35 + partial * 0.20 + sorted * 0.25 + overlap * 0.20).clamp(0.0, 1.0)
}

/// F1 of the two token sets (both sorted and deduplicated).
fn token_overlap(left: &[String], right: &[String]) -> f64 {
    if left.is_empty() || right.is_empty() {
        return 0.0;
    }
    let (mut i, mut j, mut shared) = (0, 0, 0usize);
    while i < left.len() && j < right.len() {
        match left[i].cmp(&right[j]) {
            std::cmp::Ordering::Less => i += 1,
            std::cmp::Ordering::Greater => j += 1,
            std::cmp::Ordering::Equal => {
                shared += 1;
                i += 1;
                j += 1;
            }
        }
    }
    if shared == 0 {
        return 0.0;
    }
    let p = shared as f64 / right.len() as f64;
    let r = shared as f64 / left.len() as f64;
    (2.0 * p * r) / (p + r)
}

fn artists_similarity(left: &Artists, right: &Artists) -> f64 {
    // With one side empty the Dart version compared against an empty
    // string, which always scores 0.
    if left.each.is_empty() || right.each.is_empty() {
        return 0.0;
    }
    let best_sum = |from: &[Text], to: &[Text]| -> f64 {
        from.iter()
            .map(|n| to.iter().map(|o| similarity(n, o)).fold(0.0, f64::max))
            .sum()
    };
    let fwd = best_sum(&left.each, &right.each);
    let rev = best_sum(&right.each, &left.each);
    let combined = similarity(&left.joined, &right.joined);
    let primary_bonus = if similarity(&left.each[0], &right.each[0]) > 0.85 {
        0.05
    } else {
        0.0
    };
    ((fwd / left.each.len() as f64) * 0.35
        + (rev / right.each.len() as f64) * 0.30
        + combined * 0.25
        + primary_bonus)
        .clamp(0.0, 1.0)
}

fn duration_score(left: Option<u64>, right: Option<u64>) -> f64 {
    let (Some(l), Some(r)) = (left, right) else {
        return 0.35;
    };
    let (l, r) = (l as f64, r as f64);
    if l <= 0.0 || r <= 0.0 {
        return 0.35;
    }
    let diff = (l - r).abs();
    let rel = diff / l.max(r);
    let abs_score: f64 = match diff {
        d if d <= 1500.0 => 1.00,
        d if d <= 3000.0 => 0.85,
        d if d <= 5000.0 => 0.55,
        d if d <= 10000.0 => 0.25,
        d if d <= 20000.0 => 0.08,
        _ => 0.00,
    };
    let rel_score: f64 = match rel {
        e if e <= 0.02 => 1.00,
        e if e <= 0.05 => 0.85,
        e if e <= 0.10 => 0.55,
        e if e <= 0.20 => 0.25,
        e if e <= 0.35 => 0.08,
        _ => 0.00,
    };
    (abs_score * 0.50 + rel_score * 0.50).clamp(0.0, 1.0)
}

/// Missing version tags (live, remix, ...) hurt more than extra ones.
fn version_penalty(target: &[&str], candidate: &[&str]) -> f64 {
    if target.is_empty() && candidate.is_empty() {
        return 0.0;
    }
    let missing = target.iter().filter(|t| !candidate.contains(t)).count() as f64;
    let extra = candidate.iter().filter(|t| !target.contains(t)).count() as f64;
    (missing * 0.08 + extra * 0.04).clamp(0.0, 0.25)
}

fn version_tags(value: &str) -> Vec<&'static str> {
    let norm = collapse(&punct_to_space(&lowercase(value)));
    if norm.is_empty() {
        return Vec::new();
    }
    let words = ascii_words(&norm);
    let has = |w: &str| words.iter().any(|(_, x)| *x == w);
    let radio = words.windows(2).any(|pair| {
        let ((start, first), (next, second)) = (pair[0], pair[1]);
        first == "radio"
            && (second == "edit" || second == "version")
            && &norm[start + first.len()..next] == " "
    });
    let mut tags = Vec::new();
    for (tag, present) in [
        ("live", has("live")),
        ("acoustic", has("acoustic")),
        ("karaoke", has("karaoke")),
        ("instrumental", has("instrumental")),
        ("remix", has("remix") || has("mixed") || has("rmx")),
        ("remaster", has("remaster") || has("remastered")),
        ("clean", has("clean")),
        ("explicit", has("explicit")),
        ("demo", has("demo")),
        ("cover", has("cover")),
        ("radio", radio),
        ("extended", has("extended")),
        ("unplugged", has("unplugged")),
        ("stripped", has("stripped")),
    ] {
        if present {
            tags.push(tag);
        }
    }
    tags
}

fn artist_key(names: &[String]) -> String {
    let mut keys: Vec<String> = names
        .iter()
        .map(|n| normalized(n))
        .filter(|n| !n.is_empty())
        .collect();
    keys.sort_by(|a, b| a.encode_utf16().cmp(b.encode_utf16()));
    keys.join("|")
}



fn join_non_empty(parts: &[Option<&str>]) -> String {
    parts
        .iter()
        .map(|p| p.map(dart_trim).unwrap_or(""))
        .filter(|p| !p.is_empty())
        .collect::<Vec<_>>()
        .join(" ")
}

// ── Normalisation ────────────────────────────────────────────────────────

/// Character by character, like Dart's `toLowerCase` (no context rules
/// such as Greek final sigma).
fn lowercase(s: &str) -> String {
    s.chars().flat_map(char::to_lowercase).collect()
}

/// Dart `String.trim`: Unicode White_Space plus the byte order mark.
fn dart_trim(s: &str) -> &str {
    s.trim_matches(|c: char| c.is_whitespace() || c == '\u{feff}')
}

/// JavaScript `\s`, which Dart regular expressions use.
fn is_js_space(c: char) -> bool {
    matches!(
        c,
        '\t' | '\n' | '\u{b}' | '\u{c}' | '\r' | ' ' | '\u{a0}' | '\u{1680}'
            | '\u{2000}'..='\u{200a}' | '\u{2028}' | '\u{2029}' | '\u{202f}'
            | '\u{205f}' | '\u{3000}' | '\u{feff}'
    )
}

fn is_ascii_punct(c: char) -> bool {
    matches!(c, '\x21'..='\x2f' | '\x3a'..='\x40' | '\x5b'..='\x60' | '\x7b'..='\x7e')
}

fn punct_to_space(s: &str) -> String {
    s.chars().map(|c| if is_ascii_punct(c) { ' ' } else { c }).collect()
}

/// Runs of whitespace become one space, then the ends are trimmed.
fn collapse(s: &str) -> String {
    let mut out = String::with_capacity(s.len());
    let mut in_space = false;
    for c in s.chars() {
        if is_js_space(c) {
            if !in_space {
                out.push(' ');
            }
            in_space = true;
        } else {
            out.push(c);
            in_space = false;
        }
    }
    dart_trim(&out).to_owned()
}

fn normalized(value: &str) -> String {
    if dart_trim(value).is_empty() {
        return String::new();
    }
    let lower = lowercase(value).replace('&', " and ");
    collapse(&punct_to_space(&lower))
}

fn simplified(value: &str) -> String {
    if dart_trim(value).is_empty() {
        return String::new();
    }
    let mut s = lowercase(&without_parentheticals(dart_trim(value)));
    if let Some(start) = ascii_words(&s)
        .iter()
        .find(|(_, w)| matches!(*w, "feat" | "ft" | "featuring"))
        .map(|(start, _)| *start)
    {
        s.truncate(start);
    }
    let s = replace_words(&s, |w| {
        matches!(
            w,
            "remaster" | "remastered" | "version" | "edit" | "mix" | "remix" | "single"
                | "album" | "deluxe" | "edition" | "bonus"
        )
    });
    collapse(&punct_to_space(&s))
}

/// Removes `(...)` groups, each up to its first `)`, as `\(.*?\)` does.
fn without_parentheticals(s: &str) -> String {
    let mut out = String::with_capacity(s.len());
    let mut rest = s;
    while let Some(open) = rest.find('(') {
        let after = &rest[open + 1..];
        let close = after
            .char_indices()
            .take_while(|(_, c)| !matches!(c, '\n' | '\r' | '\u{2028}' | '\u{2029}'))
            .find(|(_, c)| *c == ')')
            .map(|(i, _)| i);
        match close {
            Some(close) => {
                out.push_str(&rest[..open]);
                out.push(' ');
                rest = &after[close + 1..];
            }
            None => {
                out.push_str(&rest[..open + 1]);
                rest = after;
            }
        }
    }
    out.push_str(rest);
    out
}

fn is_ascii_word(c: char) -> bool {
    c.is_ascii_alphanumeric() || c == '_'
}

/// Maximal runs of ASCII word characters with their byte offsets: exactly
/// the spans `\bword\b` can match in a Dart regular expression.
fn ascii_words(s: &str) -> Vec<(usize, &str)> {
    let mut words = Vec::new();
    let mut start = None;
    for (i, c) in s.char_indices() {
        match (is_ascii_word(c), start) {
            (true, None) => start = Some(i),
            (false, Some(st)) => {
                words.push((st, &s[st..i]));
                start = None;
            }
            _ => {}
        }
    }
    if let Some(st) = start {
        words.push((st, &s[st..]));
    }
    words
}

fn replace_words(s: &str, matches: impl Fn(&str) -> bool) -> String {
    let mut out = String::with_capacity(s.len());
    let mut last = 0;
    for (start, word) in ascii_words(s) {
        if matches(word) {
            out.push_str(&s[last..start]);
            out.push(' ');
            last = start + word.len();
        }
    }
    out.push_str(&s[last..]);
    out
}

/// fuzzywuzzy's token sort: words sorted in UTF-16 order.
fn token_sort(s: &str) -> String {
    let mut words: Vec<&str> = s.split(|c: char| is_js_space(c)).collect();
    words.sort_by(|a, b| a.encode_utf16().cmp(b.encode_utf16()));
    dart_trim(&words.join(" ")).to_owned()
}

// ── python-Levenshtein ratios on UTF-16 code units ───────────────────────

fn utf16(s: &str) -> Vec<u16> {
    s.encode_utf16().collect()
}

fn simple_ratio(a: &[u16], b: &[u16]) -> i64 {
    let r = ratio(a, b);
    if r.is_nan() { 0 } else { (r * 100.0).round() as i64 }
}

/// (len1 + len2 - indel distance) / (len1 + len2).
fn ratio(a: &[u16], b: &[u16]) -> f64 {
    let sum = a.len() + b.len();
    (sum - indel_distance(a, b)) as f64 / sum as f64
}

fn indel_distance(a: &[u16], b: &[u16]) -> usize {
    a.len() + b.len() - 2 * lcs(a, b)
}

/// Longest common subsequence length; bit-parallel when the shorter side
/// fits in a machine word (all realistic titles), plain DP otherwise.
fn lcs(a: &[u16], b: &[u16]) -> usize {
    let (short, long) = if a.len() <= b.len() { (a, b) } else { (b, a) };
    if short.is_empty() {
        return 0;
    }
    if short.len() <= 64 {
        let mut ascii = [0u64; 128];
        let mut other: Vec<(u16, u64)> = Vec::new();
        for (i, &c) in short.iter().enumerate() {
            if c < 128 {
                ascii[c as usize] |= 1 << i;
            } else if let Some(slot) = other.iter_mut().find(|(k, _)| *k == c) {
                slot.1 |= 1 << i;
            } else {
                other.push((c, 1 << i));
            }
        }
        let mut v: u64 = !0;
        for &c in long {
            let m = if c < 128 {
                ascii[c as usize]
            } else {
                other.iter().find(|(k, _)| *k == c).map_or(0, |(_, m)| *m)
            };
            v = v.wrapping_add(v & m) | (v & !m);
        }
        let used = if short.len() == 64 { !0 } else { (1u64 << short.len()) - 1 };
        return (!v & used).count_ones() as usize;
    }
    let mut row = vec![0usize; short.len() + 1];
    for &c in long {
        let mut prev_diag = 0;
        for j in 0..short.len() {
            let above = row[j + 1];
            row[j + 1] = if short[j] == c { prev_diag + 1 } else { above.max(row[j]) };
            prev_diag = above;
        }
    }
    row[short.len()]
}

fn partial_ratio(a: &[u16], b: &[u16]) -> i64 {
    let (shorter, longer) = if a.len() < b.len() { (a, b) } else { (b, a) };
    let mut best: Option<f64> = None;
    for (spos, dpos) in matching_blocks(shorter, longer) {
        let start = dpos.saturating_sub(spos);
        let end = (start + shorter.len()).min(longer.len());
        let r = ratio(shorter, &longer[start..end]);
        if r.is_nan() {
            continue;
        }
        if r > 0.995 {
            return 100;
        }
        best = Some(best.map_or(r, |b| b.max(r)));
    }
    best.map_or(0, |b| (100.0 * b).round() as i64)
}

#[derive(Clone, Copy, PartialEq)]
enum Op {
    Replace,
    Insert,
    Delete,
}

/// Levenshtein edit operations, walked back through the cost matrix with
/// python-Levenshtein's tie-breaking so the matching blocks agree.
fn edit_ops(c1: &[u16], c2: &[u16]) -> Vec<(Op, usize, usize)> {
    let (mut len1, mut len2) = (c1.len(), c2.len());
    let mut p = 0;
    while len1 > 0 && len2 > 0 && c1[p] == c2[p] {
        len1 -= 1;
        len2 -= 1;
        p += 1;
    }
    let offset = p;
    while len1 > 0 && len2 > 0 && c1[p + len1 - 1] == c2[p + len2 - 1] {
        len1 -= 1;
        len2 -= 1;
    }
    let (len1, len2) = (len1 + 1, len2 + 1);
    let mut m = vec![0usize; len1 * len2];
    for (i, cell) in m.iter_mut().enumerate().take(len2) {
        *cell = i;
    }
    for i in 1..len1 {
        m[len2 * i] = i;
    }
    for i in 1..len1 {
        let ch1 = c1[p + i - 1];
        let mut x = i;
        for j in 1..len2 {
            let diag = m[(i - 1) * len2 + j - 1] + usize::from(ch1 != c2[p + j - 1]);
            x += 1;
            x = x.min(diag);
            x = x.min(m[(i - 1) * len2 + j] + 1);
            m[i * len2 + j] = x;
        }
    }

    let mut ops = Vec::with_capacity(m[len1 * len2 - 1]);
    let (mut i, mut j) = (len1 - 1, len2 - 1);
    let mut ptr = len1 * len2 - 1;
    let mut dir = 0i8;
    while i > 0 || j > 0 {
        if i != 0 && j != 0 && m[ptr] == m[ptr - len2 - 1] && c1[p + i - 1] == c2[p + j - 1] {
            i -= 1;
            j -= 1;
            ptr -= len2 + 1;
            dir = 0;
        } else if dir < 0 && j != 0 && m[ptr] == m[ptr - 1] + 1 {
            j -= 1;
            ops.push((Op::Insert, i + offset, j + offset));
            ptr -= 1;
        } else if dir > 0 && i != 0 && m[ptr] == m[ptr - len2] + 1 {
            i -= 1;
            ops.push((Op::Delete, i + offset, j + offset));
            ptr -= len2;
        } else if i != 0 && j != 0 && m[ptr] == m[ptr - len2 - 1] + 1 {
            i -= 1;
            j -= 1;
            ops.push((Op::Replace, i + offset, j + offset));
            ptr -= len2 + 1;
            dir = 0;
        } else if dir == 0 && j != 0 && m[ptr] == m[ptr - 1] + 1 {
            j -= 1;
            ops.push((Op::Insert, i + offset, j + offset));
            ptr -= 1;
            dir = -1;
        } else if dir == 0 && i != 0 && m[ptr] == m[ptr - len2] + 1 {
            i -= 1;
            ops.push((Op::Delete, i + offset, j + offset));
            ptr -= len2;
            dir = 1;
        } else {
            unreachable!("Levenshtein matrix walk lost its path");
        }
    }
    ops.reverse();
    ops
}

/// Starts (in each string) of the runs both strings share, in order.
fn matching_blocks(c1: &[u16], c2: &[u16]) -> Vec<(usize, usize)> {
    let ops = edit_ops(c1, c2);
    let mut blocks = Vec::new();
    let (mut spos, mut dpos) = (0, 0);
    let mut o = 0;
    while o < ops.len() {
        let (kind, s, d) = ops[o];
        if spos < s || dpos < d {
            blocks.push((spos, dpos));
            spos = s;
            dpos = d;
        }
        loop {
            match kind {
                Op::Replace => {
                    spos += 1;
                    dpos += 1;
                }
                Op::Delete => spos += 1,
                Op::Insert => dpos += 1,
            }
            o += 1;
            if o >= ops.len() {
                break;
            }
            let (next, s, d) = ops[o];
            if next != kind || spos != s || dpos != d {
                break;
            }
        }
    }
    if spos < c1.len() || dpos < c2.len() {
        blocks.push((spos, dpos));
    }
    blocks.push((c1.len(), c2.len()));
    blocks
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::Value;

    fn track(v: &Value) -> MatchTrack {
        MatchTrack {
            title: v[0].as_str().unwrap().to_owned(),
            artists: v[1]
                .as_array()
                .unwrap()
                .iter()
                .map(|a| a.as_str().unwrap().to_owned())
                .collect(),
            album: v[2].as_str().map(str::to_owned),
            duration_ms: v[3].as_u64(),
        }
    }

    /// Dart's own results differ in the last bit between its JIT tiers, so
    /// scores are compared to 1e-9; strings and decisions must be exact.
    fn close(got: f64, want: &Value, what: &str) {
        let want = want.as_f64().unwrap();
        assert!((got - want).abs() < 1e-9, "{what}: got {got}, Dart {want}");
    }

    #[test]
    fn matches_the_dart_scores() {
        let fixture: Value = serde_json::from_str(include_str!(
            "../../tests/fixtures/match_scores.json"
        ))
        .unwrap();

        for pair in fixture["normalized"].as_array().unwrap() {
            assert_eq!(normalized(pair[0].as_str().unwrap()), pair[1], "normalize {pair}");
        }
        for pair in fixture["simplified"].as_array().unwrap() {
            assert_eq!(simplified(pair[0].as_str().unwrap()), pair[1], "simplify {pair}");
        }
        for row in fixture["text"].as_array().unwrap() {
            let got = similarity(
                &Text::new(row[0].as_str().unwrap()),
                &Text::new(row[1].as_str().unwrap()),
            );
            close(got, &row[2], &format!("text {row}"));
        }
        for row in fixture["tracks"].as_array().unwrap() {
            let (t, c) = (track(&row[0]), track(&row[1]));
            let what = format!("{row}");
            close(score(&Prepared::new(&t), &Prepared::new(&c)), &row[2], &what);
            close(
                artists_similarity(&Artists::new(&t.artists), &Artists::new(&c.artists)),
                &row[4],
                &what,
            );
            close(duration_score(t.duration_ms, c.duration_ms), &row[5], &what);
            close(
                version_penalty(&Prepared::new(&t).tags, &Prepared::new(&c).tags),
                &row[6],
                &what,
            );
            assert_eq!(is_strong_match(t, c), row[3].as_bool().unwrap(), "strong {row}");
        }
    }

    #[test]
    #[ignore]
    fn bench_scoring() {
        let fixture: Value = serde_json::from_str(include_str!(
            "../../tests/fixtures/match_scores.json"
        ))
        .unwrap();
        let rows: Vec<(MatchTrack, MatchTrack)> = fixture["tracks"]
            .as_array()
            .unwrap()
            .iter()
            .map(|row| (track(&row[0]), track(&row[1])))
            .collect();
        let start = std::time::Instant::now();
        let mut calls = 0;
        for _ in 0..20 {
            for (t, c) in &rows {
                let (t, c) = (Prepared::new(t), Prepared::new(c));
                std::hint::black_box(score(&t, &c));
                std::hint::black_box(strong(&t, &c));
                calls += 1;
            }
        }
        let us = start.elapsed().as_secs_f64() * 1e6;
        println!("Rust: {calls} score+strong in {us:.0} us ({:.2} us each)", us / calls as f64);
    }
}
