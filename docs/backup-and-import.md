# Backup and import

Bloomee exports portable JSON. Internal recovery copies are compact Isar snapshots.
An Isar snapshot is an import source, never a replacement for the live database file.

## Ownership

- `BackupSettings` and `BackupImportFlow` present file actions, previews, confirmation, and progress.
- `BackupCubit` owns operation state and receives its repository and file transport through injection.
- `BackupRepository` serializes exports, recovery copies, import commits, reset requests, automatic-backup checks, and scheduled retention maintenance.
- `BackupFiles` handles the system picker, Save As, sharing, and bounded file staging.
- `BackupDAO` owns serialization and database mapping. It reads a consistent transaction snapshot and applies an import in one write transaction.
- Backup reads, validation, and import writes run in worker isolates with short-lived Isar connections. The main connection and subscriptions remain open.
- `DBProvider` opens only `dbv3` in application support storage and schedules ordinary retention maintenance. It does not search for legacy files, migrate old databases, or restore arbitrary fallback copies.

Startup migration runners, blocking migration overlays, legacy database schemas,
unused repair helpers and competing import implementations remain removed. The old
GitHub report has no confirmed upgrade path and is not evidence that the retired
pre-v3 migrator should be reintroduced.

## Missing library after an upgrade

**Storage > Recover missing library** (also available from the empty Offline tab)
uses the existing `BackupCubit` -> `BackupRepository` -> `BackupDAO` flow. It reads
retained v3 databases in support/documents storage and current-format recovery
snapshots. It does not discover `default.isar`, `.migrated` originals or run pre-v3
migration. Recovery DTOs live together in `recovery_copy.dart`; file-path resolution
is owned by the existing `DownloadDAO`. No separate recovery service or compatibility
schema is required.

The user selects a source, reviews counts and confirms a merge. The ordinary Recovery
copies action uses the same merge. `BackupDAO` stages copies and reads them on a worker
isolate. The repository snapshots the live database with `copyToFile` before inspecting
it. Original sources are never opened, renamed or deleted. A pre-import protection
snapshot must succeed before an atomic transaction adds missing tracks, entries and
download mappings. Repeating a merge does not duplicate entries or overwrite current
metadata, settings or download paths. Conflicting playlist types abort the whole merge.

Current-format snapshots retain ordering, likes, empty playlists and saved collections.
Unreferenced metadata is placed in a recovered playlist. Broken references are reported;
absent track identities cannot be reconstructed from a link alone. Local file mappings
return to Local Music, while remote downloads return to Downloads.

Download reads never prune records or playlist membership because a file is absent
or inaccessible. Exact paths and known Android/Apple container-relative relocations
are checked; there is no search by filename that could attach the wrong audio.
Unavailable mappings remain stored, allowing files to reappear after storage becomes
available. Path corrections compare the original row inside a transaction before
writing, protecting concurrent downloads/removals. File checks use batches of 32,
metadata lookups batches of 256, and embedded-artwork reads batches of 8.
Startup maintenance no longer purges unlinked track metadata: it may be the last
surviving evidence after a historical link-loss bug. Explicit playlist/track deletion
still performs its reference-checked cleanup.

The historical GitHub report cannot establish which earlier build was installed or
whether its audio files survived. 5.4 GB of app data is not proof of recoverable
audio. Do not recommend uninstalling or clearing app data before recovery: Android
removes app-specific files on uninstall. If no intact database or backup survives,
this flow cannot promise to restore original playlists. Scanning accessible audio
through Local Music can expose surviving files but does not reconstruct memberships.

