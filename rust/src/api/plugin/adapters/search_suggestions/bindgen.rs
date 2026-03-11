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
pub enum EntityType {
    Track,
    Album,
    Artist,
    Playlist,
    Genre,
    Unknown,
}

impl ComponentType for EntityType {
    fn ty() -> ValueType {
        ValueType::Enum(EnumType::new(None, [
            "track",
            "album",
            "artist",
            "playlist",
            "genre",
            "unknown",
        ]).unwrap())
    }

    fn from_value(value: &Value) -> Result<Self> {
        if let Value::Enum(enum_val) = value {
            let discriminant = enum_val.discriminant();
            match discriminant {
                0 => Ok(EntityType::Track),
                1 => Ok(EntityType::Album),
                2 => Ok(EntityType::Artist),
                3 => Ok(EntityType::Playlist),
                4 => Ok(EntityType::Genre),
                5 => Ok(EntityType::Unknown),
                _ => bail!("Invalid enum discriminant: {}", discriminant),
            }
        } else {
            bail!("Expected Enum value")
        }
    }

    fn into_value(self) -> Result<Value> {
        let enum_type = EnumType::new(None, [
            "track",
            "album",
            "artist",
            "playlist",
            "genre",
            "unknown",
        ]).unwrap();

        let discriminant = match self {
            EntityType::Track => 0,
            EntityType::Album => 1,
            EntityType::Artist => 2,
            EntityType::Playlist => 3,
            EntityType::Genre => 4,
            EntityType::Unknown => 5,
        };

        Ok(Value::Enum(Enum::new(enum_type, discriminant)?))
    }
}

impl UnaryComponentType for EntityType {}

#[derive(Debug, Clone)]
pub struct Artwork {
    pub url: String,
    pub url_low: Option<String>,
}

impl ComponentType for Artwork {
    fn ty() -> ValueType {
        ValueType::Record(
            RecordType::new(
                None,
                [
                    ("url", ValueType::String),
                    ("url-low", ValueType::Option(OptionType::new(ValueType::String))),
                ],
            ).unwrap(),
        )
    }

    fn from_value(value: &Value) -> Result<Self> {
        if let Value::Record(record) = value {
            let url = record
                .field("url")
                .ok_or_else(|| anyhow!("Missing 'url' field"))?;
            let url_low = record
                .field("url-low")
                .ok_or_else(|| anyhow!("Missing 'url-low' field"))?;

            let url = if let Value::String(s) = url { s.to_string() } else { bail!("Expected string") };
            let url_low = Option::<String>::from_value(&url_low)?;

            Ok(Artwork {
                url,
                url_low,
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
                    ("url", ValueType::String),
                    ("url-low", ValueType::Option(OptionType::new(ValueType::String))),
                ],
            ).unwrap(),
            [
                ("url", Value::String(self.url.into())),
                ("url-low", self.url_low.into_value()?),
            ],
        )?;
        Ok(Value::Record(record))
    }
}

impl UnaryComponentType for Artwork {}


#[derive(Debug, Clone)]
pub struct EntitySuggestion {
    pub id: String,
    pub title: String,
    pub subtitle: Option<String>,
    pub kind: EntityType,
    pub thumbnail: Option<Artwork>,
}

