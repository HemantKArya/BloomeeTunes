# icons_plus (Vendored)

A vendored, patched copy of the `icons_plus` package for BloomeeTune.

## Reason for Inclusion

- **Breaking Change Fix:** Flutter 3.27+ / Dart 3.7+ marked `IconData` as a `final class`, causing compilation errors across all icon classes that previously extended `IconData`. This version patches those classes to work with modern Flutter SDKs.
- **Upstream Deprecation / Inactivity:** The original upstream repository is inactive or removed, preventing official updates on pub.dev.

## Upstream References

- **Pub.dev:** [https://pub.dev/packages/icons_plus](https://pub.dev/packages/icons_plus)
- **Original Repository:** [https://github.com/chouhan-rahul/icons_plus](https://github.com/chouhan-rahul/icons_plus)

## Future Plans / TODO

- [ ] Monitor pub.dev for an active, official community fork or replacement.
- [ ] Migrate to a maintained dependency or replace with standard icon alternatives when available, then delete this `packages/icons_plus` directory.