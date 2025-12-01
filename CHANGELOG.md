## [2.13.3] - 2025-12-01

### Added
- **Shortcut Pressed Indicator for Desktop**: Added visual indicator for pressed keyboard shortcuts on desktop platforms.
- **New Flavor Dev[Android]**: Introduced a new development flavor for Android builds.

### Fixed
- **What's New Font Family**: Fixed font family issues in the "What's New" section.
- **Keyboard Shortcut**: Resolved issues with keyboard shortcuts functionality.
- **Add to Playlist**: Fixed bugs in the add to playlist feature.
- **Player Disposer Problem**: Addressed player disposer issues on Realme, Oppo, and similar devices.

## [2.13.2] - 2025-11-30

### Added
- **Library Item Search Box**: Added search functionality for library items to improve navigation and discovery.
- **New Search in Playlist Database Function**: Implemented enhanced search capabilities within playlist databases.
- **DNS Checker**: Added DNS connectivity checking feature for better network diagnostics.
- **Touch Device Support**: Improved support for touch-based interactions across the application.
- **Redesigned Up Next Panel**: Completely redesigned the "Up Next" panel with modern UI elements.
- **Full Screen Lyrics Viewer**: Introduced a new full-screen lyrics viewing mode with enhanced display options.
- **Auto Scroll in Queue**: Automatic scroll to every song changed in the queue.

### Changed
- **New Progress Bar for Player**: Implemented a new progress bar design for the media player.
- **Up Next Panel and Song Tile Improvements**: Enhanced the "Up Next" panel and song tiles for better usability and appearance.
- **Ambient Background Enhancement**: Improved ambient background effects throughout the application.
- **Song Info UI Updates**: Updated the song information display interface for better readability.
- **Add to Playlist UI**: Redesigned the "Add to Playlist" feature with circular stacked avatars and improved layout.
- **Player Enhancements**: Various improvements to the media player functionality and user experience.
- **Custom Animated List**: Implemented custom animated lists for smoother UI transitions.
- **Subtitle Override in Song Model**: Added ability to override subtitles in song metadata.
- **Fullscreen Up Next Panel**: Made the fullscreen "Up Next" panel translucent for better visual integration.
- **Lyric Widget Enhancements**: Improved colors and icons in the lyrics widget.
- **Player UI Optimizations**: Optimized player interface for better performance and usability.
- **Gradient Adjustments**: Fine-tuned gradient effects in the player interface.
- **Media Kit Integration**: Switched to MediaKit for Android platform for improved media handling.

### Fixed
- **Font Fixes**: Resolved font rendering issues across the application.
- **Mini Player Fixes**: Fixed bleed and progress bar issues in the mini player.
- **Warning Fixes**: Addressed various deprecation warnings, including `.withOpacity` usage.
- **Full Screen Lyric View**: Corrected display issues in full-screen lyrics mode.
- **Auto Wake Controls**: Fixed auto-scroll behavior in wake controls.
- **Up Next Panel**: Resolved various issues with the "Up Next" panel functionality.
- **Desktop Handle Fix**: Fixed panel handle behavior on desktop platforms.
- **Player Reconfiguration**: Corrected player reconfiguration issues on Android.
- **JSON File Opening**: Partially addressed issues with JSON file handling (ongoing).

## [2.12.5] - 2025-10-25
- **Flutter Version Upgrade**: Updated Flutter version to 3.35.4 with CI/CD pipeline improvements.
- **Package Upgrades**: Updated various dependencies and packages for better performance and security.
- **Connectivity Improvements**: Enhanced connectivity handling after package upgrades.
- **YouTube Shared Music**: Added support for playing YouTube shared music links.
- **Audio Source Optimization**: Removed concatenating audio source usage for improved performance.
- **Network Failure Handling**: Added maximum limit of 10 retries before shifting to next song on network failures.
- **Track Recovery**: Improved track recovery when lost during network interruptions.
- **About Page Refactor**: Refactored the about section for better maintainability.
- **Color Analyzer**: Added new color analyzer functionality from URLs.
- **Chart Widget Fixes**: Fixed image display issues in chart widgets.
- **Billboard Image Fixes**: Resolved image loading issues in Billboard charts.

