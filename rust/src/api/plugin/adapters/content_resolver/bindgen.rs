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
    pub url_low: Option<String>,
    pub url_high: Option<String>,
    pub layout: ImageLayout,
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
            let url_low = record
                .field("url-low")
                .ok_or_else(|| anyhow!("Missing 'url-low' field"))?;
            let url_high = record
                .field("url-high")
                .ok_or_else(|| anyhow!("Missing 'url-high' field"))?;
            let layout = record
                .field("layout")
                .ok_or_else(|| anyhow!("Missing 'layout' field"))?;

            let url = if let Value::String(s) = url { s.to_string() } else { bail!("Expected string") };
            let url_low = Option::<String>::from_value(&url_low)?;
            let url_high = Option::<String>::from_value(&url_high)?;
            let layout = ImageLayout::from_value(&layout)?;

            Ok(Artwork {
                url,
                url_low,
                url_high,
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
                    ("url-low", ValueType::Option(OptionType::new(ValueType::String))),
                    ("url-high", ValueType::Option(OptionType::new(ValueType::String))),
                    ("layout", ImageLayout::ty()),
                ],
            ).unwrap(),
            [
                ("url", Value::String(self.url.into())),
                ("url-low", self.url_low.into_value()?),
                ("url-high", self.url_high.into_value()?),
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
    pub thumbnail: Option<Artwork>,
    pub subtitle: Option<String>,
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
                    ("thumbnail", ValueType::Option(OptionType::new(Artwork::ty()))),
                    ("subtitle", ValueType::Option(OptionType::new(ValueType::String))),
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
            let thumbnail = record
                .field("thumbnail")
                .ok_or_else(|| anyhow!("Missing 'thumbnail' field"))?;
            let subtitle = record
                .field("subtitle")
                .ok_or_else(|| anyhow!("Missing 'subtitle' field"))?;
            let url = record
                .field("url")
                .ok_or_else(|| anyhow!("Missing 'url' field"))?;

            let id = if let Value::String(s) = id { s.to_string() } else { bail!("Expected string") };
            let name = if let Value::String(s) = name { s.to_string() } else { bail!("Expected string") };
            let thumbnail = Option::<Artwork>::from_value(&thumbnail)?;
            let subtitle = Option::<String>::from_value(&subtitle)?;
            let url = Option::<String>::from_value(&url)?;

            Ok(ArtistSummary {
                id,
                name,
                thumbnail,
                subtitle,
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
                    ("thumbnail", ValueType::Option(OptionType::new(Artwork::ty()))),
                    ("subtitle", ValueType::Option(OptionType::new(ValueType::String))),
                    ("url", ValueType::Option(OptionType::new(ValueType::String))),
                ],
            ).unwrap(),
            [
                ("id", Value::String(self.id.into())),
                ("name", Value::String(self.name.into())),
                ("thumbnail", self.thumbnail.into_value()?),
                ("subtitle", self.subtitle.into_value()?),
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
    pub thumbnail: Option<Artwork>,
    pub subtitle: Option<String>,
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
                    ("thumbnail", ValueType::Option(OptionType::new(Artwork::ty()))),
                    ("subtitle", ValueType::Option(OptionType::new(ValueType::String))),
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
            let thumbnail = record
                .field("thumbnail")
                .ok_or_else(|| anyhow!("Missing 'thumbnail' field"))?;
            let subtitle = record
                .field("subtitle")
                .ok_or_else(|| anyhow!("Missing 'subtitle' field"))?;
            let year = record
                .field("year")
                .ok_or_else(|| anyhow!("Missing 'year' field"))?;
            let url = record
                .field("url")
                .ok_or_else(|| anyhow!("Missing 'url' field"))?;

            let id = if let Value::String(s) = id { s.to_string() } else { bail!("Expected string") };
            let title = if let Value::String(s) = title { s.to_string() } else { bail!("Expected string") };
            let artists = Vec::<ArtistSummary>::from_value(&artists)?;
            let thumbnail = Option::<Artwork>::from_value(&thumbnail)?;
            let subtitle = Option::<String>::from_value(&subtitle)?;
            let year = Option::<u32>::from_value(&year)?;
            let url = Option::<String>::from_value(&url)?;

            Ok(AlbumSummary {
                id,
                title,
                artists,
                thumbnail,
                subtitle,
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
                    ("thumbnail", ValueType::Option(OptionType::new(Artwork::ty()))),
                    ("subtitle", ValueType::Option(OptionType::new(ValueType::String))),
                    ("year", ValueType::Option(OptionType::new(ValueType::U32))),
                    ("url", ValueType::Option(OptionType::new(ValueType::String))),
                ],
            ).unwrap(),
            [
                ("id", Value::String(self.id.into())),
                ("title", Value::String(self.title.into())),
                ("artists", self.artists.into_value()?),
                ("thumbnail", self.thumbnail.into_value()?),
                ("subtitle", self.subtitle.into_value()?),
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
    pub thumbnail: Artwork,
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
                    ("thumbnail", Artwork::ty()),
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
            let thumbnail = record
                .field("thumbnail")
                .ok_or_else(|| anyhow!("Missing 'thumbnail' field"))?;
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
            let thumbnail = Artwork::from_value(&thumbnail)?;
            let url = Option::<String>::from_value(&url)?;
            let is_explicit = if let Value::Bool(x) = is_explicit { x } else { bail!("Expected bool") };
            let lyrics = Option::<Lyrics>::from_value(&lyrics)?;

            Ok(Track {
                id,
                title,
                artists,
                album,
                duration_ms,
                thumbnail,
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
                    ("thumbnail", Artwork::ty()),
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
                ("thumbnail", self.thumbnail.into_value()?),
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
    pub thumbnail: Artwork,
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
                    ("thumbnail", Artwork::ty()),
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
            let thumbnail = record
                .field("thumbnail")
                .ok_or_else(|| anyhow!("Missing 'thumbnail' field"))?;
            let url = record
                .field("url")
                .ok_or_else(|| anyhow!("Missing 'url' field"))?;

            let id = if let Value::String(s) = id { s.to_string() } else { bail!("Expected string") };
            let title = if let Value::String(s) = title { s.to_string() } else { bail!("Expected string") };
            let owner = Option::<String>::from_value(&owner)?;
            let thumbnail = Artwork::from_value(&thumbnail)?;
            let url = Option::<String>::from_value(&url)?;

            Ok(PlaylistSummary {
                id,
                title,
                owner,
                thumbnail,
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
                    ("thumbnail", Artwork::ty()),
                    ("url", ValueType::Option(OptionType::new(ValueType::String))),
                ],
            ).unwrap(),
            [
                ("id", Value::String(self.id.into())),
                ("title", Value::String(self.title.into())),
                ("owner", self.owner.into_value()?),
                ("thumbnail", self.thumbnail.into_value()?),
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
pub struct PagedTracks {
    pub items: Vec<Track>,
    pub next_page_token: Option<String>,
}

impl ComponentType for PagedTracks {
    fn ty() -> ValueType {
        ValueType::Record(
            RecordType::new(
                None,
                [
                    ("items", ValueType::List(ListType::new(Track::ty()))),
                    ("next-page-token", ValueType::Option(OptionType::new(ValueType::String))),
                ],
            ).unwrap(),
        )
    }

    fn from_value(value: &Value) -> Result<Self> {
        if let Value::Record(record) = value {
            let items = record
                .field("items")
                .ok_or_else(|| anyhow!("Missing 'items' field"))?;
            let next_page_token = record
                .field("next-page-token")
                .ok_or_else(|| anyhow!("Missing 'next-page-token' field"))?;

            let items = Vec::<Track>::from_value(&items)?;
            let next_page_token = Option::<String>::from_value(&next_page_token)?;

            Ok(PagedTracks {
                items,
                next_page_token,
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
                    ("items", ValueType::List(ListType::new(Track::ty()))),
                    ("next-page-token", ValueType::Option(OptionType::new(ValueType::String))),
                ],
            ).unwrap(),
            [
                ("items", self.items.into_value()?),
                ("next-page-token", self.next_page_token.into_value()?),
            ],
        )?;
        Ok(Value::Record(record))
    }
}

impl UnaryComponentType for PagedTracks {}


#[derive(Debug, Clone)]
pub struct PagedAlbums {
    pub items: Vec<AlbumSummary>,
    pub next_page_token: Option<String>,
}

impl ComponentType for PagedAlbums {
    fn ty() -> ValueType {
        ValueType::Record(
            RecordType::new(
                None,
                [
                    ("items", ValueType::List(ListType::new(AlbumSummary::ty()))),
                    ("next-page-token", ValueType::Option(OptionType::new(ValueType::String))),
                ],
            ).unwrap(),
        )
    }

    fn from_value(value: &Value) -> Result<Self> {
        if let Value::Record(record) = value {
            let items = record
                .field("items")
                .ok_or_else(|| anyhow!("Missing 'items' field"))?;
            let next_page_token = record
                .field("next-page-token")
                .ok_or_else(|| anyhow!("Missing 'next-page-token' field"))?;

            let items = Vec::<AlbumSummary>::from_value(&items)?;
            let next_page_token = Option::<String>::from_value(&next_page_token)?;

            Ok(PagedAlbums {
                items,
                next_page_token,
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
                    ("items", ValueType::List(ListType::new(AlbumSummary::ty()))),
                    ("next-page-token", ValueType::Option(OptionType::new(ValueType::String))),
                ],
            ).unwrap(),
            [
                ("items", self.items.into_value()?),
                ("next-page-token", self.next_page_token.into_value()?),
            ],
        )?;
        Ok(Value::Record(record))
    }
}

impl UnaryComponentType for PagedAlbums {}


#[derive(Debug, Clone)]
pub struct PagedMediaItems {
    pub items: Vec<MediaItem>,
    pub next_page_token: Option<String>,
}

impl ComponentType for PagedMediaItems {
    fn ty() -> ValueType {
        ValueType::Record(
            RecordType::new(
                None,
                [
                    ("items", ValueType::List(ListType::new(MediaItem::ty()))),
                    ("next-page-token", ValueType::Option(OptionType::new(ValueType::String))),
                ],
            ).unwrap(),
        )
    }

    fn from_value(value: &Value) -> Result<Self> {
        if let Value::Record(record) = value {
            let items = record
                .field("items")
                .ok_or_else(|| anyhow!("Missing 'items' field"))?;
            let next_page_token = record
                .field("next-page-token")
                .ok_or_else(|| anyhow!("Missing 'next-page-token' field"))?;

            let items = Vec::<MediaItem>::from_value(&items)?;
            let next_page_token = Option::<String>::from_value(&next_page_token)?;

            Ok(PagedMediaItems {
                items,
                next_page_token,
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
                    ("items", ValueType::List(ListType::new(MediaItem::ty()))),
                    ("next-page-token", ValueType::Option(OptionType::new(ValueType::String))),
                ],
            ).unwrap(),
            [
                ("items", self.items.into_value()?),
                ("next-page-token", self.next_page_token.into_value()?),
            ],
        )?;
        Ok(Value::Record(record))
    }
}

impl UnaryComponentType for PagedMediaItems {}










#[derive(Debug, Clone)]
pub struct AlbumDetails {
    pub summary: AlbumSummary,
    pub tracks: PagedTracks,
    pub description: Option<String>,
}

impl ComponentType for AlbumDetails {
    fn ty() -> ValueType {
        ValueType::Record(
            RecordType::new(
                None,
                [
                    ("summary", AlbumSummary::ty()),
                    ("tracks", PagedTracks::ty()),
                    ("description", ValueType::Option(OptionType::new(ValueType::String))),
                ],
            ).unwrap(),
        )
    }

    fn from_value(value: &Value) -> Result<Self> {
        if let Value::Record(record) = value {
            let summary = record
                .field("summary")
                .ok_or_else(|| anyhow!("Missing 'summary' field"))?;
            let tracks = record
                .field("tracks")
                .ok_or_else(|| anyhow!("Missing 'tracks' field"))?;
            let description = record
                .field("description")
                .ok_or_else(|| anyhow!("Missing 'description' field"))?;

            let summary = AlbumSummary::from_value(&summary)?;
            let tracks = PagedTracks::from_value(&tracks)?;
            let description = Option::<String>::from_value(&description)?;

            Ok(AlbumDetails {
                summary,
                tracks,
                description,
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
                    ("summary", AlbumSummary::ty()),
                    ("tracks", PagedTracks::ty()),
                    ("description", ValueType::Option(OptionType::new(ValueType::String))),
                ],
            ).unwrap(),
            [
                ("summary", self.summary.into_value()?),
                ("tracks", self.tracks.into_value()?),
                ("description", self.description.into_value()?),
            ],
        )?;
        Ok(Value::Record(record))
    }
}

impl UnaryComponentType for AlbumDetails {}



#[derive(Debug, Clone)]
pub struct ArtistDetails {
    pub summary: ArtistSummary,
    pub top_tracks: Vec<Track>,
    pub albums: PagedAlbums,
    pub related_artists: Vec<ArtistSummary>,
    pub description: Option<String>,
}

impl ComponentType for ArtistDetails {
    fn ty() -> ValueType {
        ValueType::Record(
            RecordType::new(
                None,
                [
                    ("summary", ArtistSummary::ty()),
                    ("top-tracks", ValueType::List(ListType::new(Track::ty()))),
                    ("albums", PagedAlbums::ty()),
                    ("related-artists", ValueType::List(ListType::new(ArtistSummary::ty()))),
                    ("description", ValueType::Option(OptionType::new(ValueType::String))),
                ],
            ).unwrap(),
        )
    }

    fn from_value(value: &Value) -> Result<Self> {
        if let Value::Record(record) = value {
            let summary = record
                .field("summary")
                .ok_or_else(|| anyhow!("Missing 'summary' field"))?;
            let top_tracks = record
                .field("top-tracks")
                .ok_or_else(|| anyhow!("Missing 'top-tracks' field"))?;
            let albums = record
                .field("albums")
                .ok_or_else(|| anyhow!("Missing 'albums' field"))?;
            let related_artists = record
                .field("related-artists")
                .ok_or_else(|| anyhow!("Missing 'related-artists' field"))?;
            let description = record
                .field("description")
                .ok_or_else(|| anyhow!("Missing 'description' field"))?;

            let summary = ArtistSummary::from_value(&summary)?;
            let top_tracks = Vec::<Track>::from_value(&top_tracks)?;
            let albums = PagedAlbums::from_value(&albums)?;
            let related_artists = Vec::<ArtistSummary>::from_value(&related_artists)?;
            let description = Option::<String>::from_value(&description)?;

            Ok(ArtistDetails {
                summary,
                top_tracks,
                albums,
                related_artists,
                description,
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
                    ("summary", ArtistSummary::ty()),
                    ("top-tracks", ValueType::List(ListType::new(Track::ty()))),
                    ("albums", PagedAlbums::ty()),
                    ("related-artists", ValueType::List(ListType::new(ArtistSummary::ty()))),
                    ("description", ValueType::Option(OptionType::new(ValueType::String))),
                ],
            ).unwrap(),
            [
                ("summary", self.summary.into_value()?),
                ("top-tracks", self.top_tracks.into_value()?),
                ("albums", self.albums.into_value()?),
                ("related-artists", self.related_artists.into_value()?),
                ("description", self.description.into_value()?),
            ],
        )?;
        Ok(Value::Record(record))
    }
}

impl UnaryComponentType for ArtistDetails {}

#[derive(Debug, Clone)]
pub struct PlaylistDetails {
    pub summary: PlaylistSummary,
    pub tracks: PagedTracks,
    pub description: Option<String>,
}

impl ComponentType for PlaylistDetails {
    fn ty() -> ValueType {
        ValueType::Record(
            RecordType::new(
                None,
                [
                    ("summary", PlaylistSummary::ty()),
                    ("tracks", PagedTracks::ty()),
                    ("description", ValueType::Option(OptionType::new(ValueType::String))),
                ],
            ).unwrap(),
        )
    }

    fn from_value(value: &Value) -> Result<Self> {
        if let Value::Record(record) = value {
            let summary = record
                .field("summary")
                .ok_or_else(|| anyhow!("Missing 'summary' field"))?;
            let tracks = record
                .field("tracks")
                .ok_or_else(|| anyhow!("Missing 'tracks' field"))?;
            let description = record
                .field("description")
                .ok_or_else(|| anyhow!("Missing 'description' field"))?;

            let summary = PlaylistSummary::from_value(&summary)?;
            let tracks = PagedTracks::from_value(&tracks)?;
            let description = Option::<String>::from_value(&description)?;

            Ok(PlaylistDetails {
                summary,
                tracks,
                description,
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
                    ("summary", PlaylistSummary::ty()),
                    ("tracks", PagedTracks::ty()),
                    ("description", ValueType::Option(OptionType::new(ValueType::String))),
                ],
            ).unwrap(),
            [
                ("summary", self.summary.into_value()?),
                ("tracks", self.tracks.into_value()?),
                ("description", self.description.into_value()?),
            ],
        )?;
        Ok(Value::Record(record))
    }
}

impl UnaryComponentType for PlaylistDetails {}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Quality {
    Low,
    Medium,
    High,
    Lossless,
}

impl ComponentType for Quality {
    fn ty() -> ValueType {
        ValueType::Enum(EnumType::new(None, [
            "low",
            "medium",
            "high",
            "lossless",
        ]).unwrap())
    }

    fn from_value(value: &Value) -> Result<Self> {
        if let Value::Enum(enum_val) = value {
            let discriminant = enum_val.discriminant();
            match discriminant {
                0 => Ok(Quality::Low),
                1 => Ok(Quality::Medium),
                2 => Ok(Quality::High),
                3 => Ok(Quality::Lossless),
                _ => bail!("Invalid enum discriminant: {}", discriminant),
            }
        } else {
            bail!("Expected Enum value")
        }
    }

    fn into_value(self) -> Result<Value> {
        let enum_type = EnumType::new(None, [
            "low",
            "medium",
            "high",
            "lossless",
        ]).unwrap();

        let discriminant = match self {
            Quality::Low => 0,
            Quality::Medium => 1,
            Quality::High => 2,
            Quality::Lossless => 3,
        };

        Ok(Value::Enum(Enum::new(enum_type, discriminant)?))
    }
}

impl UnaryComponentType for Quality {}

#[derive(Debug, Clone)]
pub struct StreamSource {
    pub url: String,
    pub quality: Quality,
    pub format: String,
    pub headers: Option<Vec<(String, String)>>,
    pub expires_at: Option<u64>,
}

impl ComponentType for StreamSource {
    fn ty() -> ValueType {
        ValueType::Record(
            RecordType::new(
                None,
                [
                    ("url", ValueType::String),
                    ("quality", Quality::ty()),
                    ("format", ValueType::String),
                    ("headers", ValueType::Option(OptionType::new(ValueType::List(ListType::new(ValueType::Tuple(TupleType::new(None, [ValueType::String, ValueType::String]))))))),
                    ("expires-at", ValueType::Option(OptionType::new(ValueType::U64))),
                ],
            ).unwrap(),
        )
    }

    fn from_value(value: &Value) -> Result<Self> {
        if let Value::Record(record) = value {
            let url = record
                .field("url")
                .ok_or_else(|| anyhow!("Missing 'url' field"))?;
            let quality = record
                .field("quality")
                .ok_or_else(|| anyhow!("Missing 'quality' field"))?;
            let format = record
                .field("format")
                .ok_or_else(|| anyhow!("Missing 'format' field"))?;
            let headers = record
                .field("headers")
                .ok_or_else(|| anyhow!("Missing 'headers' field"))?;
            let expires_at = record
                .field("expires-at")
                .ok_or_else(|| anyhow!("Missing 'expires-at' field"))?;

            let url = if let Value::String(s) = url { s.to_string() } else { bail!("Expected string") };
            let quality = Quality::from_value(&quality)?;
            let format = if let Value::String(s) = format { s.to_string() } else { bail!("Expected string") };
            let headers = Option::<Vec::<(String, String)>>::from_value(&headers)?;
            let expires_at = Option::<u64>::from_value(&expires_at)?;

            Ok(StreamSource {
                url,
                quality,
                format,
                headers,
                expires_at,
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
                    ("quality", Quality::ty()),
                    ("format", ValueType::String),
                    ("headers", ValueType::Option(OptionType::new(ValueType::List(ListType::new(ValueType::Tuple(TupleType::new(None, [ValueType::String, ValueType::String]))))))),
                    ("expires-at", ValueType::Option(OptionType::new(ValueType::U64))),
                ],
            ).unwrap(),
            [
                ("url", Value::String(self.url.into())),
                ("quality", self.quality.into_value()?),
                ("format", Value::String(self.format.into())),
                ("headers", self.headers.into_value()?),
                ("expires-at", self.expires_at.into_value()?),
            ],
        )?;
        Ok(Value::Record(record))
    }
}

impl UnaryComponentType for StreamSource {}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum SearchFilter {
    All,
    Track,
    Album,
    Artist,
    Playlist,
}

impl ComponentType for SearchFilter {
    fn ty() -> ValueType {
        ValueType::Enum(EnumType::new(None, [
            "all",
            "track",
            "album",
            "artist",
            "playlist",
        ]).unwrap())
    }

    fn from_value(value: &Value) -> Result<Self> {
        if let Value::Enum(enum_val) = value {
            let discriminant = enum_val.discriminant();
            match discriminant {
                0 => Ok(SearchFilter::All),
                1 => Ok(SearchFilter::Track),
                2 => Ok(SearchFilter::Album),
                3 => Ok(SearchFilter::Artist),
                4 => Ok(SearchFilter::Playlist),
                _ => bail!("Invalid enum discriminant: {}", discriminant),
            }
        } else {
            bail!("Expected Enum value")
        }
    }

    fn into_value(self) -> Result<Value> {
        let enum_type = EnumType::new(None, [
            "all",
            "track",
            "album",
            "artist",
            "playlist",
        ]).unwrap();

        let discriminant = match self {
            SearchFilter::All => 0,
            SearchFilter::Track => 1,
            SearchFilter::Album => 2,
            SearchFilter::Artist => 3,
            SearchFilter::Playlist => 4,
        };

        Ok(Value::Enum(Enum::new(enum_type, discriminant)?))
    }
}

impl UnaryComponentType for SearchFilter {}










#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum SectionType {
    Carousel,
    Grid,
    Vlist,
}

impl ComponentType for SectionType {
    fn ty() -> ValueType {
        ValueType::Enum(EnumType::new(None, [
            "carousel",
            "grid",
            "vlist",
        ]).unwrap())
    }

    fn from_value(value: &Value) -> Result<Self> {
        if let Value::Enum(enum_val) = value {
            let discriminant = enum_val.discriminant();
            match discriminant {
                0 => Ok(SectionType::Carousel),
                1 => Ok(SectionType::Grid),
                2 => Ok(SectionType::Vlist),
                _ => bail!("Invalid enum discriminant: {}", discriminant),
            }
        } else {
            bail!("Expected Enum value")
        }
    }

    fn into_value(self) -> Result<Value> {
        let enum_type = EnumType::new(None, [
            "carousel",
            "grid",
            "vlist",
        ]).unwrap();

        let discriminant = match self {
            SectionType::Carousel => 0,
            SectionType::Grid => 1,
            SectionType::Vlist => 2,
        };

        Ok(Value::Enum(Enum::new(enum_type, discriminant)?))
    }
}

impl UnaryComponentType for SectionType {}


#[derive(Debug, Clone)]
pub struct Section {
    pub id: String,
    pub title: String,
    pub subtitle: Option<String>,
    pub card_type: SectionType,
    pub items: Vec<MediaItem>,
    pub more_link: Option<String>,
}

impl ComponentType for Section {
    fn ty() -> ValueType {
        ValueType::Record(
            RecordType::new(
                None,
                [
                    ("id", ValueType::String),
                    ("title", ValueType::String),
                    ("subtitle", ValueType::Option(OptionType::new(ValueType::String))),
                    ("card-type", SectionType::ty()),
                    ("items", ValueType::List(ListType::new(MediaItem::ty()))),
                    ("more-link", ValueType::Option(OptionType::new(ValueType::String))),
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
            let card_type = record
                .field("card-type")
                .ok_or_else(|| anyhow!("Missing 'card-type' field"))?;
            let items = record
                .field("items")
                .ok_or_else(|| anyhow!("Missing 'items' field"))?;
            let more_link = record
                .field("more-link")
                .ok_or_else(|| anyhow!("Missing 'more-link' field"))?;

            let id = if let Value::String(s) = id { s.to_string() } else { bail!("Expected string") };
            let title = if let Value::String(s) = title { s.to_string() } else { bail!("Expected string") };
            let subtitle = Option::<String>::from_value(&subtitle)?;
            let card_type = SectionType::from_value(&card_type)?;
            let items = Vec::<MediaItem>::from_value(&items)?;
            let more_link = Option::<String>::from_value(&more_link)?;

            Ok(Section {
                id,
                title,
                subtitle,
                card_type,
                items,
                more_link,
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
                    ("card-type", SectionType::ty()),
                    ("items", ValueType::List(ListType::new(MediaItem::ty()))),
                    ("more-link", ValueType::Option(OptionType::new(ValueType::String))),
                ],
            ).unwrap(),
            [
                ("id", Value::String(self.id.into())),
                ("title", Value::String(self.title.into())),
                ("subtitle", self.subtitle.into_value()?),
                ("card-type", self.card_type.into_value()?),
                ("items", self.items.into_value()?),
                ("more-link", self.more_link.into_value()?),
            ],
        )?;
        Ok(Value::Record(record))
    }
}

impl UnaryComponentType for Section {}




// ========== Host Imports ==========

/// Host trait for interface: component:content-resolver/utils
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
            .define_instance("component:content-resolver/utils".try_into().unwrap())
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

    pub const INTERFACE_NAME: &str = "component:content-resolver/types";

}

pub mod exports_data_source {
    use super::*;

    pub const INTERFACE_NAME: &str = "component:content-resolver/data-source";

    #[allow(clippy::type_complexity)]
    pub fn get_get_album_details<T, E: backend::WasmEngine>(
        instance: &Instance,
        _store: &mut Store<T, E>,
    ) -> Result<TypedFunc<String, Result<AlbumDetails, String>>> {
        let interface = instance
            .exports()
            .instance(&INTERFACE_NAME.try_into().unwrap())
            .ok_or_else(|| anyhow!("Interface not found"))?;

        interface
            .func("get-album-details")
            .ok_or_else(|| anyhow!("Function 'get-album-details' not found"))?
            .typed::<String, Result<AlbumDetails, String>>()
    }

    #[allow(clippy::type_complexity)]
    pub fn get_more_album_tracks<T, E: backend::WasmEngine>(
        instance: &Instance,
        _store: &mut Store<T, E>,
    ) -> Result<TypedFunc<(String, String), Result<PagedTracks, String>>> {
        let interface = instance
            .exports()
            .instance(&INTERFACE_NAME.try_into().unwrap())
            .ok_or_else(|| anyhow!("Interface not found"))?;

        interface
            .func("more-album-tracks")
            .ok_or_else(|| anyhow!("Function 'more-album-tracks' not found"))?
            .typed::<(String, String), Result<PagedTracks, String>>()
    }

    #[allow(clippy::type_complexity)]
    pub fn get_get_artist_details<T, E: backend::WasmEngine>(
        instance: &Instance,
        _store: &mut Store<T, E>,
    ) -> Result<TypedFunc<String, Result<ArtistDetails, String>>> {
        let interface = instance
            .exports()
            .instance(&INTERFACE_NAME.try_into().unwrap())
            .ok_or_else(|| anyhow!("Interface not found"))?;

        interface
            .func("get-artist-details")
            .ok_or_else(|| anyhow!("Function 'get-artist-details' not found"))?
            .typed::<String, Result<ArtistDetails, String>>()
    }

    #[allow(clippy::type_complexity)]
    pub fn get_more_artist_albums<T, E: backend::WasmEngine>(
        instance: &Instance,
        _store: &mut Store<T, E>,
    ) -> Result<TypedFunc<(String, String), Result<PagedAlbums, String>>> {
        let interface = instance
            .exports()
            .instance(&INTERFACE_NAME.try_into().unwrap())
            .ok_or_else(|| anyhow!("Interface not found"))?;

        interface
            .func("more-artist-albums")
            .ok_or_else(|| anyhow!("Function 'more-artist-albums' not found"))?
            .typed::<(String, String), Result<PagedAlbums, String>>()
    }

    #[allow(clippy::type_complexity)]
    pub fn get_get_playlist_details<T, E: backend::WasmEngine>(
        instance: &Instance,
        _store: &mut Store<T, E>,
    ) -> Result<TypedFunc<String, Result<PlaylistDetails, String>>> {
        let interface = instance
            .exports()
            .instance(&INTERFACE_NAME.try_into().unwrap())
            .ok_or_else(|| anyhow!("Interface not found"))?;

        interface
            .func("get-playlist-details")
            .ok_or_else(|| anyhow!("Function 'get-playlist-details' not found"))?
            .typed::<String, Result<PlaylistDetails, String>>()
    }

    #[allow(clippy::type_complexity)]
    pub fn get_more_playlist_tracks<T, E: backend::WasmEngine>(
        instance: &Instance,
        _store: &mut Store<T, E>,
    ) -> Result<TypedFunc<(String, String), Result<PagedTracks, String>>> {
        let interface = instance
            .exports()
            .instance(&INTERFACE_NAME.try_into().unwrap())
            .ok_or_else(|| anyhow!("Interface not found"))?;

        interface
            .func("more-playlist-tracks")
            .ok_or_else(|| anyhow!("Function 'more-playlist-tracks' not found"))?
            .typed::<(String, String), Result<PagedTracks, String>>()
    }

    #[allow(clippy::type_complexity)]
    pub fn get_get_streams<T, E: backend::WasmEngine>(
        instance: &Instance,
        _store: &mut Store<T, E>,
    ) -> Result<TypedFunc<String, Result<Vec<StreamSource>, String>>> {
        let interface = instance
            .exports()
            .instance(&INTERFACE_NAME.try_into().unwrap())
            .ok_or_else(|| anyhow!("Interface not found"))?;

        interface
            .func("get-streams")
            .ok_or_else(|| anyhow!("Function 'get-streams' not found"))?
            .typed::<String, Result<Vec<StreamSource>, String>>()
    }

    #[allow(clippy::type_complexity)]
    pub fn get_search<T, E: backend::WasmEngine>(
        instance: &Instance,
        _store: &mut Store<T, E>,
    ) -> Result<TypedFunc<(String, SearchFilter, Option<String>), Result<PagedMediaItems, String>>> {
        let interface = instance
            .exports()
            .instance(&INTERFACE_NAME.try_into().unwrap())
            .ok_or_else(|| anyhow!("Interface not found"))?;

        interface
            .func("search")
            .ok_or_else(|| anyhow!("Function 'search' not found"))?
            .typed::<(String, SearchFilter, Option<String>), Result<PagedMediaItems, String>>()
    }

    #[allow(clippy::type_complexity)]
    pub fn get_get_radio_tracks<T, E: backend::WasmEngine>(
        instance: &Instance,
        _store: &mut Store<T, E>,
    ) -> Result<TypedFunc<(String, Option<String>), Result<PagedTracks, String>>> {
        let interface = instance
            .exports()
            .instance(&INTERFACE_NAME.try_into().unwrap())
            .ok_or_else(|| anyhow!("Interface not found"))?;

        interface
            .func("get-radio-tracks")
            .ok_or_else(|| anyhow!("Function 'get-radio-tracks' not found"))?
            .typed::<(String, Option<String>), Result<PagedTracks, String>>()
    }

}

pub mod exports_discovery {
    use super::*;

    pub const INTERFACE_NAME: &str = "component:content-resolver/discovery";

    #[allow(clippy::type_complexity)]
    pub fn get_get_home_sections<T, E: backend::WasmEngine>(
        instance: &Instance,
        _store: &mut Store<T, E>,
    ) -> Result<TypedFunc<(), Result<Vec<Section>, String>>> {
        let interface = instance
            .exports()
            .instance(&INTERFACE_NAME.try_into().unwrap())
            .ok_or_else(|| anyhow!("Interface not found"))?;

        interface
            .func("get-home-sections")
            .ok_or_else(|| anyhow!("Function 'get-home-sections' not found"))?
            .typed::<(), Result<Vec<Section>, String>>()
    }

    #[allow(clippy::type_complexity)]
    pub fn get_load_more<T, E: backend::WasmEngine>(
        instance: &Instance,
        _store: &mut Store<T, E>,
    ) -> Result<TypedFunc<(String, String), Result<Vec<MediaItem>, String>>> {
        let interface = instance
            .exports()
            .instance(&INTERFACE_NAME.try_into().unwrap())
            .ok_or_else(|| anyhow!("Interface not found"))?;

        interface
            .func("load-more")
            .ok_or_else(|| anyhow!("Function 'load-more' not found"))?
            .typed::<(String, String), Result<Vec<MediaItem>, String>>()
    }

}