impl ComponentType for EntitySuggestion {
    fn ty() -> ValueType {
        ValueType::Record(
            RecordType::new(
                None,
                [
                    ("id", ValueType::String),
                    ("title", ValueType::String),
                    ("subtitle", ValueType::Option(OptionType::new(ValueType::String))),
                    ("kind", EntityType::ty()),
                    ("thumbnail", ValueType::Option(OptionType::new(Artwork::ty()))),
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
            let subtitle = record
                .field("subtitle")
                .ok_or_else(|| anyhow!("Missing 'subtitle' field"))?;
            let kind = record
                .field("kind")
                .ok_or_else(|| anyhow!("Missing 'kind' field"))?;
            let thumbnail = record
                .field("thumbnail")
                .ok_or_else(|| anyhow!("Missing 'thumbnail' field"))?;

            let id = if let Value::String(s) = id { s.to_string() } else { bail!("Expected string") };
            let title = if let Value::String(s) = title { s.to_string() } else { bail!("Expected string") };
            let subtitle = Option::<String>::from_value(&subtitle)?;
            let kind = EntityType::from_value(&kind)?;
            let thumbnail = Option::<Artwork>::from_value(&thumbnail)?;

            Ok(EntitySuggestion {
                id,
                title,
                subtitle,
                kind,
                thumbnail,
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
                    ("subtitle", ValueType::Option(OptionType::new(ValueType::String))),
                    ("kind", EntityType::ty()),
                    ("thumbnail", ValueType::Option(OptionType::new(Artwork::ty()))),
                ],
            ).unwrap(),
            [
                ("id", Value::String(self.id.into())),
                ("title", Value::String(self.title.into())),
                ("subtitle", self.subtitle.into_value()?),
                ("kind", self.kind.into_value()?),
                ("thumbnail", self.thumbnail.into_value()?),
            ],
        )?;
        Ok(Value::Record(record))
    }
}

impl UnaryComponentType for EntitySuggestion {}

#[derive(Debug, Clone)]
pub enum Suggestion {
    Query(String),
    Entity(EntitySuggestion),
}

impl ComponentType for Suggestion {
    fn ty() -> ValueType {
        ValueType::Variant(
            VariantType::new(
                None,
                [
                    VariantCase::new("query", Some(ValueType::String)),
                    VariantCase::new("entity", Some(EntitySuggestion::ty())),
                ],
            ).unwrap(),
        )
    }

    fn from_value(value: &Value) -> Result<Self> {
        if let Value::Variant(variant) = value {
            let discriminant = variant.discriminant();
            let variant_ty = variant.ty();
            let case = &variant_ty.cases()[discriminant];
            let case_name = case.name();
            let payload = variant.value();

            match case_name {
                "query" => {
                    if let Some(payload_value) = payload {
                        let converted = if let Value::String(s) = payload_value { s.to_string() } else { bail!("Expected string") };
                        Ok(Suggestion::Query(converted))
                    } else {
                        bail!("Expected payload for query case")
                    }
                }
                "entity" => {
                    if let Some(payload_value) = payload {
                        let converted = EntitySuggestion::from_value(&payload_value)?;
                        Ok(Suggestion::Entity(converted))
                    } else {
                        bail!("Expected payload for entity case")
                    }
                }
                _ => bail!("Unknown variant case: {}", case_name),
            }
        } else {
            bail!("Expected Variant value")
        }
    }

    fn into_value(self) -> Result<Value> {
        let variant_type = VariantType::new(
            None,
            [
                VariantCase::new("query", Some(ValueType::String)),
                VariantCase::new("entity", Some(EntitySuggestion::ty())),
            ],
        ).unwrap();

        let (discriminant, payload) = match self {
            Suggestion::Query(val) => (0, Some(Value::String(val.into()))),
            Suggestion::Entity(val) => (1, Some(val.into_value()?)),
        };

        let variant = Variant::new(variant_type, discriminant, payload)?;
        Ok(Value::Variant(variant))
    }
}

impl UnaryComponentType for Suggestion {}




#[derive(Debug, Clone)]
pub struct SuggestionOptions {
    pub limit: Option<u8>,
    pub include_entities: bool,
    pub allowed_types: Option<Vec<EntityType>>,
}

impl ComponentType for SuggestionOptions {
    fn ty() -> ValueType {
        ValueType::Record(
            RecordType::new(
                None,
                [
                    ("limit", ValueType::Option(OptionType::new(ValueType::U8))),
                    ("include-entities", ValueType::Bool),
                    ("allowed-types", ValueType::Option(OptionType::new(ValueType::List(ListType::new(EntityType::ty()))))),
                ],
            ).unwrap(),
        )
    }

    fn from_value(value: &Value) -> Result<Self> {
        if let Value::Record(record) = value {
            let limit = record
                .field("limit")
                .ok_or_else(|| anyhow!("Missing 'limit' field"))?;
            let include_entities = record
                .field("include-entities")
                .ok_or_else(|| anyhow!("Missing 'include-entities' field"))?;
            let allowed_types = record
                .field("allowed-types")
                .ok_or_else(|| anyhow!("Missing 'allowed-types' field"))?;

            let limit = Option::<u8>::from_value(&limit)?;
            let include_entities = if let Value::Bool(x) = include_entities { x } else { bail!("Expected bool") };
            let allowed_types = Option::<Vec::<EntityType>>::from_value(&allowed_types)?;

            Ok(SuggestionOptions {
                limit,
                include_entities,
                allowed_types,
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
                    ("limit", ValueType::Option(OptionType::new(ValueType::U8))),
                    ("include-entities", ValueType::Bool),
                    ("allowed-types", ValueType::Option(OptionType::new(ValueType::List(ListType::new(EntityType::ty()))))),
                ],
            ).unwrap(),
            [
                ("limit", self.limit.into_value()?),
                ("include-entities", Value::Bool(self.include_entities)),
                ("allowed-types", self.allowed_types.into_value()?),
            ],
        )?;
        Ok(Value::Record(record))
    }
}

impl UnaryComponentType for SuggestionOptions {}





// ========== Host Imports ==========

/// Host trait for interface: component:search-suggestion-provider/utils
pub trait UtilsHost {
    fn http_request(&mut self, url: String, options: RequestOptions) -> Result<HttpResponse, String>;
    fn random_number(&mut self) -> u64;
    fn current_unix_timestamp(&mut self) -> u64;
    fn storage_set(&mut self, key: String, value: String) -> bool;
    fn storage_get(&mut self, key: String) -> Option<String>;
    fn storage_delete(&mut self, key: String) -> bool;
    fn log(&mut self, message: String) -> ();
}

pub mod imports {
    use super::*;

    pub fn register_utils_host<T: UtilsHost + 'static, E: backend::WasmEngine>(
        linker: &mut Linker,
        store: &mut Store<T, E>,
    ) -> Result<()> {
        let host_interface = linker
            .define_instance("component:search-suggestion-provider/utils".try_into().unwrap())
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

        host_interface
            .define_func(
                "log",
                Func::new(
                    &mut *store,
                    FuncType::new(
                        [ValueType::String, ],
                        [],
                    ),
                    |mut ctx, params, _results| {
                        let message = if let Value::String(s) = &params[0] { s.to_string() } else { bail!("Expected string") };
                        ctx.data_mut().log(message);
                        Ok(())
                    },
                ),
            )
            .context("Failed to define log function")?;

        Ok(())
    }

}

// ========== Guest Exports ==========

pub mod exports_types {
    use super::*;

