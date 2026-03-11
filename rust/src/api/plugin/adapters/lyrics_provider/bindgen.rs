// AUTO-GENERATED WIT BINDINGS for wasm-component-layer
// DO NOT EDIT - Regenerate using wit-bindgen-wcl

#![allow(dead_code, unused_imports, unused_variables, ambiguous_glob_reexports)]

use anyhow::*;
use waclay::*;
use wasm_runtime_layer::{backend};


// ========== Type Definitions ==========

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum HttpMethod {
    Get,
    Post,
    Put,
    Delete,
    Head,
    Patch,
    Options,
}

impl ComponentType for HttpMethod {
    fn ty() -> ValueType {
        ValueType::Enum(EnumType::new(None, [
            "get",
            "post",
            "put",
            "delete",
            "head",
            "patch",
            "options",
        ]).unwrap())
    }

    fn from_value(value: &Value) -> Result<Self> {
        if let Value::Enum(enum_val) = value {
            let discriminant = enum_val.discriminant();
            match discriminant {
                0 => Ok(HttpMethod::Get),
                1 => Ok(HttpMethod::Post),
                2 => Ok(HttpMethod::Put),
                3 => Ok(HttpMethod::Delete),
                4 => Ok(HttpMethod::Head),
                5 => Ok(HttpMethod::Patch),
                6 => Ok(HttpMethod::Options),
                _ => bail!("Invalid enum discriminant: {}", discriminant),
            }
        } else {
            bail!("Expected Enum value")
        }
    }

    fn into_value(self) -> Result<Value> {
        let enum_type = EnumType::new(None, [
            "get",
            "post",
            "put",
            "delete",
            "head",
            "patch",
            "options",
        ]).unwrap();

        let discriminant = match self {
            HttpMethod::Get => 0,
            HttpMethod::Post => 1,
            HttpMethod::Put => 2,
            HttpMethod::Delete => 3,
            HttpMethod::Head => 4,
            HttpMethod::Patch => 5,
            HttpMethod::Options => 6,
        };

        Ok(Value::Enum(Enum::new(enum_type, discriminant)?))
    }
}

impl UnaryComponentType for HttpMethod {}




#[derive(Debug, Clone)]
pub struct HttpResponse {
    pub status: u16,
    pub headers: Vec<(String, String)>,
    pub body: Vec<u8>,
}

impl ComponentType for HttpResponse {
    fn ty() -> ValueType {
        ValueType::Record(
            RecordType::new(
                None,
                [
                    ("status", ValueType::U16),
                    ("headers", ValueType::List(ListType::new(ValueType::Tuple(TupleType::new(None, [ValueType::String, ValueType::String]))))),
                    ("body", ValueType::List(ListType::new(ValueType::U8))),
                ],
            ).unwrap(),
        )
    }

    fn from_value(value: &Value) -> Result<Self> {
        if let Value::Record(record) = value {
            let status = record
                .field("status")
                .ok_or_else(|| anyhow!("Missing 'status' field"))?;
            let headers = record
                .field("headers")
                .ok_or_else(|| anyhow!("Missing 'headers' field"))?;
            let body = record
                .field("body")
                .ok_or_else(|| anyhow!("Missing 'body' field"))?;

            let status = if let Value::U16(x) = status { x } else { bail!("Expected u16") };
            let headers = Vec::<(String, String)>::from_value(&headers)?;
            let body = Vec::<u8>::from_value(&body)?;

            Ok(HttpResponse {
                status,
                headers,
                body,
            })
        } else {
            bail!("Expected Record value")
        }
    }

    fn into_value(self) -> Result<Value> {
        let record = Record::new(
            RecordType::new(
                None,
                [
                    ("status", ValueType::U16),
                    ("headers", ValueType::List(ListType::new(ValueType::Tuple(TupleType::new(None, [ValueType::String, ValueType::String]))))),
                    ("body", ValueType::List(ListType::new(ValueType::U8))),
                ],
            ).unwrap(),
            [
                ("status", Value::U16(self.status)),
                ("headers", self.headers.into_value()?),
                ("body", self.body.into_value()?),
            ],
        )?;
        Ok(Value::Record(record))
    }
}

impl UnaryComponentType for HttpResponse {}




#[derive(Debug, Clone)]
pub struct RequestOptions {
    pub method: HttpMethod,
    pub headers: Option<Vec<(String, String)>>,
    pub body: Option<Vec<u8>>,
    pub timeout_seconds: Option<u32>,
}

