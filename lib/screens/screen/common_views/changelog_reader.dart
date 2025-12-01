import 'package:Bloomee/screens/screen/home_views/setting_views/about.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:Bloomee/routes_and_consts/global_str_consts.dart';

// The final changelog string for testing all features
const String changelogText = """
## [Unreleased]

### Changed
- **UI/UX Enhancements**:
    - Updated the app logo and various icons.
    - Improved themes and color schemes.
    - Redesigned and updated the "About" page to include the build number.
    - Enhanced the Android notification thumbnail to a medium quality for better visuals.
- **Dependencies**: Upgraded Flutter, `flutter_bloc`, and the `Android Gradle Plugin`.

## [2.11.6] - 2025-05-05

### Changed
- Refactored import/export functionality.

### Fixed
- Resolved issues with **YouTube streaming**.
- Addressed bugs related to `YouTube` playlists.

## [2.11.5] - 2025-03-17

### Changed
- Updated YouTube client and carousel functionality.

## [2.11.4] - 2025-02-28

### Changed
- Improved performance of the app's main screen.
- Updated the onboarding flow for new users.

""";

class Changelog {
  final List<Version> versions;
  Changelog(this.versions);
}

class Version {
  final String versionNumber;
  final String? releaseDate;
  final List<ChangeCategory> categories;
  Version(this.versionNumber, this.releaseDate, this.categories);
}

class ChangeCategory {
  final String title;
  final List<ChangeItem> changes;
  ChangeCategory(this.title, this.changes);
}

class ChangeItem {
  final String text;
  final List<ChangeItem> subItems;
  ChangeItem(this.text, {List<ChangeItem>? subItems})
      : subItems = subItems ?? [];
}

// 2. --- PARSING LOGIC ---

class _StackItem {
  final ChangeItem item;
  final int indentLevel;
  _StackItem(this.item, this.indentLevel);
}

int _getIndentLevel(String line) {
  int indent = 0;
  for (int i = 0; i < line.length; i++) {
    if (line[i] == ' ') {
      indent++;
    } else {
      break;
    }
  }
  return indent;
}

Changelog parseChangelog(String? log) {
  if (log == null || log.trim().isEmpty) {
    return Changelog([]);
  }

  List<Version> versions = [];
  final versionBlocks =
      log.split(RegExp(r'\n##\s+')).where((block) => block.trim().isNotEmpty);

  for (final block in versionBlocks) {
    final lines = block.trim().split('\n');
    final titleLine = lines.first;
    final versionMatch = RegExp(r'\[(.*?)\](?: - (.*))?').firstMatch(titleLine);
    if (versionMatch == null) continue;

    final versionNumber = versionMatch.group(1) ?? 'Unknown Version';
    final releaseDate = versionMatch.group(2);
    final categories = <ChangeCategory>[];
    ChangeCategory? currentCategory;
    List<String> categoryLines = [];

    void processCategory() {
      if (currentCategory != null && categoryLines.isNotEmpty) {
        List<ChangeItem> rootItems = [];
        List<_StackItem> parentStack = [];

        for (final line in categoryLines) {
          final indentLevel = _getIndentLevel(line);
          final trimmedLine = line.trim().substring(2);
          final newItem = ChangeItem(trimmedLine);

          while (parentStack.isNotEmpty &&
              parentStack.last.indentLevel >= indentLevel) {
            parentStack.removeLast();
          }

          if (parentStack.isEmpty) {
            rootItems.add(newItem);
          } else {
            parentStack.last.item.subItems.add(newItem);
          }

          parentStack.add(_StackItem(newItem, indentLevel));
        }
        categories.add(ChangeCategory(currentCategory.title, rootItems));
      }
      categoryLines = [];
    }

    for (var i = 1; i < lines.length; i++) {
      final line = lines[i];
      if (line.trim().startsWith('###')) {
        processCategory();
        currentCategory = ChangeCategory(line.trim().substring(4), []);
      } else if (line.trim().startsWith('-') && currentCategory != null) {
        categoryLines.add(line);
      }
    }
    processCategory();

    versions.add(Version(versionNumber, releaseDate, categories));
  }

  final unreleasedIndex =
      versions.indexWhere((v) => v.versionNumber.toLowerCase() == 'unreleased');
  if (unreleasedIndex != -1 && versions.length > 1) {
    final unreleasedVersion = versions.removeAt(unreleasedIndex);
    versions.insert(1, unreleasedVersion);
  }

  return Changelog(versions);
}

String _normalizeVersionLabel(String v) {
  return v.trim().toLowerCase().replaceFirst(RegExp(r'^v'), '');
}

