// AUTO-GENERATED WIT BINDINGS for wasm-component-layer
// DO NOT EDIT - Regenerate using wit-bindgen-wcl

#![allow(dead_code, unused_imports, ambiguous_glob_reexports)]

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
pub enum CollectionType {
    Playlist,
    Album,
}

impl ComponentType for CollectionType {
    fn ty() -> ValueType {
        ValueType::Enum(EnumType::new(None, [
            "playlist",
            "album",
        ]).unwrap())
    }

    fn from_value(value: &Value) -> Result<Self> {
        if let Value::Enum(enum_val) = value {
            let discriminant = enum_val.discriminant();
            match discriminant {
                0 => Ok(CollectionType::Playlist),
                1 => Ok(CollectionType::Album),
                _ => bail!("Invalid enum discriminant: {}", discriminant),
            }
        } else {
            bail!("Expected Enum value")
        }
    }

    fn into_value(self) -> Result<Value> {
        let enum_type = EnumType::new(None, [
            "playlist",
            "album",
        ]).unwrap();

        let discriminant = match self {
            CollectionType::Playlist => 0,
            CollectionType::Album => 1,
        };

        Ok(Value::Enum(Enum::new(enum_type, discriminant)?))
    }
}

impl UnaryComponentType for CollectionType {}

#[derive(Debug, Clone)]
pub struct CollectionSummary {
    pub title: String,
    pub kind: CollectionType,
    pub description: Option<String>,
    pub owner: Option<String>,
    pub thumbnail_url: Option<String>,
    pub track_count: Option<u32>,
}

impl ComponentType for CollectionSummary {
    fn ty() -> ValueType {
        ValueType::Record(
            RecordType::new(
                None,
                [
                    ("title", ValueType::String),
                    ("kind", CollectionType::ty()),
                    ("description", ValueType::Option(OptionType::new(ValueType::String))),
                    ("owner", ValueType::Option(OptionType::new(ValueType::String))),
                    ("thumbnail-url", ValueType::Option(OptionType::new(ValueType::String))),
                    ("track-count", ValueType::Option(OptionType::new(ValueType::U32))),
                ],
            ).unwrap(),
        )
    }

    fn from_value(value: &Value) -> Result<Self> {
        if let Value::Record(record) = value {
            let title = record
                .field("title")
                .ok_or_else(|| anyhow!("Missing 'title' field"))?;
            let kind = record
                .field("kind")
                .ok_or_else(|| anyhow!("Missing 'kind' field"))?;
            let description = record
                .field("description")
                .ok_or_else(|| anyhow!("Missing 'description' field"))?;
            let owner = record
                .field("owner")
                .ok_or_else(|| anyhow!("Missing 'owner' field"))?;
            let thumbnail_url = record
                .field("thumbnail-url")
                .ok_or_else(|| anyhow!("Missing 'thumbnail-url' field"))?;
            let track_count = record
                .field("track-count")
                .ok_or_else(|| anyhow!("Missing 'track-count' field"))?;

            let title = if let Value::String(s) = title { s.to_string() } else { bail!("Expected string") };
            let kind = CollectionType::from_value(&kind)?;
            let description = Option::<String>::from_value(&description)?;
            let owner = Option::<String>::from_value(&owner)?;
            let thumbnail_url = Option::<String>::from_value(&thumbnail_url)?;
            let track_count = Option::<u32>::from_value(&track_count)?;

            Ok(CollectionSummary {
                title,
                kind,
                description,
                owner,
                thumbnail_url,
                track_count,
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
                    ("kind", CollectionType::ty()),
                    ("description", ValueType::Option(OptionType::new(ValueType::String))),
                    ("owner", ValueType::Option(OptionType::new(ValueType::String))),
                    ("thumbnail-url", ValueType::Option(OptionType::new(ValueType::String))),
                    ("track-count", ValueType::Option(OptionType::new(ValueType::U32))),
                ],
            ).unwrap(),
            [
                ("title", Value::String(self.title.into())),
                ("kind", self.kind.into_value()?),
                ("description", self.description.into_value()?),
                ("owner", self.owner.into_value()?),
                ("thumbnail-url", self.thumbnail_url.into_value()?),
                ("track-count", self.track_count.into_value()?),
            ],
        )?;
        Ok(Value::Record(record))
    }
}