impl ComponentType for RequestOptions {
    fn ty() -> ValueType {
        ValueType::Record(
            RecordType::new(
                None,
                [
                    ("method", HttpMethod::ty()),
                    ("headers", ValueType::Option(OptionType::new(ValueType::List(ListType::new(ValueType::Tuple(TupleType::new(None, [ValueType::String, ValueType::String]))))))),
                    ("body", ValueType::Option(OptionType::new(ValueType::List(ListType::new(ValueType::U8))))),
                    ("timeout-seconds", ValueType::Option(OptionType::new(ValueType::U32))),
                ],
            ).unwrap(),
        )
    }

    fn from_value(value: &Value) -> Result<Self> {
        if let Value::Record(record) = value {
            let method = record
                .field("method")
                .ok_or_else(|| anyhow!("Missing 'method' field"))?;
            let headers = record
                .field("headers")
                .ok_or_else(|| anyhow!("Missing 'headers' field"))?;
            let body = record
                .field("body")
                .ok_or_else(|| anyhow!("Missing 'body' field"))?;
            let timeout_seconds = record
                .field("timeout-seconds")
                .ok_or_else(|| anyhow!("Missing 'timeout-seconds' field"))?;

            let method = HttpMethod::from_value(&method)?;
            let headers = Option::<Vec::<(String, String)>>::from_value(&headers)?;
            let body = Option::<Vec::<u8>>::from_value(&body)?;
            let timeout_seconds = Option::<u32>::from_value(&timeout_seconds)?;

            Ok(RequestOptions {
                method,
                headers,
                body,
                timeout_seconds,
            })
        } else {
            bail!("Expected Record value")
        }
    }

    fn into_value(self) -> Result<Value> {
        let record = Record::new(
            RecordType::new(
                None,
                [
                    ("method", HttpMethod::ty()),
                    ("headers", ValueType::Option(OptionType::new(ValueType::List(ListType::new(ValueType::Tuple(TupleType::new(None, [ValueType::String, ValueType::String]))))))),
                    ("body", ValueType::Option(OptionType::new(ValueType::List(ListType::new(ValueType::U8))))),
                    ("timeout-seconds", ValueType::Option(OptionType::new(ValueType::U32))),
                ],
            ).unwrap(),
            [
                ("method", self.method.into_value()?),
                ("headers", self.headers.into_value()?),
                ("body", self.body.into_value()?),
                ("timeout-seconds", self.timeout_seconds.into_value()?),
            ],
        )?;
        Ok(Value::Record(record))
    }
}

impl UnaryComponentType for RequestOptions {}



#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum LyricsSyncType {
    None,
    Line,
    Syllable,
}

impl ComponentType for LyricsSyncType {
    fn ty() -> ValueType {
        ValueType::Enum(EnumType::new(None, [
            "none",
            "line",
            "syllable",
        ]).unwrap())
    }

    fn from_value(value: &Value) -> Result<Self> {
        if let Value::Enum(enum_val) = value {
            let discriminant = enum_val.discriminant();
            match discriminant {
                0 => Ok(LyricsSyncType::None),
                1 => Ok(LyricsSyncType::Line),
                2 => Ok(LyricsSyncType::Syllable),
                _ => bail!("Invalid enum discriminant: {}", discriminant),
            }
        } else {
            bail!("Expected Enum value")
        }
    }

    fn into_value(self) -> Result<Value> {
        let enum_type = EnumType::new(None, [
            "none",
            "line",
            "syllable",
        ]).unwrap();

        let discriminant = match self {
            LyricsSyncType::None => 0,
            LyricsSyncType::Line => 1,
            LyricsSyncType::Syllable => 2,
        };

        Ok(Value::Enum(Enum::new(enum_type, discriminant)?))
    }
}

impl UnaryComponentType for LyricsSyncType {}

#[derive(Debug, Clone)]
pub struct LyricsToken {
    pub offset_ms: u32,
    pub text: String,
}

impl ComponentType for LyricsToken {
    fn ty() -> ValueType {
        ValueType::Record(
            RecordType::new(
                None,
                [
                    ("offset-ms", ValueType::U32),
                    ("text", ValueType::String),
                ],
            ).unwrap(),
        )
    }

