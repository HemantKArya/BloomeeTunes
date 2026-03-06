// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';

import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/screens/widgets/media_metadata_links.dart';
import 'package:Bloomee/utils/load_image.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SongInfoScreen extends StatelessWidget {
  final Track song;
  const SongInfoScreen({
    Key? key,
    required this.song,
  }) : super(key: key);

  String _formatDuration(BigInt? durationMs) {
    if (durationMs == null) return "0:00";
    final totalSeconds = durationMs.toInt() ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }

  String _getSourceName() {
    final parts = song.id.split('::');
    if (parts.length >= 2) return parts[0];
    return "Unknown";
  }

  IconData _getSourceIcon() {
    return MingCute.plugin_2_fill;
  }

  @override
  Widget build(BuildContext context) {
    // Applied your image logic
    final imageUrl = song.thumbnail.urlHigh ?? song.thumbnail.url;

    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 70, // Gives the custom back button enough breathing room
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Center(
            child: Material(
              color: Default_Theme.themeColor.withValues(alpha: 0.5),
              shape: CircleBorder(
                side: BorderSide(
                  color: Default_Theme.primaryColor2.withValues(alpha: 0.15),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: Default_Theme.primaryColor2,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Ambient Background
          Positioned.fill(
            child: LoadImageCached(
              imageUrl: imageUrl,
              fallbackUrl: song.thumbnail.url,
              fit: BoxFit.cover,
            ),
          ),
          // 2. Heavy Blur + Darkening Gradient Overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Default_Theme.themeColor.withValues(alpha: 0.75),
                      Default_Theme.themeColor.withValues(alpha: 0.9),
                      Default_Theme.themeColor,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. True Constraint-Based Responsive Layout
          SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Switch to mobile layout if available width is less than 750px.
                // This completely fixes the squished sidebar issue.
                final bool isMobileView = constraints.maxWidth < 750;

                if (isMobileView) {
                  return _buildMobileLayout(context, imageUrl);
                } else {
                  return _buildDesktopLayout(context, constraints, imageUrl);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, String imageUrl) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildAlbumArt(context, imageUrl, isMobileView: true),
            const SizedBox(height: 32),
            _buildSongTitles(isCentered: true),
            const SizedBox(height: 24),
            _buildDetailsContent(isMobileView: true),
            const SizedBox(height: 100), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(
      BuildContext context, BoxConstraints constraints, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Pane: Sticky Album Art
          Expanded(
            flex: 4,
            child: Container(
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(top: 24),
              child: _buildAlbumArt(context, imageUrl, isMobileView: false),
            ),
          ),
          const SizedBox(width: 48),
          // Right Pane: Scrollable Details
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildSongTitles(isCentered: false),
                  const SizedBox(height: 32),
                  _buildDetailsContent(isMobileView: false),
                  const SizedBox(height: 80), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(BuildContext context, String imageUrl,
      {required bool isMobileView}) {
    return LayoutBuilder(builder: (context, constraints) {
      // Calculate a beautiful size that never overblows
      double size = isMobileView
          ? constraints.maxWidth * 0.85 // 85% of available width on mobile
          : constraints.maxWidth * 0.9; // 90% of its pane on desktop

      // Cap the maximum size so it never looks absurdly large on ultrawides
      size = size.clamp(200.0, 500.0);

      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isMobileView ? 24 : 32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
            // Subtle top highlight for 3D feel
            BoxShadow(
              color: Default_Theme.primaryColor2.withValues(alpha: 0.1),
              blurRadius: 1,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isMobileView ? 24 : 32),
          child: LoadImageCached(
            imageUrl: imageUrl,
            fallbackUrl: song.thumbnail.url,
            fit: BoxFit.cover,
          ),
        ),
      );
    });
  }

  Widget _buildSongTitles({required bool isCentered}) {
    return Column(
      crossAxisAlignment:
          isCentered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          song.title,
          textAlign: isCentered ? TextAlign.center : TextAlign.left,
          style: TextStyle(
            color: Default_Theme.primaryColor2,
            fontSize: isCentered ? 28 : 42,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        TrackMetadataLinks(
          track: song,
          showAlbum: song.album != null,
          textAlign: isCentered ? TextAlign.center : TextAlign.left,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Default_Theme.secondoryTextStyleMedium.merge(
            TextStyle(
              color: Default_Theme.primaryColor2.withValues(alpha: 0.7),
              fontSize: isCentered ? 18 : 22,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsContent({required bool isMobileView}) {
    return Column(
      crossAxisAlignment:
          isMobileView ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        // Quick Info Pills
        Wrap(
          alignment: isMobileView ? WrapAlignment.center : WrapAlignment.start,
          spacing: 12,
          runSpacing: 12,
          children: [
            _InfoPill(
              icon: MingCute.time_fill,
              label: _formatDuration(song.durationMs),
            ),
            _InfoPill(
              icon: _getSourceIcon(),
              label: _getSourceName(),
            ),
          ],
        ),

        const SizedBox(height: 40),

        // Details Section
        const _SectionHeader(title: "Song Details"),
        const SizedBox(height: 16),
        _GlassCard(
          children: [
            _DetailRow(
              icon: MingCute.music_2_fill,
              label: "Title",
              value: song.title,
            ),
            const _DetailDivider(),
            _DetailRow(
              icon: MingCute.microphone_fill,
              label: "Artist",
              value: song.artists.map((a) => a.name).join(', '),
              valueWidget: ArtistListLinks(
                artists: song.artists,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Default_Theme.secondoryTextStyle.merge(
                  const TextStyle(
                    color: Default_Theme.primaryColor2,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
            ),
            if (song.album?.title != null) ...[
              const _DetailDivider(),
              _DetailRow(
                icon: MingCute.album_fill,
                label: "Album",
                value: song.album!.title,
                valueWidget: AlbumLinkText(
                  album: song.album!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Default_Theme.secondoryTextStyle.merge(
                    const TextStyle(
                      color: Default_Theme.primaryColor2,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ]
          ],
        ),

        const SizedBox(height: 28),

        // Technical Info Section
        const _SectionHeader(title: "Technical Info"),
        const SizedBox(height: 16),
        _GlassCard(
          children: [
            _DetailRow(
              icon: MingCute.IDcard_fill,
              label: "Media ID",
              value: song.id,
              isMonospace: true,
              maxLines: 1,
            ),
          ],
        ),

        const SizedBox(height: 28),

        // Actions Section
        const _SectionHeader(title: "Actions"),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: MingCute.copy_2_fill,
                label: "Copy ID",
                onTap: () {
                  Clipboard.setData(ClipboardData(text: song.id));
                  SnackbarService.showMessage("Media ID copied");
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _ActionButton(
                icon: MingCute.link_3_fill,
                label: "Copy Link",
                onTap: () {
                  final url = song.url;
                  if (url != null && url.isNotEmpty) {
                    Clipboard.setData(ClipboardData(text: url));
                    SnackbarService.showMessage("Link copied");
                  } else {
                    SnackbarService.showMessage("No link available");
                  }
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Open in Source Button
        if (song.url != null)
          _ActionButton(
            icon: MingCute.external_link_fill,
            label: "Open in browser",
            isWide: true,
            isPrimary: true,
            onTap: () async {
              final url = song.url;
              if (url != null) {
                try {
                  await launchUrl(Uri.parse(url),
                      mode: LaunchMode.externalApplication);
                } catch (e) {
                  SnackbarService.showMessage("Could not open link");
                }
              }
            },
          ),
      ],
    );
  }
}

// ============================================================================
// BEAUTIFUL SUB-WIDGETS (Updated with your custom theme colors)
// ============================================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: Default_Theme.secondoryTextStyleMedium.merge(
          TextStyle(
            color: Default_Theme.primaryColor2.withValues(alpha: 0.5),
            fontSize: 12,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Default_Theme.accentColor2.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Default_Theme.accentColor2.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Default_Theme.accentColor2),
              const SizedBox(width: 8),
              Text(
                label,
                style: Default_Theme.secondoryTextStyleMedium.merge(
                  const TextStyle(
                    color: Default_Theme.primaryColor2,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final List<Widget> children;
  const _GlassCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Default_Theme.accentColor2.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Default_Theme.primaryColor2.withValues(alpha: 0.05),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }
}

class _DetailDivider extends StatelessWidget {
  const _DetailDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Default_Theme.primaryColor2.withValues(alpha: 0.05),
      indent: 64,
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? valueWidget;
  final bool isMonospace;
  final int maxLines;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueWidget,
    this.isMonospace = false,
    this.maxLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Default_Theme.accentColor2.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Default_Theme.accentColor2,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Default_Theme.secondoryTextStyle.merge(
                    TextStyle(
                      color: Default_Theme.primaryColor2.withValues(alpha: 0.5),
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                valueWidget ??
                    Text(
                      value,
                      maxLines: maxLines,
                      overflow: TextOverflow.ellipsis,
                      style: (isMonospace
                              ? const TextStyle(fontFamily: 'CodePro')
                              : const TextStyle())
                          .merge(
                        Default_Theme.secondoryTextStyle.merge(
                          const TextStyle(
                            color: Default_Theme.primaryColor2,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isWide;
  final bool isPrimary; // Default true based on your snippet

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isWide = false,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: (isPrimary
                ? Default_Theme.accentColor2
                : Default_Theme.accentColor1)
            .withValues(alpha: 0.2),
        highlightColor: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: isPrimary
                ? Default_Theme.accentColor2.withValues(alpha: 0.15)
                : Default_Theme.primaryColor2.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isPrimary
                  ? Default_Theme.accentColor2.withValues(alpha: 0.3)
                  : Default_Theme.primaryColor2.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: isWide ? 18 : 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: isWide ? MainAxisSize.max : MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isPrimary
                      ? Default_Theme.accentColor2
                      : Default_Theme.primaryColor2.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Default_Theme.secondoryTextStyleMedium.merge(
                      TextStyle(
                        color: isPrimary
                            ? Default_Theme.accentColor2
                            : Default_Theme.primaryColor2,
                        fontSize: 15,
                        fontWeight:
                            isPrimary ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
