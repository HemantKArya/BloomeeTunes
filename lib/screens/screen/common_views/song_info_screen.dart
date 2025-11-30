// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';

import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/utils/imgurl_formator.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:Bloomee/utils/load_Image.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:url_launcher/url_launcher.dart';

class SongInfoScreen extends StatelessWidget {
  final MediaItemModel song;
  const SongInfoScreen({
    Key? key,
    required this.song,
  }) : super(key: key);

  String _formatDuration(Duration? duration) {
    if (duration == null) return "0:00";
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }

  String _getSourceName(String? source) {
    if (source == null) return "Unknown";
    return source == "youtube" ? "YouTube" : "JioSaavn";
  }

  IconData _getSourceIcon(String? source) {
    if (source == "youtube") return MingCute.youtube_fill;
    return MingCute.music_2_fill;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final source = song.extras?["source"];
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;

    // Calculate responsive header height - consistent aesthetic view
    final double headerHeight = isMobile
        ? screenWidth * 0.75
        : isDesktop
            ? screenHeight * 0.45
            : screenHeight * 0.4;

    // Max content width for desktop
    final double maxContentWidth = isDesktop ? 600 : double.infinity;

    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Hero Header with Album Art
          SliverAppBar(
            expandedHeight: headerHeight,
            pinned: true,
            backgroundColor: Default_Theme.themeColor,
            surfaceTintColor: Default_Theme.themeColor,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Default_Theme.themeColor.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Default_Theme.primaryColor1,
                  size: 20,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _HeaderBackground(song: song),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 20 : 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Quick Info Pills Row
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            _InfoPill(
                              icon: MingCute.time_fill,
                              label: _formatDuration(song.duration),
                            ),
                            const SizedBox(width: 10),
                            _InfoPill(
                              icon: _getSourceIcon(source),
                              label: _getSourceName(source),
                            ),
                            if (song.extras?["language"] != null &&
                                song.extras!["language"] != "Unknown") ...[
                              const SizedBox(width: 10),
                              _InfoPill(
                                icon: MingCute.earth_2_fill,
                                label: song.extras!["language"],
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Details Section
                      const _SectionHeader(title: "Details"),
                      const SizedBox(height: 12),

                      _DetailCard(
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
                            value: song.artist ?? "Unknown",
                          ),
                          const _DetailDivider(),
                          _DetailRow(
                            icon: MingCute.album_fill,
                            label: "Album",
                            value: song.album ?? "Unknown",
                          ),
                          if (song.genre != null && song.genre!.isNotEmpty) ...[
                            const _DetailDivider(),
                            _DetailRow(
                              icon: MingCute.hashtag_fill,
                              label: "Genre",
                              value: song.genre!,
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Technical Info Section
                      const _SectionHeader(title: "Technical Info"),
                      const SizedBox(height: 12),

                      _DetailCard(
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

                      const SizedBox(height: 24),

                      // Actions Section
                      const _SectionHeader(title: "Actions"),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _ActionButton(
                              icon: MingCute.copy_2_fill,
                              label: "Copy ID",
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: song.id));
                                SnackbarService.showMessage(
                                    "Media ID copied to clipboard");
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ActionButton(
                              icon: MingCute.link_3_fill,
                              label: "Copy Link",
                              onTap: () {
                                final url = song.extras?["perma_url"];
                                if (url != null && url.isNotEmpty) {
                                  Clipboard.setData(ClipboardData(text: url));
                                  SnackbarService.showMessage(
                                      "Link copied to clipboard");
                                } else {
                                  SnackbarService.showMessage(
                                      "No link available");
                                }
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Open in Source Button
                      if (song.extras?["perma_url"] != null)
                        _ActionButton(
                          icon: MingCute.external_link_fill,
                          label: "Open in ${_getSourceName(source)}",
                          isWide: true,
                          isPrimary: true,
                          onTap: () async {
                            final url = song.extras!["perma_url"];
                            if (url != null) {
                              try {
                                await launchUrl(Uri.parse(url),
                                    mode: LaunchMode.externalApplication);
                              } catch (e) {
                                SnackbarService.showMessage(
                                    "Could not open link");
                              }
                            }
                          },
                        ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Header background with blurred aesthetic view for all devices
class _HeaderBackground extends StatelessWidget {
  final MediaItemModel song;

  const _HeaderBackground({required this.song});

  @override
  Widget build(BuildContext context) {
    final imageUrl = formatImgURL(song.artUri.toString(), ImageQuality.high);
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    // Unified aesthetic view: Blurred background with centered album art
    return Stack(
      fit: StackFit.expand,
      children: [
        // Blurred background
        LoadImageCached(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            color: Default_Theme.themeColor.withValues(alpha: 0.5),
          ),
        ),
        // Centered album art - handles both 1:1 and 16:9 thumbnails
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 40 : 60,
              vertical: isMobile ? 50 : 40,
            ),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isMobile ? 280 : 320,
                maxHeight: isMobile ? 280 : 320,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: LoadImageCached(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
        // Bottom gradient for smooth transition
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 80,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Default_Theme.themeColor.withValues(alpha: 0.8),
                  Default_Theme.themeColor,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Section header text
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Default_Theme.secondoryTextStyleMedium.merge(
        TextStyle(
          color: Default_Theme.primaryColor1.withValues(alpha: 0.5),
          fontSize: 13,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

/// Quick info pill widget
class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Default_Theme.accentColor1.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Default_Theme.accentColor1,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Default_Theme.secondoryTextStyleMedium.merge(
              const TextStyle(
                color: Default_Theme.primaryColor1,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card container for detail rows
class _DetailCard extends StatelessWidget {
  final List<Widget> children;

  const _DetailCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Default_Theme.accentColor1.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

/// Divider for detail card
class _DetailDivider extends StatelessWidget {
  const _DetailDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Default_Theme.accentColor1.withValues(alpha: 0.08),
      indent: 52,
    );
  }
}

/// Detail row inside card
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isMonospace;
  final int maxLines;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isMonospace = false,
    this.maxLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Default_Theme.accentColor1.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: Default_Theme.accentColor1,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Default_Theme.secondoryTextStyle.merge(
                    TextStyle(
                      color: Default_Theme.primaryColor1.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                  style: (isMonospace
                          ? Default_Theme.tertiaryTextStyle
                          : Default_Theme.secondoryTextStyleMedium)
                      .merge(
                    const TextStyle(
                      color: Default_Theme.primaryColor1,
                      fontSize: 15,
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

/// Action button
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isWide;
  final bool isPrimary;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isWide = false,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: (isPrimary
                ? Default_Theme.accentColor2
                : Default_Theme.accentColor1)
            .withValues(alpha: 0.2),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isWide ? 16 : 14,
          ),
          decoration: BoxDecoration(
            color: isPrimary
                ? Default_Theme.accentColor2.withValues(alpha: 0.15)
                : Default_Theme.accentColor1.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: isPrimary
                ? Border.all(
                    color: Default_Theme.accentColor2.withValues(alpha: 0.3),
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: isWide ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isPrimary
                    ? Default_Theme.accentColor2
                    : Default_Theme.primaryColor1.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: Default_Theme.secondoryTextStyleMedium.merge(
                  TextStyle(
                    color: isPrimary
                        ? Default_Theme.accentColor2
                        : Default_Theme.primaryColor1,
                    fontSize: 14,
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