    fn from_value(value: &Value) -> Result<Self> {
        if let Value::Record(record) = value {
            let offset_ms = record
                .field("offset-ms")
                .ok_or_else(|| anyhow!("Missing 'offset-ms' field"))?;
            let text = record
                .field("text")
                .ok_or_else(|| anyhow!("Missing 'text' field"))?;

            let offset_ms = if let Value::U32(x) = offset_ms { x } else { bail!("Expected u32") };
            let text = if let Value::String(s) = text { s.to_string() } else { bail!("Expected string") };

            Ok(LyricsToken {
                offset_ms,
                text,
            })
        } else {
            bail!("Expected Record value")
        }
    }

    fn into_value(self) -> Result<Value> {
        let record = Record::new(
            RecordType::new(
                None,
                [
                    ("offset-ms", ValueType::U32),
                    ("text", ValueType::String),
                ],
            ).unwrap(),
            [
                ("offset-ms", Value::U32(self.offset_ms)),
                ("text", Value::String(self.text.into())),
            ],
        )?;
        Ok(Value::Record(record))
    }
}

impl UnaryComponentType for LyricsToken {}



#[derive(Debug, Clone)]
pub struct LyricsLine {
    pub start_ms: u32,
    pub duration_ms: Option<u32>,
    pub content: String,
    pub tokens: Option<Vec<LyricsToken>>,
}

impl ComponentType for LyricsLine {
    fn ty() -> ValueType {
        ValueType::Record(
            RecordType::new(
                None,
                [
                    ("start-ms", ValueType::U32),
                    ("duration-ms", ValueType::Option(OptionType::new(ValueType::U32))),
                    ("content", ValueType::String),
                    ("tokens", ValueType::Option(OptionType::new(ValueType::List(ListType::new(LyricsToken::ty()))))),
                ],
            ).unwrap(),
        )
    }

    fn from_value(value: &Value) -> Result<Self> {
        if let Value::Record(record) = value {
            let start_ms = record
                .field("start-ms")
                .ok_or_else(|| anyhow!("Missing 'start-ms' field"))?;
            let duration_ms = record
                .field("duration-ms")
                .ok_or_else(|| anyhow!("Missing 'duration-ms' field"))?;
            let content = record
                .field("content")
                .ok_or_else(|| anyhow!("Missing 'content' field"))?;
            let tokens = record
                .field("tokens")
                .ok_or_else(|| anyhow!("Missing 'tokens' field"))?;

            let start_ms = if let Value::U32(x) = start_ms { x } else { bail!("Expected u32") };
            let duration_ms = Option::<u32>::from_value(&duration_ms)?;
            let content = if let Value::String(s) = content { s.to_string() } else { bail!("Expected string") };
            let tokens = Option::<Vec::<LyricsToken>>::from_value(&tokens)?;

            Ok(LyricsLine {
                start_ms,
                duration_ms,
                content,
                tokens,
            })
        } else {
            bail!("Expected Record value")
        }
    }

    fn into_value(self) -> Result<Value> {
        let record = Record::new(
            RecordType::new(
                None,
                [
                    ("start-ms", ValueType::U32),
                    ("duration-ms", ValueType::Option(OptionType::new(ValueType::U32))),
                    ("content", ValueType::String),
                    ("tokens", ValueType::Option(OptionType::new(ValueType::List(ListType::new(LyricsToken::ty()))))),
                ],
            ).unwrap(),
            [
                ("start-ms", Value::U32(self.start_ms)),
                ("duration-ms", self.duration_ms.into_value()?),
                ("content", Value::String(self.content.into())),
                ("tokens", self.tokens.into_value()?),
            ],
        )?;
        Ok(Value::Record(record))
    }
}

impl UnaryComponentType for LyricsLine {}



#[derive(Debug, Clone)]
pub struct Lyrics {
    pub plain: Option<String>,
    pub lrc: Option<String>,
    pub lines: Option<Vec<LyricsLine>>,
    pub is_instrumental: bool,
    pub sync_type: LyricsSyncType,
}

impl ComponentType for Lyrics {
    fn ty() -> ValueType {
        ValueType::Record(
            RecordType::new(
                None,
                [
                    ("plain", ValueType::Option(OptionType::new(ValueType::String))),
                    ("lrc", ValueType::Option(OptionType::new(ValueType::String))),
                    ("lines", ValueType::Option(OptionType::new(ValueType::List(ListType::new(LyricsLine::ty()))))),
                    ("is-instrumental", ValueType::Bool),
                    ("sync-type", LyricsSyncType::ty()),
                ],
            ).unwrap(),
        )
    }

