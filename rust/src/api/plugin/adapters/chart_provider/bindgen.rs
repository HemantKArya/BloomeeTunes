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
pub enum ImageLayout {
    Square,
    Portrait,
    Landscape,
    Banner,
    Circular,
}

impl ComponentType for ImageLayout {
    fn ty() -> ValueType {
        ValueType::Enum(EnumType::new(None, [
            "square",
            "portrait",
            "landscape",
            "banner",
            "circular",
        ]).unwrap())
    }

    fn from_value(value: &Value) -> Result<Self> {
        if let Value::Enum(enum_val) = value {
            let discriminant = enum_val.discriminant();
            match discriminant {
                0 => Ok(ImageLayout::Square),
                1 => Ok(ImageLayout::Portrait),
                2 => Ok(ImageLayout::Landscape),
                3 => Ok(ImageLayout::Banner),
                4 => Ok(ImageLayout::Circular),
                _ => bail!("Invalid enum discriminant: {}", discriminant),
            }
        } else {
            bail!("Expected Enum value")
        }
    }

    fn into_value(self) -> Result<Value> {
        let enum_type = EnumType::new(None, [
            "square",
            "portrait",
            "landscape",
            "banner",
            "circular",
        ]).unwrap();

        let discriminant = match self {
            ImageLayout::Square => 0,
            ImageLayout::Portrait => 1,
            ImageLayout::Landscape => 2,
            ImageLayout::Banner => 3,
            ImageLayout::Circular => 4,
        };

        Ok(Value::Enum(Enum::new(enum_type, discriminant)?))
    }
}

impl UnaryComponentType for ImageLayout {}

#[derive(Debug, Clone)]
pub struct Artwork {
    pub url: String,
    pub layout: ImageLayout,
}

impl ComponentType for Artwork {
    fn ty() -> ValueType {
        ValueType::Record(
            RecordType::new(
                None,
                [
                    ("url", ValueType::String),
                    ("layout", ImageLayout::ty()),
                ],
            ).unwrap(),
        )
    }

    fn from_value(value: &Value) -> Result<Self> {
        if let Value::Record(record) = value {
            let url = record
                .field("url")
                .ok_or_else(|| anyhow!("Missing 'url' field"))?;
            let layout = record
                .field("layout")
                .ok_or_else(|| anyhow!("Missing 'layout' field"))?;

            let url = if let Value::String(s) = url { s.to_string() } else { bail!("Expected string") };
            let layout = ImageLayout::from_value(&layout)?;

            Ok(Artwork {
                url,
                layout,
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
                    ("layout", ImageLayout::ty()),
                ],
            ).unwrap(),
            [
                ("url", Value::String(self.url.into())),
                ("layout", self.layout.into_value()?),
            ],
        )?;
        Ok(Value::Record(record))
    }
}

impl UnaryComponentType for Artwork {}


#[derive(Debug, Clone)]
pub struct ArtistSummary {
    pub id: String,
    pub name: String,
    pub thumbnails: Vec<Artwork>,
    pub url: Option<String>,
}

