# Bloomee

A cross-platform, plugin-first music player built with Flutter + Rust.

[![Release](https://img.shields.io/github/v/release/HemantKArya/BloomeeTunes?style=for-the-badge)](https://github.com/HemantKArya/BloomeeTunes/releases/latest)
[![GitHub Downloads](https://img.shields.io/github/downloads/HemantKArya/BloomeeTunes/total?style=for-the-badge)](https://github.com/HemantKArya/BloomeeTunes/releases)
[![License](https://img.shields.io/github/license/HemantKArya/BloomeeTunes?style=for-the-badge)](LICENSE)
[![CI](https://img.shields.io/github/actions/workflow/status/HemantKArya/BloomeeTunes/checkout.yml?style=for-the-badge)](https://github.com/HemantKArya/BloomeeTunes/actions)

[![Windows](https://img.shields.io/badge/Windows-Supported-0078D6?style=for-the-badge&logo=windows&logoColor=white)](#)
[![Android](https://img.shields.io/badge/Android-Supported-3DDC84?style=for-the-badge&logo=android&logoColor=white)](#)
[![Linux](https://img.shields.io/badge/Linux-Supported-FCC624?style=for-the-badge&logo=linux&logoColor=black)](#)

## Preview

![App Banner Placeholder](./assets/docs/README_PLACEHOLDER_BANNER.png)

![Desktop Placeholder](./assets/docs/README_PLACEHOLDER_DESKTOP.png)

![Mobile Placeholder](./assets/docs/README_PLACEHOLDER_MOBILE.png)

Replace the placeholder images above with updated screenshots before the next public release.

## Why Bloomee

- Plugin-first architecture with Rust-backed runtime.
- Cross-platform playback and queue experience.
- Typed plugin contracts for reliability and safer evolution.
- Modern, localization-ready Flutter UI.
- Open-source workflow with active release cadence.

## Highlights

- Plugin repository bootstrap and sync.
- Auto-update for installed plugins.
- Country-aware plugin allowlist handling.
- Search, charts, lyrics, suggestions, and importer plugin types.
- Smart fallback replacement for unavailable tracks.
- Cached plugin responses for faster home/chart/detail loads.
- Refined player engine with crossfade and robust error handling.
- Desktop keyboard shortcuts and interaction polish.
- Backup/restore, download management, and migration tooling.

## Plugin System Overview

Bloomee now routes content operations through installable plugins instead of hardcoded provider integrations.

### Plugin Types

- `contentResolver`: search, media details, stream resolution, home sections.
- `chartProvider`: charts and chart details.
- `lyricsProvider`: synced and plain lyrics.
- `searchSuggestionProvider`: query suggestions/autocomplete.
- `contentImporter`: import external collections into library/playlists.

### How It Works

1. App reads hosted repository index.
2. Repository manifests are downloaded and validated.
3. Required plugins are installed from `.bex` packages.
4. Installed plugins are loaded through the Rust plugin manager.
5. Blocs/services call typed plugin commands via the bridge layer.
6. Responses are cached and reused with stale-while-refresh behavior.

## Getting Started

### Download

- GitHub Releases: https://github.com/HemantKArya/BloomeeTunes/releases
- SourceForge: https://sourceforge.net/projects/bloomee/files/latest/download
- IzzyOnDroid: https://apt.izzysoft.de/fdroid/index/apk/ls.bloomee.musicplayer

### Development Setup

```bash
flutter pub get
flutter run
```

### Useful Commands

```bash
flutter analyze
flutter test
```

## Release Notes

- Full release history: [CHANGELOG.md](CHANGELOG.md)
- Architecture reference: [ARCHITECTURE.md](ARCHITECTURE.md)
- Contribution guide: [CONTRIBUTING.md](CONTRIBUTING.md)

## Support the Project

If Bloomee helps you, consider supporting ongoing maintenance and development.

- Liberapay: https://liberapay.com/hemantkarya/donate
- Sponsor links and campaign updates will be kept in project metadata and release notes.

## Contributing

Contributions are welcome.

1. Fork the repository.
2. Create a feature/fix branch.
3. Make focused changes with clear commit messages.
4. Run analyze/tests locally.
5. Open a PR with context and screenshots (if UI changes).

Please review [CONTRIBUTING.md](CONTRIBUTING.md) and [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) first.

## Contact

- LinkedIn: https://www.linkedin.com/in/iamhemantindia/
- X: https://x.com/iamhemantindia/
- Email: mailto:iamhemantindia@protonmail.com