    fn from_value(value: &Value) -> Result<Self> {
        if let Value::Record(record) = value {
            let plain = record
                .field("plain")
                .ok_or_else(|| anyhow!("Missing 'plain' field"))?;
            let lrc = record
                .field("lrc")
                .ok_or_else(|| anyhow!("Missing 'lrc' field"))?;
            let lines = record
                .field("lines")
                .ok_or_else(|| anyhow!("Missing 'lines' field"))?;
            let is_instrumental = record
                .field("is-instrumental")
                .ok_or_else(|| anyhow!("Missing 'is-instrumental' field"))?;
            let sync_type = record
                .field("sync-type")
                .ok_or_else(|| anyhow!("Missing 'sync-type' field"))?;

            let plain = Option::<String>::from_value(&plain)?;
            let lrc = Option::<String>::from_value(&lrc)?;
            let lines = Option::<Vec::<LyricsLine>>::from_value(&lines)?;
            let is_instrumental = if let Value::Bool(x) = is_instrumental { x } else { bail!("Expected bool") };
            let sync_type = LyricsSyncType::from_value(&sync_type)?;

            Ok(Lyrics {
                plain,
                lrc,
                lines,
                is_instrumental,
                sync_type,
            })
        } else {
            bail!("Expected Record value")
        }
    }

    fn into_value(self) -> Result<Value> {
        let record = Record::new(
            RecordType::new(
                None,
                [
                    ("plain", ValueType::Option(OptionType::new(ValueType::String))),
                    ("lrc", ValueType::Option(OptionType::new(ValueType::String))),
                    ("lines", ValueType::Option(OptionType::new(ValueType::List(ListType::new(LyricsLine::ty()))))),
                    ("is-instrumental", ValueType::Bool),
                    ("sync-type", LyricsSyncType::ty()),
                ],
            ).unwrap(),
            [
                ("plain", self.plain.into_value()?),
                ("lrc", self.lrc.into_value()?),
                ("lines", self.lines.into_value()?),
                ("is-instrumental", Value::Bool(self.is_instrumental)),
                ("sync-type", self.sync_type.into_value()?),
            ],
        )?;
        Ok(Value::Record(record))
    }
}

impl UnaryComponentType for Lyrics {}

#[derive(Debug, Clone)]
pub struct LyricsMetadata {
    pub source: Option<String>,
    pub author: Option<String>,
    pub language: Option<String>,
    pub copyright: Option<String>,
    pub is_verified: bool,
}

impl ComponentType for LyricsMetadata {
    fn ty() -> ValueType {
        ValueType::Record(
            RecordType::new(
                None,
                [
                    ("source", ValueType::Option(OptionType::new(ValueType::String))),
                    ("author", ValueType::Option(OptionType::new(ValueType::String))),
                    ("language", ValueType::Option(OptionType::new(ValueType::String))),
                    ("copyright", ValueType::Option(OptionType::new(ValueType::String))),
                    ("is-verified", ValueType::Bool),
                ],
            ).unwrap(),
        )
    }

    fn from_value(value: &Value) -> Result<Self> {
        if let Value::Record(record) = value {
            let source = record
                .field("source")
                .ok_or_else(|| anyhow!("Missing 'source' field"))?;
            let author = record
                .field("author")
                .ok_or_else(|| anyhow!("Missing 'author' field"))?;
            let language = record
                .field("language")
                .ok_or_else(|| anyhow!("Missing 'language' field"))?;
            let copyright = record
                .field("copyright")
                .ok_or_else(|| anyhow!("Missing 'copyright' field"))?;
            let is_verified = record
                .field("is-verified")
                .ok_or_else(|| anyhow!("Missing 'is-verified' field"))?;

            let source = Option::<String>::from_value(&source)?;
            let author = Option::<String>::from_value(&author)?;
            let language = Option::<String>::from_value(&language)?;
            let copyright = Option::<String>::from_value(&copyright)?;
            let is_verified = if let Value::Bool(x) = is_verified { x } else { bail!("Expected bool") };

            Ok(LyricsMetadata {
                source,
                author,
                language,
                copyright,
                is_verified,
            })
        } else {
            bail!("Expected Record value")
        }
    }

