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



#[derive(Debug, Clone)]
pub struct Artwork {
    pub url: String,
    pub url_low: Option<String>,
    pub url_high: Option<String>,
}

impl ComponentType for Artwork {
    fn ty() -> ValueType {
        ValueType::Record(
            RecordType::new(
                None,
                [
                    ("url", ValueType::String),
                    ("url-low", ValueType::Option(OptionType::new(ValueType::String))),
                    ("url-high", ValueType::Option(OptionType::new(ValueType::String))),
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
            let url_high = record
                .field("url-high")
                .ok_or_else(|| anyhow!("Missing 'url-high' field"))?;

            let url = if let Value::String(s) = url { s.to_string() } else { bail!("Expected string") };
            let url_low = Option::<String>::from_value(&url_low)?;
            let url_high = Option::<String>::from_value(&url_high)?;

            Ok(Artwork {
                url,
                url_low,
                url_high,
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
                    ("url-high", ValueType::Option(OptionType::new(ValueType::String))),
                ],
            ).unwrap(),
            [
                ("url", Value::String(self.url.into())),
                ("url-low", self.url_low.into_value()?),
                ("url-high", self.url_high.into_value()?),
            ],
        )?;
        Ok(Value::Record(record))
    }
}

impl UnaryComponentType for Artwork {}



#[derive(Debug, Clone)]
pub struct TrackItem {
    pub id: String,
    pub title: String,
    pub artists: String,
    pub album: Option<String>,
    pub thumbnail: Option<Artwork>,
    pub duration_ms: Option<u64>,
    pub is_explicit: bool,
}

impl ComponentType for TrackItem {
    fn ty() -> ValueType {
        ValueType::Record(
            RecordType::new(
                None,
                [
                    ("id", ValueType::String),
                    ("title", ValueType::String),
                    ("artists", ValueType::String),
                    ("album", ValueType::Option(OptionType::new(ValueType::String))),
                    ("thumbnail", ValueType::Option(OptionType::new(Artwork::ty()))),
                    ("duration-ms", ValueType::Option(OptionType::new(ValueType::U64))),
                    ("is-explicit", ValueType::Bool),
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
            let artists = record
                .field("artists")
                .ok_or_else(|| anyhow!("Missing 'artists' field"))?;
            let album = record
                .field("album")
                .ok_or_else(|| anyhow!("Missing 'album' field"))?;
            let thumbnail = record
                .field("thumbnail")
                .ok_or_else(|| anyhow!("Missing 'thumbnail' field"))?;
            let duration_ms = record
                .field("duration-ms")
                .ok_or_else(|| anyhow!("Missing 'duration-ms' field"))?;
            let is_explicit = record
                .field("is-explicit")
                .ok_or_else(|| anyhow!("Missing 'is-explicit' field"))?;

            let id = if let Value::String(s) = id { s.to_string() } else { bail!("Expected string") };
            let title = if let Value::String(s) = title { s.to_string() } else { bail!("Expected string") };
            let artists = if let Value::String(s) = artists { s.to_string() } else { bail!("Expected string") };
            let album = Option::<String>::from_value(&album)?;
            let thumbnail = Option::<Artwork>::from_value(&thumbnail)?;
            let duration_ms = Option::<u64>::from_value(&duration_ms)?;
            let is_explicit = if let Value::Bool(x) = is_explicit { x } else { bail!("Expected bool") };

            Ok(TrackItem {
                id,
                title,
                artists,
                album,
                thumbnail,
                duration_ms,
                is_explicit,
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
                    ("artists", ValueType::String),
                    ("album", ValueType::Option(OptionType::new(ValueType::String))),
                    ("thumbnail", ValueType::Option(OptionType::new(Artwork::ty()))),
                    ("duration-ms", ValueType::Option(OptionType::new(ValueType::U64))),
                    ("is-explicit", ValueType::Bool),
                ],
            ).unwrap(),
            [
                ("id", Value::String(self.id.into())),
                ("title", Value::String(self.title.into())),
                ("artists", Value::String(self.artists.into())),
                ("album", self.album.into_value()?),
                ("thumbnail", self.thumbnail.into_value()?),
                ("duration-ms", self.duration_ms.into_value()?),
                ("is-explicit", Value::Bool(self.is_explicit)),
            ],
        )?;
        Ok(Value::Record(record))
    }
}

impl UnaryComponentType for TrackItem {}


#[derive(Debug, Clone)]
pub struct AlbumItem {
    pub id: String,
    pub title: String,
    pub artists: Vec<String>,
    pub thumbnail: Option<Artwork>,
    pub year: Option<u32>,
}

impl ComponentType for AlbumItem {
    fn ty() -> ValueType {
        ValueType::Record(
            RecordType::new(
                None,
                [
                    ("id", ValueType::String),
                    ("title", ValueType::String),
                    ("artists", ValueType::List(ListType::new(ValueType::String))),
                    ("thumbnail", ValueType::Option(OptionType::new(Artwork::ty()))),
                    ("year", ValueType::Option(OptionType::new(ValueType::U32))),
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
            let artists = record
                .field("artists")
                .ok_or_else(|| anyhow!("Missing 'artists' field"))?;
            let thumbnail = record
                .field("thumbnail")
                .ok_or_else(|| anyhow!("Missing 'thumbnail' field"))?;
            let year = record
                .field("year")
                .ok_or_else(|| anyhow!("Missing 'year' field"))?;

            let id = if let Value::String(s) = id { s.to_string() } else { bail!("Expected string") };
            let title = if let Value::String(s) = title { s.to_string() } else { bail!("Expected string") };
            let artists = Vec::<String>::from_value(&artists)?;
            let thumbnail = Option::<Artwork>::from_value(&thumbnail)?;
            let year = Option::<u32>::from_value(&year)?;

            Ok(AlbumItem {
                id,
                title,
                artists,
                thumbnail,
                year,
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
                    ("artists", ValueType::List(ListType::new(ValueType::String))),
                    ("thumbnail", ValueType::Option(OptionType::new(Artwork::ty()))),
                    ("year", ValueType::Option(OptionType::new(ValueType::U32))),
                ],
            ).unwrap(),
            [
                ("id", Value::String(self.id.into())),
                ("title", Value::String(self.title.into())),
                ("artists", self.artists.into_value()?),
                ("thumbnail", self.thumbnail.into_value()?),
                ("year", self.year.into_value()?),
            ],
        )?;
        Ok(Value::Record(record))
    }
}

impl UnaryComponentType for AlbumItem {}

#[derive(Debug, Clone)]
pub struct ArtistItem {
    pub id: String,
    pub name: String,
    pub thumbnail: Option<Artwork>,
}

impl ComponentType for ArtistItem {
    fn ty() -> ValueType {
        ValueType::Record(
            RecordType::new(
                None,
                [
                    ("id", ValueType::String),
                    ("name", ValueType::String),
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
            let name = record
                .field("name")
                .ok_or_else(|| anyhow!("Missing 'name' field"))?;
            let thumbnail = record
                .field("thumbnail")
                .ok_or_else(|| anyhow!("Missing 'thumbnail' field"))?;

            let id = if let Value::String(s) = id { s.to_string() } else { bail!("Expected string") };
            let name = if let Value::String(s) = name { s.to_string() } else { bail!("Expected string") };
            let thumbnail = Option::<Artwork>::from_value(&thumbnail)?;

            Ok(ArtistItem {
                id,
                name,
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
                    ("name", ValueType::String),
                    ("thumbnail", ValueType::Option(OptionType::new(Artwork::ty()))),
                ],
            ).unwrap(),
            [
                ("id", Value::String(self.id.into())),
                ("name", Value::String(self.name.into())),
                ("thumbnail", self.thumbnail.into_value()?),
            ],
        )?;
        Ok(Value::Record(record))
    }
}

impl UnaryComponentType for ArtistItem {}

#[derive(Debug, Clone)]
pub enum MediaItem {
    Track(TrackItem),
    Album(AlbumItem),
    Artist(ArtistItem),
}

impl ComponentType for MediaItem {
    fn ty() -> ValueType {
        ValueType::Variant(
            VariantType::new(
                None,
                [
                    VariantCase::new("track", Some(TrackItem::ty())),
                    VariantCase::new("album", Some(AlbumItem::ty())),
                    VariantCase::new("artist", Some(ArtistItem::ty())),
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
                "track" => {
                    if let Some(payload_value) = payload {
                        let converted = TrackItem::from_value(&payload_value)?;
                        Ok(MediaItem::Track(converted))
                    } else {
                        bail!("Expected payload for track case")
                    }
                }
                "album" => {
                    if let Some(payload_value) = payload {
                        let converted = AlbumItem::from_value(&payload_value)?;
                        Ok(MediaItem::Album(converted))
                    } else {
                        bail!("Expected payload for album case")
                    }
                }
                "artist" => {
                    if let Some(payload_value) = payload {
                        let converted = ArtistItem::from_value(&payload_value)?;
                        Ok(MediaItem::Artist(converted))
                    } else {
                        bail!("Expected payload for artist case")
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
                VariantCase::new("track", Some(TrackItem::ty())),
                VariantCase::new("album", Some(AlbumItem::ty())),
                VariantCase::new("artist", Some(ArtistItem::ty())),
            ],
        ).unwrap();

        let (discriminant, payload) = match self {
            MediaItem::Track(val) => (0, Some(val.into_value()?)),
            MediaItem::Album(val) => (1, Some(val.into_value()?)),
            MediaItem::Artist(val) => (2, Some(val.into_value()?)),
        };

        let variant = Variant::new(variant_type, discriminant, payload)?;
        Ok(Value::Variant(variant))
    }
}

impl UnaryComponentType for MediaItem {}




#[derive(Debug, Clone)]
pub struct ChartSummary {
    pub id: String,
    pub title: String,
    pub description: Option<String>,
    pub thumbnail: Option<Artwork>,
}

impl ComponentType for ChartSummary {
    fn ty() -> ValueType {
        ValueType::Record(
            RecordType::new(
                None,
                [
                    ("id", ValueType::String),
                    ("title", ValueType::String),
                    ("description", ValueType::Option(OptionType::new(ValueType::String))),
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
            let description = record
                .field("description")
                .ok_or_else(|| anyhow!("Missing 'description' field"))?;
            let thumbnail = record
                .field("thumbnail")
                .ok_or_else(|| anyhow!("Missing 'thumbnail' field"))?;

            let id = if let Value::String(s) = id { s.to_string() } else { bail!("Expected string") };
            let title = if let Value::String(s) = title { s.to_string() } else { bail!("Expected string") };
            let description = Option::<String>::from_value(&description)?;
            let thumbnail = Option::<Artwork>::from_value(&thumbnail)?;

            Ok(ChartSummary {
                id,
                title,
                description,
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
                    ("description", ValueType::Option(OptionType::new(ValueType::String))),
                    ("thumbnail", ValueType::Option(OptionType::new(Artwork::ty()))),
                ],
            ).unwrap(),
            [
                ("id", Value::String(self.id.into())),
                ("title", Value::String(self.title.into())),
                ("description", self.description.into_value()?),
                ("thumbnail", self.thumbnail.into_value()?),
            ],
        )?;
        Ok(Value::Record(record))
    }
}

impl UnaryComponentType for ChartSummary {}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Trend {
    Up,
    Down,
    Same,
    NewEntry,
    Unknown,
}

impl ComponentType for Trend {
    fn ty() -> ValueType {
        ValueType::Enum(EnumType::new(None, [
            "up",
            "down",
            "same",
            "new-entry",
            "unknown",
        ]).unwrap())
    }

    fn from_value(value: &Value) -> Result<Self> {
        if let Value::Enum(enum_val) = value {
            let discriminant = enum_val.discriminant();
            match discriminant {
                0 => Ok(Trend::Up),
                1 => Ok(Trend::Down),
                2 => Ok(Trend::Same),
                3 => Ok(Trend::NewEntry),
                4 => Ok(Trend::Unknown),
                _ => bail!("Invalid enum discriminant: {}", discriminant),
            }
        } else {
            bail!("Expected Enum value")
        }
    }

    fn into_value(self) -> Result<Value> {
        let enum_type = EnumType::new(None, [
            "up",
            "down",
            "same",
            "new-entry",
            "unknown",
        ]).unwrap();

        let discriminant = match self {
            Trend::Up => 0,
            Trend::Down => 1,
            Trend::Same => 2,
            Trend::NewEntry => 3,
            Trend::Unknown => 4,
        };

        Ok(Value::Enum(Enum::new(enum_type, discriminant)?))
    }
}

impl UnaryComponentType for Trend {}

#[derive(Debug, Clone)]
pub struct ChartItem {
    pub item: MediaItem,
    pub rank: u32,
    pub trend: Trend,
    pub change: Option<u32>,
    pub peak_rank: Option<u32>,
    pub weeks_on_chart: Option<u32>,
}

impl ComponentType for ChartItem {
    fn ty() -> ValueType {
        ValueType::Record(
            RecordType::new(
                None,
                [
                    ("item", MediaItem::ty()),
                    ("rank", ValueType::U32),
                    ("trend", Trend::ty()),
                    ("change", ValueType::Option(OptionType::new(ValueType::U32))),
                    ("peak-rank", ValueType::Option(OptionType::new(ValueType::U32))),
                    ("weeks-on-chart", ValueType::Option(OptionType::new(ValueType::U32))),
                ],
            ).unwrap(),
        )
    }

    fn from_value(value: &Value) -> Result<Self> {
        if let Value::Record(record) = value {
            let item = record
                .field("item")
                .ok_or_else(|| anyhow!("Missing 'item' field"))?;
            let rank = record
                .field("rank")
                .ok_or_else(|| anyhow!("Missing 'rank' field"))?;
            let trend = record
                .field("trend")
                .ok_or_else(|| anyhow!("Missing 'trend' field"))?;
            let change = record
                .field("change")
                .ok_or_else(|| anyhow!("Missing 'change' field"))?;
            let peak_rank = record
                .field("peak-rank")
                .ok_or_else(|| anyhow!("Missing 'peak-rank' field"))?;
            let weeks_on_chart = record
                .field("weeks-on-chart")
                .ok_or_else(|| anyhow!("Missing 'weeks-on-chart' field"))?;

            let item = MediaItem::from_value(&item)?;
            let rank = if let Value::U32(x) = rank { x } else { bail!("Expected u32") };
            let trend = Trend::from_value(&trend)?;
            let change = Option::<u32>::from_value(&change)?;
            let peak_rank = Option::<u32>::from_value(&peak_rank)?;
            let weeks_on_chart = Option::<u32>::from_value(&weeks_on_chart)?;

            Ok(ChartItem {
                item,
                rank,
                trend,
                change,
                peak_rank,
                weeks_on_chart,
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
                    ("item", MediaItem::ty()),
                    ("rank", ValueType::U32),
                    ("trend", Trend::ty()),
                    ("change", ValueType::Option(OptionType::new(ValueType::U32))),
                    ("peak-rank", ValueType::Option(OptionType::new(ValueType::U32))),
                    ("weeks-on-chart", ValueType::Option(OptionType::new(ValueType::U32))),
                ],
            ).unwrap(),
            [
                ("item", self.item.into_value()?),
                ("rank", Value::U32(self.rank)),
                ("trend", self.trend.into_value()?),
                ("change", self.change.into_value()?),
                ("peak-rank", self.peak_rank.into_value()?),
                ("weeks-on-chart", self.weeks_on_chart.into_value()?),
            ],
        )?;
        Ok(Value::Record(record))
    }
}

impl UnaryComponentType for ChartItem {}





// ========== Host Imports ==========

/// Host trait for interface: component:chart-provider/utils
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
            .define_instance("component:chart-provider/utils".try_into().unwrap())
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

        Ok(())
    }

}

// ========== Guest Exports ==========

pub mod exports_types {
    use super::*;

    pub const INTERFACE_NAME: &str = "component:chart-provider/types";

}

pub mod exports_chart_api {
    use super::*;

    pub const INTERFACE_NAME: &str = "component:chart-provider/chart-api";

    #[allow(clippy::type_complexity)]
    pub fn get_get_charts<T, E: backend::WasmEngine>(
        instance: &Instance,
        _store: &mut Store<T, E>,
    ) -> Result<TypedFunc<(), Result<Vec<ChartSummary>, String>>> {
        let interface = instance
            .exports()
            .instance(&INTERFACE_NAME.try_into().unwrap())
            .ok_or_else(|| anyhow!("Interface not found"))?;

        interface
            .func("get-charts")
            .ok_or_else(|| anyhow!("Function 'get-charts' not found"))?
            .typed::<(), Result<Vec<ChartSummary>, String>>()
    }

    #[allow(clippy::type_complexity)]
    pub fn get_get_chart_details<T, E: backend::WasmEngine>(
        instance: &Instance,
        _store: &mut Store<T, E>,
    ) -> Result<TypedFunc<String, Result<Vec<ChartItem>, String>>> {
        let interface = instance
            .exports()
            .instance(&INTERFACE_NAME.try_into().unwrap())
            .ok_or_else(|| anyhow!("Interface not found"))?;

        interface
            .func("get-chart-details")
            .ok_or_else(|| anyhow!("Function 'get-chart-details' not found"))?
            .typed::<String, Result<Vec<ChartItem>, String>>()
    }

}

