## 6.0.0

- **Fixed compatibility with Flutter 3.44+**, where `IconData` became a `final` class and could no longer be extended ("The class 'IconData' can't be extended outside of its library because it's a final class").
- All 17,730 icon constants now use plain `IconData(...)` values, which work on every Flutter version from 3.10 through 3.44+.
- The old `XxxIconData` classes (e.g. `BootstrapIconData`) are now **type aliases** (`typedef XxxIconData = IconData`), so existing code that references them still compiles.
- Raised minimum SDK to Dart 3 / Flutter 3.10 and updated `flutter_lints` to v5.
- Verified all 15 font assets cover every icon codepoint used by the package, and all SVG asset paths referenced by `Brand`/`Flags`/`Flag` exist.
- Added an icon-set license table to the README.

## 5.0.0

- All exsiting icons sets are updated with the latest version
- AntDesign Icons Added
- Clarity Icons Added
- MingCute Icons Added
- TeenyIcons Added
- ZondIcons Added
- Now use `Brand` instead of `Logo`

## 4.0.0

- IconsPlus version 4.0.0 released.
- Bug fixes.
- Upadated existing icons packs with the latest version.
- Heroicons added.
- Iconsax added.
- Octicons added.

## 3.0.0

- New version released.
- Added more icons packs.
- Removed not working icons and bugs.
- Updated all icons packs to the latest version.

## 2.0.1

- Unidentified error fixed.

## 2.0.0

- Redesigned and more icon packs added.

## 1.0.2

- dartdoc comments added and some minor changes.

## 1.0.1

- Fixed some bugs.

## 1.0.0

- Beta release.