    fn into_value(self) -> Result<Value> {
        let record = Record::new(
            RecordType::new(
                None,
                [
                    ("source", ValueType::Option(OptionType::new(ValueType::String))),
                    ("author", ValueType::Option(OptionType::new(ValueType::String))),
                    ("language", ValueType::Option(OptionType::new(ValueType::String))),
                    ("copyright", ValueType::Option(OptionType::new(ValueType::String))),
                    ("is-verified", ValueType::Bool),
                ],
            ).unwrap(),
            [
                ("source", self.source.into_value()?),
                ("author", self.author.into_value()?),
                ("language", self.language.into_value()?),
                ("copyright", self.copyright.into_value()?),
                ("is-verified", Value::Bool(self.is_verified)),
            ],
        )?;
        Ok(Value::Record(record))
    }
}

impl UnaryComponentType for LyricsMetadata {}


#[derive(Debug, Clone)]
pub struct TrackMetadata {
    pub title: String,
    pub artist: String,
    pub album: Option<String>,
    pub duration_ms: Option<u64>,
}

impl ComponentType for TrackMetadata {
    fn ty() -> ValueType {
        ValueType::Record(
            RecordType::new(
                None,
                [
                    ("title", ValueType::String),
                    ("artist", ValueType::String),
                    ("album", ValueType::Option(OptionType::new(ValueType::String))),
                    ("duration-ms", ValueType::Option(OptionType::new(ValueType::U64))),
                ],
            ).unwrap(),
        )
    }

    fn from_value(value: &Value) -> Result<Self> {
        if let Value::Record(record) = value {
            let title = record
                .field("title")
                .ok_or_else(|| anyhow!("Missing 'title' field"))?;
            let artist = record
                .field("artist")
                .ok_or_else(|| anyhow!("Missing 'artist' field"))?;
            let album = record
                .field("album")
                .ok_or_else(|| anyhow!("Missing 'album' field"))?;
            let duration_ms = record
                .field("duration-ms")
                .ok_or_else(|| anyhow!("Missing 'duration-ms' field"))?;

            let title = if let Value::String(s) = title { s.to_string() } else { bail!("Expected string") };
            let artist = if let Value::String(s) = artist { s.to_string() } else { bail!("Expected string") };
            let album = Option::<String>::from_value(&album)?;
            let duration_ms = Option::<u64>::from_value(&duration_ms)?;

            Ok(TrackMetadata {
                title,
                artist,
                album,
                duration_ms,
            })
        } else {
            bail!("Expected Record value")
        }
    }

    fn into_value(self) -> Result<Value> {
        let record = Record::new(
            RecordType::new(
                None,
                [
                    ("title", ValueType::String),
                    ("artist", ValueType::String),
                    ("album", ValueType::Option(OptionType::new(ValueType::String))),
                    ("duration-ms", ValueType::Option(OptionType::new(ValueType::U64))),
                ],
            ).unwrap(),
            [
                ("title", Value::String(self.title.into())),
                ("artist", Value::String(self.artist.into())),
                ("album", self.album.into_value()?),
                ("duration-ms", self.duration_ms.into_value()?),
            ],
        )?;
        Ok(Value::Record(record))
    }
}

impl UnaryComponentType for TrackMetadata {}

#[derive(Debug, Clone)]
pub struct LyricsMatch {
    pub id: String,
    pub title: String,
    pub artist: String,
    pub album: Option<String>,
    pub duration_ms: Option<u64>,
    pub sync_type: LyricsSyncType,
}

impl ComponentType for LyricsMatch {
    fn ty() -> ValueType {
        ValueType::Record(
            RecordType::new(
                None,
                [
                    ("id", ValueType::String),
                    ("title", ValueType::String),
                    ("artist", ValueType::String),
                    ("album", ValueType::Option(OptionType::new(ValueType::String))),
                    ("duration-ms", ValueType::Option(OptionType::new(ValueType::U64))),
                    ("sync-type", LyricsSyncType::ty()),
                ],
            ).unwrap(),
        )
    }