/// Return a filtered list of versions to display when 'showOlderVersions' is false.
/// Rules:
/// - Always include the latest version (index 0) if present.
/// - If an 'Unreleased' entry exists, ensure it's placed in position 1.
/// - Then include older versions down to and including the installedVersion (if found).
/// - If installedVersion isn't found, only latest (+ Unreleased if present) are returned.
List<Version> _filterToInstalledRange(
    List<Version> all, String? installedVersion) {
  if (all.isEmpty) return [];

  final normalizedInstalled = installedVersion == null
      ? null
      : _normalizeVersionLabel(installedVersion);

  // Ensure Unreleased remains at index 1 if present (parseChangelog already does this,
  // but defend defensively).
  final unreleasedIndex = all.indexWhere(
      (v) => _normalizeVersionLabel(v.versionNumber) == 'unreleased');
  if (unreleasedIndex > 0) {
    final unreleased = all.removeAt(unreleasedIndex);
    all.insert(1, unreleased);
  }

  final List<Version> out = [];
  // Always include the latest (first) entry.
  out.add(all[0]);

  // If there's an unreleased at 1, include it as second element.
  final hasUnreleased = all.length > 1 &&
      _normalizeVersionLabel(all[1].versionNumber) == 'unreleased';
  if (hasUnreleased) out.add(all[1]);

  // If no installed version provided, stop here.
  if (normalizedInstalled == null) return out;

  // Find index of installed version in the remaining list (search full list for robustness).
  final installedIdx = all.indexWhere(
      (v) => _normalizeVersionLabel(v.versionNumber) == normalizedInstalled);
  if (installedIdx == -1) {
    // Not found in changelog; return only latest (+ unreleased already added).
    return out;
  }

  // Determine starting index to append older versions from `all`.
  int startIdx = hasUnreleased ? 2 : 1;
  // Append versions from startIdx up to and including installedIdx, skipping duplicates.
  for (int i = startIdx; i <= installedIdx && i < all.length; i++) {
    // Avoid adding latest/unreleased twice
    if (i == 0 || (hasUnreleased && i == 1)) continue;
    out.add(all[i]);
  }

  return out;
}

// 3. --- UI WIDGETS ---

class ChangelogScreen extends StatelessWidget {
  final String? changelogText;
  final bool showOlderVersions;

  const ChangelogScreen({
    Key? key,
    required this.changelogText,
    this.showOlderVersions = true, // Default to true
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final changelog = parseChangelog(changelogText);

    // We need to possibly consult the installed package info when showOlderVersions is false.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
            onPressed: () async {
              await Navigator.of(context).maybePop();
              Navigator.of(context).push(PageRouteBuilder(
                pageBuilder: (_, __, ___) => const About(),
                transitionsBuilder: (_, animation, secondaryAnimation, child) {
                  final offsetAnimation = Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeOut));
                  final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
                      .chain(CurveTween(curve: Curves.easeOut));
                  return SlideTransition(
                    position: animation.drive(offsetAnimation),
                    child: FadeTransition(
                      opacity: animation.drive(fadeAnimation),
                      child: child,
                    ),
                  );
                },
                transitionDuration: const Duration(milliseconds: 280),
              ));
            }),
      ),
      body: FutureBuilder<PackageInfo?>(
        // Always attempt to load PackageInfo so badges & expansion ranges work in both modes.
        future: PackageInfo.fromPlatform(),
        builder: (context, AsyncSnapshot<PackageInfo?> snapshot) {
          final installedLabel = snapshot.hasData && snapshot.data != null
              ? 'v${snapshot.data!.version}'
              : null; // only version part needed for matching

          final List<Version> versionsToShow = showOlderVersions
              ? changelog.versions
              : _filterToInstalledRange(
                  List<Version>.from(changelog.versions), installedLabel);

          // Compute which indices to expand by default: range from installed -> latestStable (inclusive)
          final String? installedNorm = installedLabel != null
              ? _normalizeVersionLabel(installedLabel)
              : null;
          String? latestStableNorm;
          try {
            latestStableNorm = _normalizeVersionLabel(changelog.versions
                .firstWhere((v) =>
                    _normalizeVersionLabel(v.versionNumber) != 'unreleased')
                .versionNumber);
          } catch (_) {
            latestStableNorm = changelog.versions.isNotEmpty
                ? _normalizeVersionLabel(changelog.versions[0].versionNumber)
                : null;
          }

          int installedIndexInView = -1;
          int latestIndexInView = -1;
          if (installedNorm != null) {
            installedIndexInView = versionsToShow.indexWhere((v) =>
                _normalizeVersionLabel(v.versionNumber) == installedNorm);
          }
          if (latestStableNorm != null) {
            latestIndexInView = versionsToShow.indexWhere((v) =>
                _normalizeVersionLabel(v.versionNumber) == latestStableNorm);
          }

          final Set<int> expandedIndices = {};
          if (installedIndexInView != -1 && latestIndexInView != -1) {
            final start = installedIndexInView < latestIndexInView
                ? installedIndexInView
                : latestIndexInView;
            final end = installedIndexInView > latestIndexInView
                ? installedIndexInView
                : latestIndexInView;
            for (int i = start; i <= end; i++) {
              expandedIndices.add(i);
            }
          }

          // Persist the fact that user viewed the changelog for the installed version.
          // Schedule as a post-frame callback to avoid performing IO during build.
          if (snapshot.connectionState == ConnectionState.done &&
              installedLabel != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // Saved value must be in the format "vX.Y.Z"
              BloomeeDBService.putSettingStr(
                  GlobalStrConsts.readChangelogs, installedLabel);
            });
          }

          if (versionsToShow.isEmpty && !showOlderVersions) {
            return const Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text('No changelog information available.',
                    style: TextStyle(fontSize: 16, fontFamily: 'Gilroy')),
              ],
            ));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            itemCount: versionsToShow.length + 1, // Use the filtered list
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(left: 6, right: 6, bottom: 16),
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFFFA751), Color(0xFFFF4B4B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: const Text("What's new",
                        style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Gilroy',
                            color: Colors.white)),
                  ),
                );
              }
              final versionIndex = index - 1;
              // Determine the latest stable version (first non-unreleased in original changelog)
              String? latestStable;
              try {
                latestStable = changelog.versions
                    .firstWhere((v) =>
                        _normalizeVersionLabel(v.versionNumber) != 'unreleased')
                    .versionNumber;
              } catch (_) {
                latestStable = changelog.versions.isNotEmpty
                    ? changelog.versions[0].versionNumber
                    : null;
              }

              return VersionCard(
                version: versionsToShow[versionIndex], // Use the filtered list
                // The list index is now based on the filtered list's index
                listIndex: versionIndex,
                installedVersion: installedLabel,
                latestStableVersion: latestStable,
                forceExpanded: expandedIndices.contains(versionIndex),
              );
            },
          );
        },
      ),
    );
  }
}

