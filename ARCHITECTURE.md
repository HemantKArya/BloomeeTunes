# Bloomee Architecture

> Authoritative reference for all contributors. All code must conform to the rules in this document.

## Table of Contents

1. [Layer Model](#1-layer-model)
2. [Layer Boundary Rules](#2-layer-boundary-rules)
3. [Directory Structure](#3-directory-structure)
4. [Data Layer](#4-data-layer)
5. [State Layer](#5-state-layer)
6. [Plugin System](#6-plugin-system)
7. [Plugin Response Cache](#7-plugin-response-cache)
8. [Service Layer](#8-service-layer)
9. [Update & Changelog Flow](#9-update--changelog-flow)
10. [Localization](#10-localization)
11. [Keyboard Shortcuts](#11-keyboard-shortcuts)
12. [Dependency Injection](#12-dependency-injection)
13. [Navigation](#13-navigation)

---

## 1. Layer Model

```
┌─────────────────────────────────────────────────┐
│                Screens / Widgets                │  UI
│   lib/screens/                                  │
├─────────────────────────────────────────────────┤
│               Blocs / Cubits                    │  State
│   lib/blocs/                                    │
├─────────────────────────────────────────────────┤
│               Repositories                      │  Domain
│   lib/repository/                               │
├─────────────────────────────────────────────────┤
│         DAOs  ·  Mappers  ·  DBProvider         │  Data
│   lib/services/db/                              │
├─────────────────────────────────────────────────┤
│               Isar (GlobalDB)                   │  Storage
│   lib/services/db/global_db.dart               │
└─────────────────────────────────────────────────┘
```

Flow: UI dispatches events → Bloc/Cubit → Repository (or DAO directly) → DB.  
No layer may import from a layer above it. No layer may skip more than one step downward.

---

## 2. Layer Boundary Rules

| # | Rule |
|---|------|
| 1 | **UI must not import** `global_db.dart`, any `dao/*.dart`, Isar types, or `mappers/*.dart`. |
| 2 | **UI must not instantiate** DAOs or services. All state comes through Cubit/Bloc. |
| 3 | **Bloc/Cubit state classes must not contain DB types** (`*DB`). State is a view-model; use domain types. |
| 4 | **Cubits may hold DAO references** (received via constructor) but must expose domain models in state. |
| 5 | **DAOs own all DB↔domain mapping**. Callers always receive domain objects, never Isar entities. |
| 6 | **Mappers are pure functions** — no side effects, no dependencies. Imported only by DAOs and repositories. |
| 7 | **One DAO per entity concern.** `PlaylistDAO` = user-playlist CRUD; `LibraryDAO` = saved remote collections. |
| 8 | **All Bloc/Cubit classes live under `lib/blocs/`**. Screen-scoped cubits that do not touch DAOs may live under `lib/screens/`. |
| 9 | **Plugins (`lib/plugins/`) must not access the DB layer directly.** They communicate through repositories or cubits. |
| 10 | **Services (`lib/services/`) are application-lifetime singletons** registered in `ServiceLocator`. Screens do not instantiate services. |

---

## 3. Directory Structure

```
lib/
├── blocs/             # Global and feature blocs/cubits
├── core/
│   ├── adapters/      # Type conversion helpers (e.g. MediaItem ↔ Track)
│   ├── constants/     # App-wide constants, setting keys, sentinel values
│   ├── di/            # ServiceLocator (get_it)
│   ├── events/        # GlobalEventBus (AppError stream)
│   ├── models/        # Domain model classes and enums
│   └── theme/         # App theme constants
├── l10n/              # ARB source files + generated AppLocalizations
├── plugins/
│   ├── blocs/         # ChartBloc, ContentBloc, PluginBloc
│   ├── models/        # ChartItem, Section, plugin-level models
│   └── screens/       # PluginManagerScreen
├── repository/        # Repositories orchestrating DAOs + API clients
├── routes/            # GoRouter config + route path constants
├── screens/
│   ├── screen/        # Full-page screens
│   └── widgets/       # Reusable widgets
└── services/
    ├── cache/         # PluginCacheStore, PluginCacheRepository, PluginCacheWriter
    ├── db/
    │   ├── dao/       # All DAO classes
    │   ├── global_db.dart
    │   ├── db_provider.dart
    │   └── mappers/   # Pure DB↔domain mapper functions
    ├── plugin/        # Plugin lifecycle, PluginEventBus, plugin storage
    └── player/        # Player engine, AudioSession
```

---

## 4. Data Layer

### DBProvider

- **Location**: `lib/services/db/db_provider.dart`
- Owns the Isar instance lifecycle, DB path, maintenance, backup/restore.
- Access: `await DBProvider.db` → `Isar`.
- Initialised once in `bootstrap.dart` via `await DBProvider.init()`.

### DAOs

| DAO | Responsibility |
|-----|----------------|
| `PlaylistDAO` | User-playlist CRUD, track add/remove/order, likes, search |
| `LibraryDAO` | Save/remove/query remote collections (artists, albums, remote playlists) |
| `TrackDAO` | Track upsert, lookup, search, orphan-purge |
| `HistoryDAO` | Playback history record/query/purge |
| `SettingsDAO` | Bool and String app settings with reactive watchers |
| `CacheDAO` | Link cache and plugin response cache persistence |
| `SearchHistoryDAO` | Search history with entry-count limit |
| `DownloadDAO` | Download job tracking |
| `NotificationDAO` | Notification persistence |
| `LyricsDAO` | Lyrics cache keyed by media ID |
| `PluginStorageDAO` | Per-plugin key-value persistent storage |

**Constructor pattern** — `const` constructors accept `Future<Isar>`:

```dart
PlaylistDAO(DBProvider.db, TrackDAO(DBProvider.db))
```

### Mappers

- **Location**: `lib/services/db/mappers/`
- Pure functions, no side effects. Imported **only by DAOs and repositories**.

| File | Converts |
|------|---------|
| `media_item_mapper.dart` | `Track` ↔ `TrackDB`, `ArtistSummary` ↔ `ArtistSummaryDB` |
| `playlist_mapper.dart` | `Playlist` ↔ `PlaylistDB`, `PlaylistType` ↔ `PlaylistTypeDB` |
| `collection_mapper.dart` | `ArtistSummary`/`AlbumSummary`/`PlaylistSummary` ↔ `PlaylistDB` |
| `lyrics_mapper.dart` | `Lyrics` ↔ `LyricsDB` |

---

## 5. State Layer

### Conventions

- State classes are **view-models**: only domain types, primitives, and enums — never Isar/DB types.
- States extend `Equatable` for efficient rebuild suppression.
- Cubits receive DAO/repository dependencies through constructor injection at `BlocProvider`.

### Domain enum example

```dart
// lib/core/models/media_playlist_model.dart
enum PlaylistType { userPlaylist, album, artist, remotePlaylist }

// UI display variant — cubits map DB enum → domain enum → this before emitting:
enum LibItemTypes { userPlaylist, onlPlaylist, artist, album }
```

UI never holds `PlaylistTypeDB`. All enum mapping happens inside DAO calls within cubits.

### Key global blocs

| Bloc/Cubit | Location | Purpose |
|---|---|---|
| `BloomeePlayerCubit` | `blocs/media_player/` | Wraps `BloomeeMusicPlayer`; exposes player state |
| `MiniPlayerCubit` | `blocs/mini_player/` | Playback status for the mini-player overlay |
| `LibraryItemsCubit` | `blocs/library/` | Library list with save/remove operations |
| `DownloaderCubit` | `blocs/downloader/` | Offline download queue |
| `SettingsCubit` | `blocs/settings/` | Reactive app settings |
| `GlobalEventsCubit` | `blocs/global_events/` | Update check, changelog, alert dialogs |
| `ShortcutIndicatorCubit` | `services/shortcut_indicator_service.dart` | Keyboard shortcut on-screen feedback |

---

## 6. Plugin System

Plugins are WebAssembly modules conforming to WIT-defined interfaces, compiled via the `bloomee_plugin_sdk`. The Rust layer (`rust/`) bridges Flutter and the WASM runtime.

### Plugin types

| Type | WIT interface | Purpose |
|---|---|---|
| `ContentResolver` | `content-resolver.wit` | Search, home sections, track URL resolution |
| `ChartProvider` | `chart-provider.wit` | Chart listings and metadata |
| `LyricsProvider` | `lyrics-provider.wit` | Lyrics fetching |
| `SuggestionProvider` | `suggestion-provider.wit` | Search autocomplete |

### Plugin lifecycle

1. **Install** — User picks `.bex` file → `PluginManagerScreen` calls `PluginService.install(path)`.
2. **Load** — Plugin compiled + registered with runtime; emits `PluginManagerEvent_PluginLoaded`.
3. **Use** — Blocs call plugin methods via `PluginService`; errors surface through `PluginEventBus`.
4. **Delete** — `PluginService.delete(id)` unloads and removes files; emits `PluginManagerEvent_PluginDeleted`.

### Event buses

**`PluginEventBus.instance.events`** — `Stream<PluginManagerEvent>`:
- `GlobalEventListener` listens for install/load/delete success/failure → localised snackbars.
- Individual plugin blocs listen for resolver availability changes.

**`GlobalEventBus.instance.errors`** — `Stream<AppError>` for structural errors:
- `PluginNotLoadedError`, `MalformedMediaIdError`, `PluginErrorEvent`, `NetworkFailureError`
- Handled by `GlobalEventListener._onAppError()` → rate-limited snackbar.

### Plugin storage

`PluginStorageDAO` provides per-plugin KV persistence. API keys entered in `PluginManagerScreen` are stored here and injected into the plugin runtime at load time.

---

## 7. Plugin Response Cache

Two-tier cache (L1 in-memory + L2 Isar) for expensive network calls made through WASM plugins.

```
 Bloc
  │
  ▼
 PluginCacheRepository
  ├─ L1: PluginCacheStore (typed in-memory LRU)
  │       chart_details · chart_list · home_sections
  └─ L2: CacheDAO + Isar (JSON blobs, survives restart)
              ▲ promoted on L2 hit
              debounced batch writes via PluginCacheWriter
```

**Read path**: L1 hit → return instantly. L1 miss → L2 lookup (decoded in isolate via `compute`) → promote to L1 → return `(value, isStale)`.

**Write path**: Insert into L1 immediately, queue for debounced batch L2 write. Flushed on app pause and low-memory lifecycle events.

**Stale-while-revalidate**: Blocs emit cached data immediately then refresh in the background when `isStale`. `ChartBloc` uses an 8-hour staleness threshold; `ContentBloc` uses 2 hours. `ForceRefresh*` events bypass the cache entirely.

**Cache keys**: `chart_list::<pluginId>`, `chart_cache::<pluginId>::<chartId>`, `home_sections::<pluginId>`.

**Location**: `lib/services/cache/`

---

## 8. Service Layer

Application-lifetime singletons registered in `ServiceLocator` (`get_it`).

| Service | Purpose |
|---|---|
| `BloomeeMusicPlayer` | Core audio engine wrapping `audio_service` |
| `PluginService` | WASM plugin runtime (load/unload/call) |
| `PluginCacheRepository` | Plugin response cache (L1 + L2) |
| `EqualizerService` | 10-band parametric EQ via FFmpeg |
| `LyricsService` | Lyrics fetch and sync |
| `SmartReplaceService` | Resolves dead/missing tracks using available plugins |
| `CrossfadeService` | Audio crossfade transitions |

---

## 9. Update & Changelog Flow

```
App start
  └─ GlobalEventsCubit.checkForUpdates()
       └─ getAppUpdates()          (services/bloomee_updater_tools.dart)
            ├─ GitHub Releases API
            └─ SourceForge fallback

            Result map keys:
              results   → bool: new version available
              newVer    → String: latest version name
              newBuild  → String: latest build number
              changelogs → String?: text if unread changelog exists
                  │
                  ├─ changelogs != null
                  │     → emit WhatIsNewState(changeLogs)
                  │     → GlobalEventListener: push ChangelogScreen(showOlderVersions: false)
                  │     → ChangelogScreen on first frame:
                  │           SettingsCubit.putSettingStr(SettingKeys.readChangelogs, label)
                  │
                  └─ results == true  &&  autoUpdateNotify setting == true
                        → emit UpdateAvailable(newVersion, newBuild, downloadUrl)
                        → GlobalEventListener: showBloomeeDialog with localised strings
                             ├─ "Later" → dismiss
                             └─ "Update Now" → launchUrl(downloadUrl)
```

**Changelog gate**: `changelogs` is populated only when the installed version equals the latest version (i.e. the user is up-to-date but hasn't seen the changelog) or on a fresh install that matches the latest release. The `readChangelogs` setting key prevents re-display on subsequent launches.

**`UpdateAvailable` state** carries `newVersion` and `newBuild` — no pre-formatted message string. The listener calls `l10n.updateAvailableBody(ver, build)` so the text is properly localised.

---

## 10. Localization

- **Format**: Flutter ARB — `lib/l10n/app_en.arb` (source), `lib/l10n/app_hi.arb` (Hindi).
- **Generated file**: `lib/l10n/app_localizations.dart` — do not edit manually.
- **Regenerate**: `flutter gen-l10n`
- **Access in widgets**: `AppLocalizations.of(context)!`

### Key naming conventions

| Prefix | Usage |
|--------|-------|
| `tooltip*` | `Tooltip.message` values |
| `snackbar*` | `SnackbarService.showMessage()` arguments |
| `button*` | Dialog/sheet action labels |
| `dialog*` | Dialog title or body strings |
| `player*` | Player-screen strings |
| `plugin*` | Plugin system user-visible messages |

**Rule**: All user-visible hardcoded strings must use `AppLocalizations`. Cubits and services that lack `BuildContext` must pass raw data (version numbers, IDs, names) to the UI layer so it can format user-facing text.

---

## 11. Keyboard Shortcuts

`KeyboardShortcutsHandler` is a `StatefulWidget` wrapping the app root. Its `State` registers a `HardwareKeyboard` global handler. Desktop-only; the handler is a no-op on mobile.

| Key | Action |
|-----|--------|
| Space | Play / Pause |
| → / ← | Seek ±5 s |
| Shift+→ / Shift+← | Next / Previous track |
| ↑ / ↓ | Volume ±5 % |
| L | Toggle like |
| S | Toggle shuffle |
| R | Cycle loop mode (Off → One → All) |

`ShortcutIndicatorCubit` drives transient on-screen feedback overlays rendered by `ShortcutsIndicatorWidget`.

---

## 12. Dependency Injection

Constructor injection through the `BlocProvider` tree in `main.dart`. `ServiceLocator` (get_it) for non-widget application singletons.

```dart
// BlocProvider pattern (main.dart)
BlocProvider(
  create: (_) => LibraryItemsCubit(
    playlistDao: PlaylistDAO(DBProvider.db, TrackDAO(DBProvider.db)),
    libraryDao: LibraryDAO(DBProvider.db),
  ),
),

// ServiceLocator pattern (core/di/service_locator.dart)
ServiceLocator.pluginCache    // PluginCacheRepository
ServiceLocator.pluginService  // PluginService
```

---

## 13. Navigation

- **Router**: GoRouter, configured in `lib/routes/app_router.dart`.
- **Route path constants**: `lib/routes/route_paths.dart`.
- **String constants**: `lib/core/constants/global_str_consts.dart`.
- **Deep links**: handled by GoRouter redirect logic.
- **Navigator key**: `GlobalKey<NavigatorState>` passed to `GlobalEventListener` for out-of-tree navigation (update dialogs, changelog screen pushed from within a cubit listener).