    pub const INTERFACE_NAME: &str = "component:search-suggestion-provider/types";

}

pub mod exports_suggestion_api {
    use super::*;

    pub const INTERFACE_NAME: &str = "component:search-suggestion-provider/suggestion-api";

    #[allow(clippy::type_complexity)]
    pub fn get_get_suggestions<T, E: backend::WasmEngine>(
        instance: &Instance,
        _store: &mut Store<T, E>,
    ) -> Result<TypedFunc<(String, SuggestionOptions), Result<Vec<Suggestion>, String>>> {
        let interface = instance
            .exports()
            .instance(&INTERFACE_NAME.try_into().unwrap())
            .ok_or_else(|| anyhow!("Interface not found"))?;

        interface
            .func("get-suggestions")
            .ok_or_else(|| anyhow!("Function 'get-suggestions' not found"))?
            .typed::<(String, SuggestionOptions), Result<Vec<Suggestion>, String>>()
    }

    #[allow(clippy::type_complexity)]
    pub fn get_get_default_suggestions<T, E: backend::WasmEngine>(
        instance: &Instance,
        _store: &mut Store<T, E>,
    ) -> Result<TypedFunc<SuggestionOptions, Result<Vec<Suggestion>, String>>> {
        let interface = instance
            .exports()
            .instance(&INTERFACE_NAME.try_into().unwrap())
            .ok_or_else(|| anyhow!("Interface not found"))?;

        interface
            .func("get-default-suggestions")
            .ok_or_else(|| anyhow!("Function 'get-default-suggestions' not found"))?
            .typed::<SuggestionOptions, Result<Vec<Suggestion>, String>>()
    }

}