### Fixed
- **Isar Version Compatibility**: Fixed Isar database version compatibility issues.
- **Code Reverts**: Reverted problematic code changes to maintain stability.

## [2.12.4] - 2025-09-28

### Added
- **Bulk Download Feature**: Added the ability to select and download multiple songs from playlists at once.
- **Enhanced Queue Management**: Added `showPlayNext` and `showAddtoQueue` boolean controls for better UI customization.
- **Song Options in Up Next Panel**: Added song options menu in the "Up Next" panel for better track management.
- **Recently Played Tracking**: Implemented recently played tracking with configurable thresholds (40% playback or 15 seconds).
- **Trendshift Badge**: Added Trendshift badge to the project.

### Changed
- **Audio Service Updates**: Updated audio service configuration and handling.
- **Bulk Download UI Enhancements**: Improved the bulk download progress dialog and user experience.
- **Queue Title Broadcasting**: Fixed queue title override to properly broadcast updated queue titles.
- **Button Renaming**: Changed "Play Now" button to "Play with Mix" for clarity.
- **Player Error Handling**: Enhanced error handling for network-related playback issues.
- **Snackbar Improvements**: Enhanced snackbar notifications throughout the app.
- **Volume Control**: Fixed volume sliding on cover art for manual control.
- **YouTube Download Fix**: Temporary fix for YouTube downloading (requires future maintenance for youtube_explode_dart).
- **Restore Warning**: Clarified warning messages for restore operations.
- **Code Cleanup**: General code cleanup and optimizations.
- **Documentation Updates**: Updated README, GitHub Pages, and fastlane changelog.
- **Workflow Improvements**: Enhanced GitHub Actions workflows for better CI/CD.
- **Funding Information**: Updated funding URLs and configuration.

### Fixed
- **Bulk Download Snackbars**: Fixed snackbar notifications to show only one message for bulk downloads instead of individual messages per song.

## [2.12.3] - 2025-08-17

### Added
- **Windows Media Controls**: Implemented native media controls for Windows for a better desktop experience with `audio_service_win`.
- **Search in Downloads**: Added search functionality to the offline/downloads screen.
- **Changelog**: Added `CHANGELOG.md` for release notes and version history.
- **Changelog viewer**: In-app viewer that shows "what's new" after updates so users see release notes on first run after an update.
- **Global event notifier**: New global event cubit used for app-wide notifications and to drive the updated updater popup logic.
 - **Android: Backup sharing**: Added Android-specific sharing for backup JSON files so users can easily export/share backups from the app.

### Changed
- **Downloader Overhaul**: The download manager has been completely rewritten from the ground up, removing the `flutter_downloader` dependency. This new implementation enables downloads on desktop platforms and shows live progress on the downloads screen.
- **Backup & Restore Rework**: The backup and restore functionality has been completely rewritten to use a more reliable JSON format.
- **UI/UX Enhancements**:
    - Updated the app logo and various icons.
    - Improved themes and color schemes.
    - Redesigned and updated the "About" page to include the build number and small layout/text refinements.
    - Enhanced the Android notification thumbnail to a medium quality for better visuals.
- **Library Management**: Implemented a playlist watcher to keep the library in sync.
- **Player Modularization**: Refactored the core audio player code for better state management and maintainability.
- **Dependencies**: Upgraded Flutter, `flutter_bloc`, and the Android Gradle Plugin to their latest versions.
- **App updater**: Updated popup logic to use the new global event cubit and applied several updater fixes.
- **CI / Workflow**: Automatic version reading from `package.json` is enabled; Linux build number offset adjusted (+121) to align with Windows/Android.
- **Deploy script**: The deploy script now copies the changelog into the GitHub Pages build directory before force-pushes.
- **Docs & README**: Small README and documentation updates.
 - **Global footer animation**: Page animation in the global footer changed to a soft zoom-in transition for smoother navigation.
 - **YouTube service improvements**: Enhanced the YouTube service/provider for better reliability and performance (provider enhancements and multiple bug fixes).