impl UnaryComponentType for CollectionSummary {}




#[derive(Debug, Clone)]
pub struct TrackItem {
    pub title: String,
    pub artists: Vec<String>,
    pub thumbnail_url: Option<String>,
    pub album_title: Option<String>,
    pub duration_ms: Option<u64>,
    pub is_explicit: Option<bool>,
    pub url: Option<String>,
    pub source_id: Option<String>,
}

impl ComponentType for TrackItem {
    fn ty() -> ValueType {
        ValueType::Record(
            RecordType::new(
                None,
                [
                    ("title", ValueType::String),
                    ("artists", ValueType::List(ListType::new(ValueType::String))),
                    ("thumbnail-url", ValueType::Option(OptionType::new(ValueType::String))),
                    ("album-title", ValueType::Option(OptionType::new(ValueType::String))),
                    ("duration-ms", ValueType::Option(OptionType::new(ValueType::U64))),
                    ("is-explicit", ValueType::Option(OptionType::new(ValueType::Bool))),
                    ("url", ValueType::Option(OptionType::new(ValueType::String))),
                    ("source-id", ValueType::Option(OptionType::new(ValueType::String))),
                ],
            ).unwrap(),
        )
    }

    fn from_value(value: &Value) -> Result<Self> {
        if let Value::Record(record) = value {
            let title = record
                .field("title")
                .ok_or_else(|| anyhow!("Missing 'title' field"))?;
            let artists = record
                .field("artists")
                .ok_or_else(|| anyhow!("Missing 'artists' field"))?;
            let thumbnail_url = record
                .field("thumbnail-url")
                .ok_or_else(|| anyhow!("Missing 'thumbnail-url' field"))?;
            let album_title = record
                .field("album-title")
                .ok_or_else(|| anyhow!("Missing 'album-title' field"))?;
            let duration_ms = record
                .field("duration-ms")
                .ok_or_else(|| anyhow!("Missing 'duration-ms' field"))?;
            let is_explicit = record
                .field("is-explicit")
                .ok_or_else(|| anyhow!("Missing 'is-explicit' field"))?;
            let url = record
                .field("url")
                .ok_or_else(|| anyhow!("Missing 'url' field"))?;
            let source_id = record
                .field("source-id")
                .ok_or_else(|| anyhow!("Missing 'source-id' field"))?;

            let title = if let Value::String(s) = title { s.to_string() } else { bail!("Expected string") };
            let artists = Vec::<String>::from_value(&artists)?;
            let thumbnail_url = Option::<String>::from_value(&thumbnail_url)?;
            let album_title = Option::<String>::from_value(&album_title)?;
            let duration_ms = Option::<u64>::from_value(&duration_ms)?;
            let is_explicit = Option::<bool>::from_value(&is_explicit)?;
            let url = Option::<String>::from_value(&url)?;
            let source_id = Option::<String>::from_value(&source_id)?;

            Ok(TrackItem {
                title,
                artists,
                thumbnail_url,
                album_title,
                duration_ms,
                is_explicit,
                url,
                source_id,
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
                    ("artists", ValueType::List(ListType::new(ValueType::String))),
                    ("thumbnail-url", ValueType::Option(OptionType::new(ValueType::String))),
                    ("album-title", ValueType::Option(OptionType::new(ValueType::String))),
                    ("duration-ms", ValueType::Option(OptionType::new(ValueType::U64))),
                    ("is-explicit", ValueType::Option(OptionType::new(ValueType::Bool))),
                    ("url", ValueType::Option(OptionType::new(ValueType::String))),
                    ("source-id", ValueType::Option(OptionType::new(ValueType::String))),
                ],
            ).unwrap(),
            [
                ("title", Value::String(self.title.into())),
                ("artists", self.artists.into_value()?),
                ("thumbnail-url", self.thumbnail_url.into_value()?),
                ("album-title", self.album_title.into_value()?),
                ("duration-ms", self.duration_ms.into_value()?),
                ("is-explicit", self.is_explicit.into_value()?),
                ("url", self.url.into_value()?),
                ("source-id", self.source_id.into_value()?),
            ],
        )?;
        Ok(Value::Record(record))
    }
}