impl ComponentType for ArtistSummary {
    fn ty() -> ValueType {
        ValueType::Record(
            RecordType::new(
                None,
                [
                    ("id", ValueType::String),
                    ("name", ValueType::String),
                    ("thumbnails", ValueType::List(ListType::new(Artwork::ty()))),
                    ("url", ValueType::Option(OptionType::new(ValueType::String))),
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
            let thumbnails = record
                .field("thumbnails")
                .ok_or_else(|| anyhow!("Missing 'thumbnails' field"))?;
            let url = record
                .field("url")
                .ok_or_else(|| anyhow!("Missing 'url' field"))?;

            let id = if let Value::String(s) = id { s.to_string() } else { bail!("Expected string") };
            let name = if let Value::String(s) = name { s.to_string() } else { bail!("Expected string") };
            let thumbnails = Vec::<Artwork>::from_value(&thumbnails)?;
            let url = Option::<String>::from_value(&url)?;

            Ok(ArtistSummary {
                id,
                name,
                thumbnails,
                url,
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
                    ("thumbnails", ValueType::List(ListType::new(Artwork::ty()))),
                    ("url", ValueType::Option(OptionType::new(ValueType::String))),
                ],
            ).unwrap(),
            [
                ("id", Value::String(self.id.into())),
                ("name", Value::String(self.name.into())),
                ("thumbnails", self.thumbnails.into_value()?),
                ("url", self.url.into_value()?),
            ],
        )?;
        Ok(Value::Record(record))
    }
}

impl UnaryComponentType for ArtistSummary {}


#[derive(Debug, Clone)]
pub struct AlbumSummary {
    pub id: String,
    pub title: String,
    pub artists: Vec<ArtistSummary>,
    pub thumbnails: Vec<Artwork>,
    pub year: Option<u32>,
    pub url: Option<String>,
}

impl ComponentType for AlbumSummary {
    fn ty() -> ValueType {
        ValueType::Record(
            RecordType::new(
                None,
                [
                    ("id", ValueType::String),
                    ("title", ValueType::String),
                    ("artists", ValueType::List(ListType::new(ArtistSummary::ty()))),
                    ("thumbnails", ValueType::List(ListType::new(Artwork::ty()))),
                    ("year", ValueType::Option(OptionType::new(ValueType::U32))),
                    ("url", ValueType::Option(OptionType::new(ValueType::String))),
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
            let thumbnails = record
                .field("thumbnails")
                .ok_or_else(|| anyhow!("Missing 'thumbnails' field"))?;
            let year = record
                .field("year")
                .ok_or_else(|| anyhow!("Missing 'year' field"))?;
            let url = record
                .field("url")
                .ok_or_else(|| anyhow!("Missing 'url' field"))?;

            let id = if let Value::String(s) = id { s.to_string() } else { bail!("Expected string") };
            let title = if let Value::String(s) = title { s.to_string() } else { bail!("Expected string") };
            let artists = Vec::<ArtistSummary>::from_value(&artists)?;
            let thumbnails = Vec::<Artwork>::from_value(&thumbnails)?;
            let year = Option::<u32>::from_value(&year)?;
            let url = Option::<String>::from_value(&url)?;

            Ok(AlbumSummary {
                id,
                title,
                artists,
                thumbnails,
                year,
                url,
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
                    ("artists", ValueType::List(ListType::new(ArtistSummary::ty()))),
                    ("thumbnails", ValueType::List(ListType::new(Artwork::ty()))),
                    ("year", ValueType::Option(OptionType::new(ValueType::U32))),
                    ("url", ValueType::Option(OptionType::new(ValueType::String))),
                ],
            ).unwrap(),
            [
                ("id", Value::String(self.id.into())),
                ("title", Value::String(self.title.into())),
                ("artists", self.artists.into_value()?),
                ("thumbnails", self.thumbnails.into_value()?),
                ("year", self.year.into_value()?),
                ("url", self.url.into_value()?),
            ],
        )?;
        Ok(Value::Record(record))
    }
}

impl UnaryComponentType for AlbumSummary {}

#[derive(Debug, Clone)]
pub struct Lyrics {
    pub plain: Option<String>,
    pub synced: Option<String>,
    pub copyright: Option<String>,
}

impl ComponentType for Lyrics {
    fn ty() -> ValueType {
        ValueType::Record(
            RecordType::new(
                None,
                [
                    ("plain", ValueType::Option(OptionType::new(ValueType::String))),
                    ("synced", ValueType::Option(OptionType::new(ValueType::String))),
                    ("copyright", ValueType::Option(OptionType::new(ValueType::String))),
                ],
            ).unwrap(),
        )
    }

    fn from_value(value: &Value) -> Result<Self> {
        if let Value::Record(record) = value {
            let plain = record
                .field("plain")
                .ok_or_else(|| anyhow!("Missing 'plain' field"))?;
            let synced = record
                .field("synced")
                .ok_or_else(|| anyhow!("Missing 'synced' field"))?;
            let copyright = record
                .field("copyright")
                .ok_or_else(|| anyhow!("Missing 'copyright' field"))?;

            let plain = Option::<String>::from_value(&plain)?;
            let synced = Option::<String>::from_value(&synced)?;
            let copyright = Option::<String>::from_value(&copyright)?;

            Ok(Lyrics {
                plain,
                synced,
                copyright,
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
                    ("synced", ValueType::Option(OptionType::new(ValueType::String))),
                    ("copyright", ValueType::Option(OptionType::new(ValueType::String))),
                ],
            ).unwrap(),
            [
                ("plain", self.plain.into_value()?),
                ("synced", self.synced.into_value()?),
                ("copyright", self.copyright.into_value()?),
            ],
        )?;
        Ok(Value::Record(record))
    }
}

impl UnaryComponentType for Lyrics {}




#[derive(Debug, Clone)]
pub struct Track {
    pub id: String,
    pub title: String,
    pub artists: Vec<ArtistSummary>,
    pub album: Option<AlbumSummary>,
    pub duration_ms: Option<u64>,
    pub thumbnails: Vec<Artwork>,
    pub url: Option<String>,
    pub is_explicit: bool,
    pub lyrics: Option<Lyrics>,
}

impl ComponentType for Track {
    fn ty() -> ValueType {
        ValueType::Record(
            RecordType::new(
                None,
                [
                    ("id", ValueType::String),
                    ("title", ValueType::String),
                    ("artists", ValueType::List(ListType::new(ArtistSummary::ty()))),
                    ("album", ValueType::Option(OptionType::new(AlbumSummary::ty()))),
                    ("duration-ms", ValueType::Option(OptionType::new(ValueType::U64))),
                    ("thumbnails", ValueType::List(ListType::new(Artwork::ty()))),
                    ("url", ValueType::Option(OptionType::new(ValueType::String))),
                    ("is-explicit", ValueType::Bool),
                    ("lyrics", ValueType::Option(OptionType::new(Lyrics::ty()))),
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
            let duration_ms = record
                .field("duration-ms")
                .ok_or_else(|| anyhow!("Missing 'duration-ms' field"))?;
            let thumbnails = record
                .field("thumbnails")
                .ok_or_else(|| anyhow!("Missing 'thumbnails' field"))?;
            let url = record
                .field("url")
                .ok_or_else(|| anyhow!("Missing 'url' field"))?;
            let is_explicit = record
                .field("is-explicit")
                .ok_or_else(|| anyhow!("Missing 'is-explicit' field"))?;
            let lyrics = record
                .field("lyrics")
                .ok_or_else(|| anyhow!("Missing 'lyrics' field"))?;

            let id = if let Value::String(s) = id { s.to_string() } else { bail!("Expected string") };
            let title = if let Value::String(s) = title { s.to_string() } else { bail!("Expected string") };
            let artists = Vec::<ArtistSummary>::from_value(&artists)?;
            let album = Option::<AlbumSummary>::from_value(&album)?;
            let duration_ms = Option::<u64>::from_value(&duration_ms)?;
            let thumbnails = Vec::<Artwork>::from_value(&thumbnails)?;
            let url = Option::<String>::from_value(&url)?;
            let is_explicit = if let Value::Bool(x) = is_explicit { x } else { bail!("Expected bool") };
            let lyrics = Option::<Lyrics>::from_value(&lyrics)?;

            Ok(Track {
                id,
                title,
                artists,
                album,
                duration_ms,
                thumbnails,
                url,
                is_explicit,
                lyrics,
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
                    ("artists", ValueType::List(ListType::new(ArtistSummary::ty()))),
                    ("album", ValueType::Option(OptionType::new(AlbumSummary::ty()))),
                    ("duration-ms", ValueType::Option(OptionType::new(ValueType::U64))),
                    ("thumbnails", ValueType::List(ListType::new(Artwork::ty()))),
                    ("url", ValueType::Option(OptionType::new(ValueType::String))),
                    ("is-explicit", ValueType::Bool),
                    ("lyrics", ValueType::Option(OptionType::new(Lyrics::ty()))),
                ],
            ).unwrap(),
            [
                ("id", Value::String(self.id.into())),
                ("title", Value::String(self.title.into())),
                ("artists", self.artists.into_value()?),
                ("album", self.album.into_value()?),
                ("duration-ms", self.duration_ms.into_value()?),
                ("thumbnails", self.thumbnails.into_value()?),
                ("url", self.url.into_value()?),
                ("is-explicit", Value::Bool(self.is_explicit)),
                ("lyrics", self.lyrics.into_value()?),
            ],
        )?;
        Ok(Value::Record(record))
    }
}

impl UnaryComponentType for Track {}

#[derive(Debug, Clone)]
pub struct PlaylistSummary {
    pub id: String,
    pub title: String,
    pub owner: Option<String>,
    pub thumbnails: Vec<Artwork>,
    pub track_count: Option<u32>,
    pub url: Option<String>,
}

impl ComponentType for PlaylistSummary {
    fn ty() -> ValueType {
        ValueType::Record(
            RecordType::new(
                None,
                [
                    ("id", ValueType::String),
                    ("title", ValueType::String),
                    ("owner", ValueType::Option(OptionType::new(ValueType::String))),
                    ("thumbnails", ValueType::List(ListType::new(Artwork::ty()))),
                    ("track-count", ValueType::Option(OptionType::new(ValueType::U32))),
                    ("url", ValueType::Option(OptionType::new(ValueType::String))),
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
            let owner = record
                .field("owner")
                .ok_or_else(|| anyhow!("Missing 'owner' field"))?;
            let thumbnails = record
                .field("thumbnails")
                .ok_or_else(|| anyhow!("Missing 'thumbnails' field"))?;
            let track_count = record
                .field("track-count")
                .ok_or_else(|| anyhow!("Missing 'track-count' field"))?;
            let url = record
                .field("url")
                .ok_or_else(|| anyhow!("Missing 'url' field"))?;

            let id = if let Value::String(s) = id { s.to_string() } else { bail!("Expected string") };
            let title = if let Value::String(s) = title { s.to_string() } else { bail!("Expected string") };
            let owner = Option::<String>::from_value(&owner)?;
            let thumbnails = Vec::<Artwork>::from_value(&thumbnails)?;
            let track_count = Option::<u32>::from_value(&track_count)?;
            let url = Option::<String>::from_value(&url)?;

            Ok(PlaylistSummary {
                id,
                title,
                owner,
                thumbnails,
                track_count,
                url,
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
                    ("owner", ValueType::Option(OptionType::new(ValueType::String))),
                    ("thumbnails", ValueType::List(ListType::new(Artwork::ty()))),
                    ("track-count", ValueType::Option(OptionType::new(ValueType::U32))),
                    ("url", ValueType::Option(OptionType::new(ValueType::String))),
                ],
            ).unwrap(),
            [
                ("id", Value::String(self.id.into())),
                ("title", Value::String(self.title.into())),
                ("owner", self.owner.into_value()?),
                ("thumbnails", self.thumbnails.into_value()?),
                ("track-count", self.track_count.into_value()?),
                ("url", self.url.into_value()?),
            ],
        )?;
        Ok(Value::Record(record))
    }
}

impl UnaryComponentType for PlaylistSummary {}

#[derive(Debug, Clone)]
pub enum MediaItem {
    Track(Track),
    Album(AlbumSummary),
    Artist(ArtistSummary),
    Playlist(PlaylistSummary),
}

impl ComponentType for MediaItem {
    fn ty() -> ValueType {
        ValueType::Variant(
            VariantType::new(
                None,
                [
                    VariantCase::new("track", Some(Track::ty())),
                    VariantCase::new("album", Some(AlbumSummary::ty())),
                    VariantCase::new("artist", Some(ArtistSummary::ty())),
                    VariantCase::new("playlist", Some(PlaylistSummary::ty())),
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
                        let converted = Track::from_value(&payload_value)?;
                        Ok(MediaItem::Track(converted))
                    } else {
                        bail!("Expected payload for track case")
                    }
                }
                "album" => {
                    if let Some(payload_value) = payload {
                        let converted = AlbumSummary::from_value(&payload_value)?;
                        Ok(MediaItem::Album(converted))
                    } else {
                        bail!("Expected payload for album case")
                    }
                }
                "artist" => {
                    if let Some(payload_value) = payload {
                        let converted = ArtistSummary::from_value(&payload_value)?;
                        Ok(MediaItem::Artist(converted))
                    } else {
                        bail!("Expected payload for artist case")
                    }
                }
                "playlist" => {
                    if let Some(payload_value) = payload {
                        let converted = PlaylistSummary::from_value(&payload_value)?;
                        Ok(MediaItem::Playlist(converted))
                    } else {
                        bail!("Expected payload for playlist case")
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
                VariantCase::new("track", Some(Track::ty())),
                VariantCase::new("album", Some(AlbumSummary::ty())),
                VariantCase::new("artist", Some(ArtistSummary::ty())),
                VariantCase::new("playlist", Some(PlaylistSummary::ty())),
            ],
        ).unwrap();

        let (discriminant, payload) = match self {
            MediaItem::Track(val) => (0, Some(val.into_value()?)),
            MediaItem::Album(val) => (1, Some(val.into_value()?)),
            MediaItem::Artist(val) => (2, Some(val.into_value()?)),
            MediaItem::Playlist(val) => (3, Some(val.into_value()?)),
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
    pub thumbnails: Vec<Artwork>,
    pub updated_at: Option<String>,
    pub period: Option<String>,
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
                    ("thumbnails", ValueType::List(ListType::new(Artwork::ty()))),
                    ("updated-at", ValueType::Option(OptionType::new(ValueType::String))),
                    ("period", ValueType::Option(OptionType::new(ValueType::String))),
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
            let thumbnails = record
                .field("thumbnails")
                .ok_or_else(|| anyhow!("Missing 'thumbnails' field"))?;
            let updated_at = record
                .field("updated-at")
                .ok_or_else(|| anyhow!("Missing 'updated-at' field"))?;
            let period = record
                .field("period")
                .ok_or_else(|| anyhow!("Missing 'period' field"))?;

            let id = if let Value::String(s) = id { s.to_string() } else { bail!("Expected string") };
            let title = if let Value::String(s) = title { s.to_string() } else { bail!("Expected string") };
            let description = Option::<String>::from_value(&description)?;
            let thumbnails = Vec::<Artwork>::from_value(&thumbnails)?;
            let updated_at = Option::<String>::from_value(&updated_at)?;
            let period = Option::<String>::from_value(&period)?;

            Ok(ChartSummary {
                id,
                title,
                description,
                thumbnails,
                updated_at,
                period,
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
                    ("thumbnails", ValueType::List(ListType::new(Artwork::ty()))),
                    ("updated-at", ValueType::Option(OptionType::new(ValueType::String))),
                    ("period", ValueType::Option(OptionType::new(ValueType::String))),
                ],
            ).unwrap(),
            [
                ("id", Value::String(self.id.into())),
                ("title", Value::String(self.title.into())),
                ("description", self.description.into_value()?),
                ("thumbnails", self.thumbnails.into_value()?),
                ("updated-at", self.updated_at.into_value()?),
                ("period", self.period.into_value()?),
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
    pub previous_rank: Option<u32>,
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
                    ("previous-rank", ValueType::Option(OptionType::new(ValueType::U32))),
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
            let previous_rank = record
                .field("previous-rank")
                .ok_or_else(|| anyhow!("Missing 'previous-rank' field"))?;
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
            let previous_rank = Option::<u32>::from_value(&previous_rank)?;
            let peak_rank = Option::<u32>::from_value(&peak_rank)?;
            let weeks_on_chart = Option::<u32>::from_value(&weeks_on_chart)?;

            Ok(ChartItem {
                item,
                rank,
                trend,
                change,
                previous_rank,
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
                    ("previous-rank", ValueType::Option(OptionType::new(ValueType::U32))),
                    ("peak-rank", ValueType::Option(OptionType::new(ValueType::U32))),
                    ("weeks-on-chart", ValueType::Option(OptionType::new(ValueType::U32))),
                ],
            ).unwrap(),
            [
                ("item", self.item.into_value()?),
                ("rank", Value::U32(self.rank)),
                ("trend", self.trend.into_value()?),
                ("change", self.change.into_value()?),
                ("previous-rank", self.previous_rank.into_value()?),
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