### Fixed
- Resolved a bug with the 'like' button on album views.
- Fixed an issue preventing clicks on media items in the "Recently Played" section.
- Addressed loading problems on YouTube Music artist pages.
- Corrected the app updater logic and fixed a SourceForge header issue affecting Android updater requests.
- Fixed various UI bugs, including carousel alignment and button states.
 - Fixed play/pause not responding on first-time button press.
 - Fixed several UI issues: contrast adjustments, gradient box rendering, button state fixes, and small About-page fixes including back-pop navigation behavior.
 - Corrected Liberapay naming.

### Removed
- Removed the `flutter_downloader` package.
- Removed the `yt_streams` script.

## [2.11.6] - 2025-05-05

### Changed
- Refactored import/export functionality.
- General code cleanups and optimizations.

### Fixed
- Resolved issues with YouTube streaming.
- Addressed bugs related to YouTube playlists.

## [2.11.5] - 2025-03-17

### Changed
- Updated YouTube client and carousel functionality.
- Upgraded libraries and packages.

## [2.11.4] - 2025-03-16

### Changed
- Enhanced the "check related item" feature.
- User interface improvements for playlist and artist views.

### Fixed
- Addressed a bug in the YouTube Music API.
- Fixed an issue with the YouTube audio stream.

## [2.11.3] - 2025-03-08

### Added
- **Discord Rich Presence**: Show your current listening activity on Discord.

### Changed
- Updated Billboard charts integration.

### Removed
- Discontinued support for TikTok Top 50 chart from Billboard.

### Fixed
- Resolved issues with Discord Rich Presence integration.

## [2.11.2] - 2025-02-27

### Changed
- Redefined search suggestions for better accuracy.
- Upgraded the BLoC library.

### Fixed
- Corrected a bug in the `putSearchHistory` function.
- Fixed a bug related to spaces in search queries.

## [2.11.1] - 2025-02-25

### Added
- Implemented a setting for enabling/disabling autoplay.

### Fixed
- Resolved a bug preventing adding tracks to the queue.
- Fixed an issue with shuffle functionality in playlists.
- Corrected an app updater issue for ABI `versionCode`.

## [2.11.0] - 2025-02-24

### Added
- Implemented `YTAudioSource` for improved YouTube audio handling.
- Added new queue management functions.

### Changed
- Refactored the "Up Next" panel and player for better performance.
- Shifted to `media_kit` for Windows audio playback.

### Fixed
- Addressed bugs in the mini-player and "Up Next" animations.
- Re-enabled cleartext traffic for YouTube streams to resolve playback issues.

## [2.10.16] - 2025-02-17

### Changed
- Updated the `youtube_explode_dart` package.

## [2.10.15] - 2025-02-05

### Fixed
- Corrected formatting issues on the YouTube Music home screen.

## [2.10.14] - 2025-01-24

### Fixed
- Addressed a bug causing YouTube stream failures.

## [2.10.13] - 2025-01-16

### Changed
- Improved error handling to stop playback on player exceptions.
- Added a development "flavor" for better testing.

### Fixed
- Resolved a mini-player issue where it would show infinite loading on playback failure.

## [2.10.11] - 2024-12-26

### Changed
- Switched to `yt_streams` for handling YouTube streams.
- Improved caching mechanisms.

## [2.10.10] - 2024-12-23

### Changed
- Updated the YouTube API implementation.
- Refactored YouTube background link refreshing to run in a separate isolate for better performance.

## [2.10.9] - 2024-11-09

### Added
- Implemented an option to manually save lyrics.
- Added a settings option to auto-save lyrics.

### Changed
- Enhanced the lyrics search dialog.

## [2.10.8] - 2024-10-16

### Added
- Implemented mouse scrolling support for the volume bar on desktop.

### Changed
- Decreased the volume increment/decrement speed for finer control.

## [2.10.7] - 2024-10-11

### Fixed
- Addressed various bugs in the JioSaavn API integration.

## [2.10.6] - 2024-10-09

### Added
- Implemented swipe gestures (next/previous) on the mini-player.

### Changed
- Upgraded the `youtube_explode_dart` package.

## [2.10.5] - 2024-10-05

