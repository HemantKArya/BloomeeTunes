# How to contribute

## Build prerequisites

Use Flutter **3.47.7** (the version pinned in GitHub Actions), Rust stable,
and **JDK 17** for Android builds. Gradle 8.14.3 cannot run on Java 25.
Select the JDK used by Flutter explicitly, since it can differ from `JAVA_HOME`:

```powershell
flutter config --jdk-dir="C:/path/to/jdk-17"
flutter doctor -v
flutter pub get --enforce-lockfile
flutter analyze --no-fatal-infos
flutter test --no-pub
flutter build apk --debug --target-platform android-x64
flutter build apk --release --split-per-abi
```

On Linux/macOS, use the same commands with your JDK installation path.
Install the Android SDK and accept its licenses with `flutter doctor --android-licenses`.
Native Rust libraries are built by Cargokit during `flutter build`; keep the Dart
and Rust `flutter_rust_bridge` versions aligned. Commit `pubspec.lock` when updating
dependencies so local and CI builds resolve the same versions.
Keep `flutter build`'s default pub step enabled so Flutter regenerates plugin
registration for the selected build mode, excluding test plugins from release builds.

Localization generation writes missing translation keys as JSON to
`untranslated-messages.json`. Missing translations use the English fallback
and do not prevent compilation.

Release signing uses `android/bloomee.jks` and `android/key.properties` locally,
or the `KEY_STORE` (base64 keystore), `KEY_ALIAS`, `KEY_PASSWORD`, and
`STORE_PASSWORD` GitHub secrets. Without a local `key.properties`, release builds
use the debug key for build verification. The release workflow requires signing secrets.

The manual **Build & Release** workflow builds Android on Ubuntu 24.04, Windows
on Windows Server 2022 with Visual Studio 2022, and Linux on Ubuntu 24.04 in parallel.
The Windows image is pinned because the current audio and permission plugins use
legacy coroutines rejected by Visual Studio 2026. Each job caches Flutter/Pub
and its Cargokit Rust target directory; Android also caches Gradle dependencies
and build outputs. Cold builds still compile native dependencies.

Android verifies all four signed APKs before uploading them. One publishing job
waits for every platform, checks all seven release files, and creates the
prerelease with the existing filenames and version/build-number scheme.
`SECRET_KEY` remains supported for publishing; when absent, the workflow uses
the built-in GitHub token with `contents: write`. APK builds remain manual.

## 1. Fork the repository

Click the "Fork" button in the top-right corner of the repository's page on GitHub, and clone your forked repository to your local machine.

## 2. Open an issue and discuss your idea

Before starting work on any changes, please open an issue on the GitHub repository to discuss your proposed feature, bug fix, or improvement. This helps ensure that your contribution aligns with the project's goals and allows maintainers and the community to provide valuable feedback and guidance. We appreciate your initiative and want to make the process as smooth as possible for everyone!

## 3. Create a branch from the `dev` branch

After discussing your idea and receiving initial feedback, create a new branch to work on.

Choose a descriptive name for your branch that reflects the feature or fix you intend to make.

For example:

```bash
git checkout -b update_readme dev
```

## 4. Make your changes

Make your desired changes to the codebase.

Ensure that your changes adhere to the project's coding conventions and standards.

## 5. Follow code style and standards

Follow the existing code style and conventions used in the project.

Ensure your code is well-formatted, readable, and documented.
Write clear and concise commit messages.

## 6. Commit

Once you're satisfied with your changes, commit them to your branch with clear and concise commit messages.

For example:

```bash
git commit -m "feat: description of the changes made"
```

You can read about commit best practises [here](https://www.freecodecamp.org/news/how-to-write-better-git-commit-messages/).

## 7. Push changes

Push your changes to your forked repository on GitHub.

For example:

```bash
git push origin update_readme
```

## 8. Submit a pull request (PR)

Go to the original repository and click on the "New Pull Request" button. Provide a descriptive title and description for your pull request, explaining the changes you've made and referencing the issue you opened.

## 9. Review and discuss

Engage in discussions with maintainers and other contributors regarding your pull request. Be open to feedback and iterate on your changes if necessary.

## 10. Merge PR

Once your pull request has been reviewed and approved, a maintainer will merge it into the main branch. If the maintainers suggest an alternative approach, we'll work together to find the best solution.

**Congratulations, your contribution has been accepted!**
<br/>
<br/>

# Other information

## Issues and Bug Reports

If you encounter a bug or have a suggestion for improvement, please search the existing issues to see if it has already been reported.

If not, feel free to open a new issue, providing as much detail as possible, including steps to reproduce the issue.

## Community Guidelines

- Be respectful and considerate of others' ideas, opinions, and contributions.
- Help and support fellow contributors, especially beginners.
- Avoid spamming, trolling, or engaging in any form of harassment.

## License

By contributing to this project, you agree that your contributions will be licensed under the project's license.