class VersionCard extends StatefulWidget {
  final Version version;
  final int listIndex;
  final String? installedVersion; // e.g. 'v2.11.6'
  final String? latestStableVersion; // e.g. '2.11.6'
  final bool forceExpanded;

  const VersionCard({
    Key? key,
    required this.version,
    required this.listIndex,
    this.installedVersion,
    this.latestStableVersion,
    this.forceExpanded = false,
  }) : super(key: key);

  @override
  _VersionCardState createState() => _VersionCardState();
}

class _VersionCardState extends State<VersionCard> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.forceExpanded ||
        widget.listIndex == 0 ||
        widget.version.versionNumber.toLowerCase() == 'unreleased';
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      const monthNames = [
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December"
      ];
      return "${date.day} ${monthNames[date.month - 1]} ${date.year}";
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isUnreleased =
        widget.version.versionNumber.toLowerCase() == 'unreleased';
    // Determine installed/current vs latest stable vs update, and ensure only one badge is visible.
    final installedNorm = widget.installedVersion != null
        ? _normalizeVersionLabel(widget.installedVersion!)
        : null;
    final thisNorm = _normalizeVersionLabel(widget.version.versionNumber);
    final latestStableNorm = widget.latestStableVersion != null
        ? _normalizeVersionLabel(widget.latestStableVersion!)
        : null;

    // Whether this version entry corresponds to the project's latest stable
    final bool isThisLatestStable =
        latestStableNorm != null && latestStableNorm == thisNorm;

    // Show LATEST badge only when installed version equals latest stable.
    final bool showLatestBadge = isThisLatestStable &&
        installedNorm != null &&
        installedNorm == latestStableNorm;

    // Show UPDATE badge on the latest stable when installed is different or unknown.
    final bool showUpdateBadge = isThisLatestStable && !showLatestBadge;

    // Show CURRENT badge on the installed version if it's present in changelog and not the latest (to avoid duplicate with LATEST).
    final bool showCurrentBadge =
        installedNorm != null && installedNorm == thisNorm && !showLatestBadge;

    const normalColor = Color(0xFF1C1C1E);
    const highlightedColor = Color(0xFF2C2C2E);

    // Keep the existing 'LATEST' styling but only render when showLatestBadge is true
    final Widget latestMarker = showLatestBadge
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [Colors.greenAccent.shade400, Colors.green.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Text("LATEST",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Gilroy',
                    letterSpacing: 0.5)),
          )
        : const SizedBox.shrink();

    // New badges: CURRENT and UPDATE (if applicable)
    Widget _badge(String text, Color bg, Color textColor) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        margin: const EdgeInsets.only(left: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: bg,
        ),
        child: Text(text,
            style: TextStyle(
                color: textColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                fontFamily: 'Gilroy',
                letterSpacing: 0.3)));

    final currentBadge = showCurrentBadge
        ? _badge('CURRENT', Colors.blueAccent.shade700, Colors.white)
        : const SizedBox.shrink();
    final updateBadge = showUpdateBadge
        ? _badge('UPDATE', Colors.deepOrangeAccent.shade200, Colors.white)
        : const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7.0),
      decoration: BoxDecoration(
        color: _isExpanded ? highlightedColor : normalColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey[850]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: ExpansionTile(
          initiallyExpanded: _isExpanded,
          onExpansionChanged: (isExpanding) =>
              setState(() => _isExpanded = isExpanding),
          backgroundColor: normalColor,
          shape: const Border(),
          collapsedShape: const Border(),
          iconColor:
              isUnreleased ? Colors.amberAccent : Colors.purpleAccent.shade100,
          collapsedIconColor: Colors.white70,
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isUnreleased
                          ? 'Next Version'
                          : 'Version ${widget.version.versionNumber}',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Gilroy',
                          color:
                              isUnreleased ? Colors.amberAccent : Colors.white),
                    ),
                    if (widget.version.releaseDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          _formatDate(widget.version.releaseDate!),
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontFamily: 'Gilroy'),
                        ),
                      ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  latestMarker,
                  // current and update badges (may be SizedBox.shrink)
                  currentBadge,
                  updateBadge,
                ],
              ),
            ],
          ),
          children: widget.version.categories
              .map((category) => CategorySection(category: category))
              .toList(),
        ),
      ),
    );
  }
}