impl UnaryComponentType for TrackItem {}


#[derive(Debug, Clone)]
pub struct Tracks {
    pub items: Vec<TrackItem>,
}

impl ComponentType for Tracks {
    fn ty() -> ValueType {
        ValueType::Record(
            RecordType::new(
                None,
                [
                    ("items", ValueType::List(ListType::new(TrackItem::ty()))),
                ],
            ).unwrap(),
        )
    }

    fn from_value(value: &Value) -> Result<Self> {
        if let Value::Record(record) = value {
            let items = record
                .field("items")
                .ok_or_else(|| anyhow!("Missing 'items' field"))?;

            let items = Vec::<TrackItem>::from_value(&items)?;

            Ok(Tracks {
                items,
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
                    ("items", ValueType::List(ListType::new(TrackItem::ty()))),
                ],
            ).unwrap(),
            [
                ("items", self.items.into_value()?),
            ],
        )?;
        Ok(Value::Record(record))
    }
}

impl UnaryComponentType for Tracks {}





// ========== Host Imports ==========

/// Host trait for interface: component:content-importer/utils
pub trait UtilsHost {
    fn http_request(&mut self, url: String, options: RequestOptions) -> Result<HttpResponse, String>;
    fn random_number(&mut self) -> u64;
    fn current_unix_timestamp(&mut self) -> u64;
    fn storage_set(&mut self, key: String, value: String) -> bool;
    fn storage_get(&mut self, key: String) -> Option<String>;
}

pub mod imports {
    use super::*;

    pub fn register_utils_host<T: UtilsHost + 'static, E: backend::WasmEngine>(
        linker: &mut Linker,
        store: &mut Store<T, E>,
    ) -> Result<()> {
        let host_interface = linker
            .define_instance("component:content-importer/utils".try_into().unwrap())
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
                    |mut ctx, _params, results| {
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
                    |mut ctx, _params, results| {
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

        Ok(())
    }

}

// ========== Guest Exports ==========

pub mod exports_types {
    use super::*;

    pub const INTERFACE_NAME: &str = "component:content-importer/types";

}

pub mod exports_importer {
    use super::*;

    pub const INTERFACE_NAME: &str = "component:content-importer/importer";

    #[allow(clippy::type_complexity)]
    pub fn get_can_handle_url<T, E: backend::WasmEngine>(
        instance: &Instance,
        _store: &mut Store<T, E>,
    ) -> Result<TypedFunc<String, bool>> {
        let interface = instance
            .exports()
            .instance(&INTERFACE_NAME.try_into().unwrap())
            .ok_or_else(|| anyhow!("Interface not found"))?;

        interface
            .func("can-handle-url")
            .ok_or_else(|| anyhow!("Function 'can-handle-url' not found"))?
            .typed::<String, bool>()
    }

    #[allow(clippy::type_complexity)]
    pub fn get_get_collection_info<T, E: backend::WasmEngine>(
        instance: &Instance,
        _store: &mut Store<T, E>,
    ) -> Result<TypedFunc<String, Result<CollectionSummary, String>>> {
        let interface = instance
            .exports()
            .instance(&INTERFACE_NAME.try_into().unwrap())
            .ok_or_else(|| anyhow!("Interface not found"))?;

        interface
            .func("get-collection-info")
            .ok_or_else(|| anyhow!("Function 'get-collection-info' not found"))?
            .typed::<String, Result<CollectionSummary, String>>()
    }

    #[allow(clippy::type_complexity)]
    pub fn get_get_tracks<T, E: backend::WasmEngine>(
        instance: &Instance,
        _store: &mut Store<T, E>,
    ) -> Result<TypedFunc<String, Result<Tracks, String>>> {
        let interface = instance
            .exports()
            .instance(&INTERFACE_NAME.try_into().unwrap())
            .ok_or_else(|| anyhow!("Interface not found"))?;

        interface
            .func("get-tracks")
            .ok_or_else(|| anyhow!("Function 'get-tracks' not found"))?
            .typed::<String, Result<Tracks, String>>()
    }

}