Sources: [Isar schema/data migrations](https://isar.dev/recipes/data_migration.html),
[Android app-specific storage](https://developer.android.com/training/data-storage/app-specific).

Regression coverage uses v3 snapshots and tests source preservation, repeated merges,
rollback, missing files, container relocation, concurrent downloads/removals, broken
links, retired source exclusion, malformed databases, artwork-cache failure and a
1,001-song offline library. Physical-device upgrade verification remains required;
the historical report's OnePlus device is not available.

## JSON version 1

```json
{
  "format": "bloomee",
  "schemaVersion": 1,
  "kind": "backup",
  "createdAt": "2026-10-20T12:00:00.000Z",
  "tracks": [
    {
      "mediaId": "content-resolver.example::track-1",
      "title": "Example",
      "artists": [{"mediaId": "artist-1", "name": "Artist"}],
      "durationMs": 180000,
      "isExplicit": false
    }
  ],
  "playlists": [
    {
      "name": "Example playlist",
      "type": "userPlaylist",
      "entries": ["content-resolver.example::track-1"]
    }
  ],
  "history": [],
  "searchHistory": [],
  "settings": [{"key": "languageCode", "value": "en"}]
}
```

`kind` is `backup`, `playlist`, or `track`. Track and playlist sections are required for backups and playlists. A single-track document can omit playlists; the importer supplies the `Imported` destination. Playlist documents contain exactly one playlist, and track documents exactly one track. Optional sections are distinguished from present, empty sections. Unknown schema versions are rejected before mutation. Additional fields are tolerated for forward-compatible metadata.

Track metadata includes artists, album, artwork, duration, genre, language, and explicit status. Embedded artist/album/artwork maps preserve their identifiers, URLs, artwork layouts, and metadata. Playlists also preserve type, subtitle, description, artwork, artists, album/remote-collection metadata, pinning, sort order, and timestamps. Entry arrays explicitly preserve each playlist's independent ordering. Internal row IDs and Isar links are never exported.

Playlists use the application's existing case-insensitive name identity. Tracks use source-scoped media IDs. A renamed playlist on another device is a different playlist; there is no cross-device synchronization protocol.

Playback history records contain `mediaId` and UTC `playedAt`. Search-history records contain `query` and UTC `lastSearched`. Preferences contain `key` and a string or boolean `value`.

`BackupSettingsPolicy` explicitly allows portable preferences and validates their types and values. Credentials, plugin storage, repository URLs, startup flags, queue state, folder paths, URI grants, and backup scheduling state are excluded. Device-managed download/local-music playlists and audio files are excluded. Installing source plugins and locating local media remain device-specific actions.

JSON inputs are limited to 32 MiB, 100,000 records per array, 16 nested levels, and 1 MiB per string. Binary inputs are limited to 256 MiB. Limits are checked before commit. Exports are round-trip validated and must fit the supported JSON limit.

## Import behavior

All Settings, Library, Android Open With, and Android Share file actions use the same preview flow. A received file never silently commits an import.

- **New playlists:** choose unique names in the write transaction. Likes merge into the existing liked playlist. Preferences retain existing values.
- **Merge:** preserve existing metadata, playlist order, and preferences. Append missing tracks in incoming order. Search history retains the latest timestamp; playback history merges by event identity and occurrence count so repeated imports do not duplicate events.
- **Replace selected sections:** requires a second explicit confirmation. Replace portable library rows when library is selected, replace only present history sections, and replace allowlisted preferences when settings are selected. Device-managed playlists, downloads, plugin state, and unselected sections remain intact.

Legacy full JSON, legacy playlist JSON, and single-song JSON are adapted to the common document model. They support merge/new-copy imports. Replacement is disabled for legacy files because they cannot establish a complete portable-library snapshot. The preview warns that old full backups may lack per-playlist ordering or other data.

Binary snapshots are copied into a unique private staging directory, opened separately with compatible schemas, and converted to the same portable model. Snapshots with no recognized library data are rejected. Old incompatible binary databases require JSON export from the compatible original app version.

The repository creates and awaits a unique private recovery snapshot before import. Snapshot failure aborts the import. The write transaction either commits the selected data and native delivery receipt together, or rolls everything back. Startup does not need to swap files or run a repair routine after an interrupted import.

Native Android delivery receipts suppress replay of a committed inbox event. A later deliberate import of the same document remains possible. Restore refreshes settings, player preferences, and the current playlist. Library and history subscribers stay connected to the live Isar instance.

## Android transport

The active `MainActivity` extends `AudioServiceActivity`, retaining audio-service integration.
It handles VIEW from `intent.data`, SEND from `EXTRA_STREAM`, and all SEND_MULTIPLE attachments on both initial launch and `onNewIntent`.

The activity consumes `content://`/`file://` streams while permission is available and stages bounded copies in private cache. Pending markers let unhandled files survive an ordinary process restart while the cache remains available. Dart waits for onboarding, plugin bootstrap, and the navigator before displaying previews. A serial inbox prevents overlapping dialogs and acknowledges files after handling. Provider read failures are queued until Flutter can display them.

The picker has an all-files fallback because provider MIME labels and extensions vary. No URI is interpreted as a filesystem path. Save As uses the installed file picker's `ACTION_CREATE_DOCUMENT` implementation; its mobile return value is treated as an opaque locator. Sharing is a separate action. These follow Android's [Storage Access Framework](https://developer.android.com/training/data-storage/shared/documents-files).

Android cannot guarantee that every file manager offers Bloomee for an opaque URI with an incorrect MIME type. The in-app picker remains available for those files.

Flutter's default deep-link handler is explicitly disabled for this activity so
document URIs cannot also navigate GoRouter to an unknown route. This follows
[Flutter's custom-handler guidance](https://docs.flutter.dev/cookbook/navigation/set-up-app-links).
The previous `share_handler` dependency and shortcut metadata are removed;
ordinary shared URL text travels through the same native bridge without copying
every file a second time through another plugin.

## Recovery copies and reset

Recovery copies are visible from Storage settings and can be previewed/imported through the same pipeline. They contain private database data and stay in application support storage. Portable restore intentionally does not transplant credentials or device paths from these copies.

Automatic backup checks occur at app initialization and when automatic backup is enabled. They run at most once per 24 hours, handle a clock moving backward, serialize concurrent checks, and record success only after the snapshot completes. Seven completed automatic copies are retained. Seven successful pre-import copies are retained separately. Failed imports retain their protection copy.

Reset creates a protection copy and writes a versioned request referencing that copy. It is cancelable. Imports are blocked until a scheduled reset is canceled or completed. On next bootstrap, before services start, the request and protection file are checked, every collection is cleared in one transaction, and system playlists are recreated. Downloaded audio and installed plugin files are retained, as the confirmation explains. No live database connection is replaced underneath background workers.

App uninstall removes private recovery copies. Users should use Save As or Share for an external backup.

## Platform support and validation

| Platform | In-app pick / save / share | External file opening |
| --- | --- | --- |
| Android | System document picker, Save As, sharing | Native VIEW / SEND / SEND_MULTIPLE inbox |
| Windows | Platform picker, Save As, and file sharing | Existing executable file arguments are routed to import; installer associations are not registered by this change |
| Linux | Platform picker and Save As; file-sharing actions are hidden because the installed sharing plugin does not support files | Existing executable file arguments are routed to import; installer associations are not registered by this change |
| macOS | Existing platform implementations; user-selected read/write sandbox entitlement | Existing executable file arguments; Finder document associations are not registered by this change |
| iOS / iPadOS | Existing document picker/export and sharing implementations, with share-popover origin | Files/Open With registration is not added by this change |
| Web | Not supported by the app's current native Isar/Rust architecture | Not applicable |

Automated tests use actual Isar files and worker connections. Coverage includes ordering, likes, metadata/link preservation, atomic rollback, selective replacement, private-setting exclusion, failed protection, rotation, scheduling, delivery replay, named database ownership, reset, queue retention, watcher notifications, renamed JSON files, and playlist-load races. Inbox transport tests cover cold delivery, events arriving during processing, and interruption/retry.

Run `flutter test --no-pub -j 1`. Tests use a locally built Windows Isar DLL when available; other hosts can provide `ISAR_TEST_LIBRARY` or allow the version-matched Isar test library download. Do not run library-download tests concurrently.

Before release, exercise Android Files by Google, Samsung My Files, Downloads and cloud providers on physical devices: cold/warm/background delivery, onboarding delay, multiple attachments, picker cancellation, revoked grants, low storage, process death, and later deliberate re-import. Apple native builds and file-picker/share behavior require an Apple host. New localization keys currently fall back to English in untranslated locales.

The Android wrapper/plugin versions were aligned with the installed Flutter SDK's minimum requirements. Compatibility references: [Gradle 8.14.3](https://docs.gradle.org/8.14.3/release-notes.html) and [AGP 8.11](https://developer.android.com/build/releases/agp-8-11-0-release-notes).