class CategorySection extends StatelessWidget {
  final ChangeCategory category;

  const CategorySection({Key? key, required this.category}) : super(key: key);

  ({String emoji, Color color}) _getEmojiForCategory(String title) {
    switch (title.toLowerCase()) {
      case 'added':
        return (emoji: '✨', color: Colors.lightGreenAccent.shade400);
      case 'changed':
        return (emoji: '🔄', color: Colors.lightBlueAccent.shade400);
      case 'fixed':
        return (emoji: '🐛', color: Colors.orangeAccent.shade400);
      case 'removed':
        return (emoji: '❌', color: Colors.redAccent.shade400);
      default:
        return (emoji: '🔹', color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryStyle = _getEmojiForCategory(category.title);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${categoryStyle.emoji} ${category.title}',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Gilroy',
                color: categoryStyle.color),
          ),
          const SizedBox(height: 12.0),
          for (var item in category.changes)
            ChangeItemWidget(item: item, color: categoryStyle.color),
        ],
      ),
    );
  }
}

class ChangeItemWidget extends StatelessWidget {
  final ChangeItem item;
  final Color color;
  final int level;

  const ChangeItemWidget(
      {Key? key, required this.item, required this.color, this.level = 0})
      : super(key: key);

  List<InlineSpan> _buildStyledText(String text) {
    final List<InlineSpan> spans = [];
    final RegExp pattern = RegExp(r'(\*\*.*?\*\*|`.*?`)');

    text.splitMapJoin(
      pattern,
      onMatch: (Match match) {
        String matchText = match.group(0)!;
        if (matchText.startsWith('**')) {
          spans.add(TextSpan(
              text: matchText.replaceAll('**', ''),
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Gilroy',
                  color: Colors.white)));
        } else if (matchText.startsWith('`')) {
          spans.add(WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6.0, vertical: 2.0),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(5.0)),
                  child: Text(matchText.replaceAll('`', ''),
                      style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'monospace',
                          fontSize: 13)))));
        }
        return '';
      },
      onNonMatch: (String nonMatch) {
        spans.add(TextSpan(
            text: nonMatch,
            style: TextStyle(
                fontFamily: 'Gilroy',
                color: Colors.white.withValues(alpha: 0.85))));
        return '';
      },
    );
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16.0 * level, bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('•  ',
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Gilroy',
                      fontSize: 16)),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context)
                        .style
                        .copyWith(height: 1.5, fontFamily: 'Gilroy'),
                    children: _buildStyledText(item.text),
                  ),
                ),
              ),
            ],
          ),
        ),
        for (var subItem in item.subItems)
          ChangeItemWidget(item: subItem, color: color, level: level + 1),
      ],
    );
  }
}