### Added
- Introduced a "Last.fm Picks" widget on the home screen.
- Implemented Last.fm authentication.

### Changed
- Enhanced the app updater functionality.

## [2.10.1] - 2024-10-04

### Added
- **Last.fm Scrobbling**: Automatically scrobble your played tracks to Last.fm, with offline caching for network failures.

### Changed
- Enabled seek controls in Android notifications.

## [2.9.13] - 2024-09-25

### Fixed
- Addressed a bug with YouTube links.
- Updated `youtube_explode_dart` to fix a critical bug.

## [2.9.12] - 2024-09-22

### Changed
- Ensured the same `versionCode` is used for all ABIs in APK builds.
- Added tooltips for better user experience.

### Fixed
- Disabled the download button on platforms other than Android.

## [2.9.11] - 2024-09-11

### Changed
- Moved the "get related songs" API call to a compute function to prevent UI blocking.

### Fixed
- Addressed a bug preventing songs from being added to playlists.

## [2.9.10] - 2024-09-11

### Changed
- Migrated the Isar database to a community fork (`isar_community`).

## [2.9.9] - 2024-09-03

### Fixed
- Addressed a database restoration issue for versions prior to 2.9.8.

## [2.9.8] - 2024-09-02

### Added
- Implemented a SourceForge version checker for app updates.
- **Save Online Media**: Added the ability to save online playlists, artists, and albums to your library.

### Changed
- Migrated the database path from `appDocumentPath` to `appSupportPath`.

## [2.9.6] - 2024-08-29

### Added
- Support for searching and viewing YouTube Music artists, albums, and playlists.
- Added a "more options" menu to song cards.

### Fixed
- Resolved bugs in the chart and artist views.

## [2.9.5] - 2024-08-16

### Changed
- Updated workflows to build split APKs per ABI for smaller app sizes.
- Improved image formatting and loading across the app.

### Fixed
- Addressed a bug in playlist editing.

## [2.9.3] - 2024-08-11

### Changed
- Migrated Flutter version from 3.19.x to 3.24.0.
- Improved the library screen UI and mini-player blur effect.
- Updated the playlist screen to use `SliverReorderableList` for a smoother experience.

## [2.9.2] - 2024-08-08

### Added
- Introduced a "view info" feature for playlists.
- Added a playing indicator to playlist tiles.

### Changed
- UI enhancements for the "like" button and player screen.

## [2.9.1] - 2024-08-06

### Added
- Implemented a settings option to select and manage external charts.
- **YouTube Music Importer**: Added the ability to import single tracks, albums, and playlists from YouTube Music.

## [2.8.3] - 2024-08-02

### Added
- **Lyrics**: Implemented a lyrics feature to view song lyrics within the app.
- **Linux Support**: Added experimental support for Linux using `media_kit` bindings.

## [2.8.2] - 2024-07-21

### Changed
- The update source has been shifted from GitHub to SourceForge.
- UI improvements for cover art and chart widgets.

### Fixed
- Resolved an issue with offline song downloads on Android 13 and 14.

## [2.8.0] - 2024-07-06

### Added
- **Windows Support**: Enabled official support for Windows desktop.

### Changed
- Made the player and navigation bar responsive for different screen sizes.

## [2.7.13] - 2024-05-14

### Fixed
- Addressed an issue where the mixed API search returned no results.

## [2.7.10] - 2024-04-26

### Added
- Implemented country-based music recommendations on the home page.
- Added a refresh indicator to the home page.

### Changed
- Implemented a volume slider.

## [2.7.7] - 2024-04-24

### Added
- Implemented a song information screen.

## [2.7.6] - 2024-04-21

### Added
- Implemented an "Up Next" sliding panel in the player screen.

## [2.7.5] - 2024-04-16

### Added
- Implemented shuffle and repeat modes.

## [2.7.2] - 2024-04-14

### Changed
- Re-implemented the mini-player using BLoC to fix bugs.

### Fixed
- Implemented a check for app updates and provided notifications.

## [2.7.0] - 2024-04-12

### Added
- **YouTube Home**: Integrated the YouTube Music homepage into the "Explore" tab.