    fn from_value(value: &Value) -> Result<Self> {
        if let Value::Record(record) = value {
            let id = record
                .field("id")
                .ok_or_else(|| anyhow!("Missing 'id' field"))?;
            let title = record
                .field("title")
                .ok_or_else(|| anyhow!("Missing 'title' field"))?;
            let artist = record
                .field("artist")
                .ok_or_else(|| anyhow!("Missing 'artist' field"))?;
            let album = record
                .field("album")
                .ok_or_else(|| anyhow!("Missing 'album' field"))?;
            let duration_ms = record
                .field("duration-ms")
                .ok_or_else(|| anyhow!("Missing 'duration-ms' field"))?;
            let sync_type = record
                .field("sync-type")
                .ok_or_else(|| anyhow!("Missing 'sync-type' field"))?;

            let id = if let Value::String(s) = id { s.to_string() } else { bail!("Expected string") };
            let title = if let Value::String(s) = title { s.to_string() } else { bail!("Expected string") };
            let artist = if let Value::String(s) = artist { s.to_string() } else { bail!("Expected string") };
            let album = Option::<String>::from_value(&album)?;
            let duration_ms = Option::<u64>::from_value(&duration_ms)?;
            let sync_type = LyricsSyncType::from_value(&sync_type)?;

            Ok(LyricsMatch {
                id,
                title,
                artist,
                album,
                duration_ms,
                sync_type,
            })
        } else {
            bail!("Expected Record value")
        }
    }

    fn into_value(self) -> Result<Value> {
        let record = Record::new(
            RecordType::new(
                None,
                [
                    ("id", ValueType::String),
                    ("title", ValueType::String),
                    ("artist", ValueType::String),
                    ("album", ValueType::Option(OptionType::new(ValueType::String))),
                    ("duration-ms", ValueType::Option(OptionType::new(ValueType::U64))),
                    ("sync-type", LyricsSyncType::ty()),
                ],
            ).unwrap(),
            [
                ("id", Value::String(self.id.into())),
                ("title", Value::String(self.title.into())),
                ("artist", Value::String(self.artist.into())),
                ("album", self.album.into_value()?),
                ("duration-ms", self.duration_ms.into_value()?),
                ("sync-type", self.sync_type.into_value()?),
            ],
        )?;
        Ok(Value::Record(record))
    }
}

impl UnaryComponentType for LyricsMatch {}











// ========== Host Imports ==========

/// Host trait for interface: component:lyrics-provider/utils
pub trait UtilsHost {
    fn http_request(&mut self, url: String, options: RequestOptions) -> Result<HttpResponse, String>;
    fn random_number(&mut self) -> u64;
    fn current_unix_timestamp(&mut self) -> u64;
    fn storage_set(&mut self, key: String, value: String) -> bool;
    fn storage_get(&mut self, key: String) -> Option<String>;
    fn storage_delete(&mut self, key: String) -> bool;
}

pub mod imports {
    use super::*;

    pub fn register_utils_host<T: UtilsHost + 'static, E: backend::WasmEngine>(
        linker: &mut Linker,
        store: &mut Store<T, E>,
    ) -> Result<()> {
        let host_interface = linker
            .define_instance("component:lyrics-provider/utils".try_into().unwrap())
            .context("Failed to define host interface")?;

        host_interface
            .define_func(
                "http-request",
                Func::new(
                    &mut *store,
                    FuncType::new(
                        [ValueType::String, RequestOptions::ty(), ],
                        [ValueType::Result(ResultType::new(Some(HttpResponse::ty()), Some(ValueType::String)))],
                    ),
                    |mut ctx, params, results| {
                        let url = if let Value::String(s) = &params[0] { s.to_string() } else { bail!("Expected string") };
                        let options = RequestOptions::from_value(&params[1])?;
                        let result = ctx.data_mut().http_request(url, options);
                        results[0] = result.into_value()?;
                        Ok(())
                    },
                ),
            )
            .context("Failed to define http-request function")?;

        host_interface
            .define_func(
                "random-number",
                Func::new(
                    &mut *store,
                    FuncType::new(
                        [],
                        [ValueType::U64],
                    ),
                    |mut ctx, params, results| {
                        let result = ctx.data_mut().random_number();
                        results[0] = Value::U64(result);
                        Ok(())
                    },
                ),
            )
            .context("Failed to define random-number function")?;

        host_interface
            .define_func(
                "current-unix-timestamp",
                Func::new(
                    &mut *store,
                    FuncType::new(
                        [],
                        [ValueType::U64],
                    ),
                    |mut ctx, params, results| {
                        let result = ctx.data_mut().current_unix_timestamp();
                        results[0] = Value::U64(result);
                        Ok(())
                    },
                ),
            )
            .context("Failed to define current-unix-timestamp function")?;

        host_interface
            .define_func(
                "storage-set",
                Func::new(
                    &mut *store,
                    FuncType::new(
                        [ValueType::String, ValueType::String, ],
                        [ValueType::Bool],
                    ),
                    |mut ctx, params, results| {
                        let key = if let Value::String(s) = &params[0] { s.to_string() } else { bail!("Expected string") };
                        let value = if let Value::String(s) = &params[1] { s.to_string() } else { bail!("Expected string") };
                        let result = ctx.data_mut().storage_set(key, value);
                        results[0] = Value::Bool(result);
                        Ok(())
                    },
                ),
            )
            .context("Failed to define storage-set function")?;

        host_interface
            .define_func(
                "storage-get",
                Func::new(
                    &mut *store,
                    FuncType::new(
                        [ValueType::String, ],
                        [ValueType::Option(OptionType::new(ValueType::String))],
                    ),
                    |mut ctx, params, results| {
                        let key = if let Value::String(s) = &params[0] { s.to_string() } else { bail!("Expected string") };
                        let result = ctx.data_mut().storage_get(key);
                        results[0] = result.into_value()?;
                        Ok(())
                    },
                ),
            )
            .context("Failed to define storage-get function")?;

        host_interface
            .define_func(
                "storage-delete",
                Func::new(
                    &mut *store,
                    FuncType::new(
                        [ValueType::String, ],
                        [ValueType::Bool],
                    ),
                    |mut ctx, params, results| {
                        let key = if let Value::String(s) = &params[0] { s.to_string() } else { bail!("Expected string") };
                        let result = ctx.data_mut().storage_delete(key);
                        results[0] = Value::Bool(result);
                        Ok(())
                    },
                ),
            )
            .context("Failed to define storage-delete function")?;

        Ok(())
    }

}

// ========== Guest Exports ==========

pub mod exports_types {
    use super::*;

    pub const INTERFACE_NAME: &str = "component:lyrics-provider/types";

}

pub mod exports_lyrics_api {
    use super::*;

    pub const INTERFACE_NAME: &str = "component:lyrics-provider/lyrics-api";

    #[allow(clippy::type_complexity)]
    pub fn get_get_lyrics<T, E: backend::WasmEngine>(
        instance: &Instance,
        _store: &mut Store<T, E>,
    ) -> Result<TypedFunc<TrackMetadata, Result<Option<(Lyrics, LyricsMetadata)>, String>>> {
        let interface = instance
            .exports()
            .instance(&INTERFACE_NAME.try_into().unwrap())
            .ok_or_else(|| anyhow!("Interface not found"))?;

        interface
            .func("get-lyrics")
            .ok_or_else(|| anyhow!("Function 'get-lyrics' not found"))?
            .typed::<TrackMetadata, Result<Option<(Lyrics, LyricsMetadata)>, String>>()
    }

    #[allow(clippy::type_complexity)]
    pub fn get_search<T, E: backend::WasmEngine>(
        instance: &Instance,
        _store: &mut Store<T, E>,
    ) -> Result<TypedFunc<String, Result<Vec<LyricsMatch>, String>>> {
        let interface = instance
            .exports()
            .instance(&INTERFACE_NAME.try_into().unwrap())
            .ok_or_else(|| anyhow!("Interface not found"))?;

        interface
            .func("search")
            .ok_or_else(|| anyhow!("Function 'search' not found"))?
            .typed::<String, Result<Vec<LyricsMatch>, String>>()
    }

    #[allow(clippy::type_complexity)]
    pub fn get_get_lyrics_by_id<T, E: backend::WasmEngine>(
        instance: &Instance,
        _store: &mut Store<T, E>,
    ) -> Result<TypedFunc<String, Result<(Lyrics, LyricsMetadata), String>>> {
        let interface = instance
            .exports()
            .instance(&INTERFACE_NAME.try_into().unwrap())
            .ok_or_else(|| anyhow!("Interface not found"))?;

        interface
            .func("get-lyrics-by-id")
            .ok_or_else(|| anyhow!("Function 'get-lyrics-by-id' not found"))?
            .typed::<String, Result<(Lyrics, LyricsMetadata), String>>()
    }

}

