import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/core/models/media_playlist_model.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/screens/widgets/more_bottom_sheet.dart';
import 'package:Bloomee/screens/widgets/song_tile.dart';
import 'package:Bloomee/utils/load_image.dart';
import 'package:Bloomee/screens/widgets/play_pause_widget.dart';
import 'package:Bloomee/blocs/downloader/cubit/downloader_cubit.dart';

class OfflineArtistDetailScreen extends StatelessWidget {
  final String artistName;
  final List<Track> songs;

  const OfflineArtistDetailScreen({
    super.key,
    required this.artistName,
    required this.songs,
  });

  void _playFromList(BuildContext context, {int? index, bool shuffle = false}) {
    if (songs.isEmpty) return;
    context.read<BloomeePlayerCubit>().bloomeePlayer.loadPlaylist(
          Playlist(
            tracks: songs,
            title: artistName,
            type: PlaylistType.artist,
          ),
          idx: index ?? 0,
          doPlay: true,
          shuffling: shuffle,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final coverUrl = songs.isNotEmpty ? songs.first.thumbnail.urlHigh ?? songs.first.thumbnail.url : '';
    final defaultBgColor = Default_Theme.themeColor;

    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Center(
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 850;
          return Stack(
            fit: StackFit.expand,
            children: [
              // Ambient Background
              Positioned.fill(
                child: RepaintBoundary(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(color: Default_Theme.themeColor),
                      Positioned(
                        top: isMobile ? -100 : -200,
                        left: isMobile ? -50 : -200,
                        width: 800,
                        height: 800,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Default_Theme.accentColor2.withValues(alpha: 0.25),
                                Colors.transparent
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (coverUrl.isNotEmpty)
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.25,
                            child: ImageFiltered(
                              imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                              child: LoadImageCached(imageUrl: coverUrl, fit: BoxFit.cover),
                            ),
                          ),
                        ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Default_Theme.themeColor.withValues(alpha: 0.1),
                              Default_Theme.themeColor.withValues(alpha: 0.85),
                              Default_Theme.themeColor,
                            ],
                            stops: const [0.0, 0.45, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Content
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Artist circular avatar cover
                          Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: coverUrl.isEmpty
                                  ? Container(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      child: const Icon(MingCute.user_3_fill, size: 60, color: Colors.white24),
                                    )
                                  : LoadImageCached(imageUrl: coverUrl, fit: BoxFit.cover),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            artistName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.playlistSongCount(songs.length),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Actions
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildActionButton(
                                icon: MingCute.shuffle_line,
                                tooltip: l10n.playlistShuffle,
                                onTap: () => _playFromList(context, shuffle: true),
                              ),
                              const SizedBox(width: 24),
                              StreamBuilder<String>(
                                stream: context.read<BloomeePlayerCubit>().bloomeePlayer.queueTitle,
                                builder: (context, snapshot) {
                                  final isCurrent = snapshot.hasData && snapshot.data == artistName;
                                  return StreamBuilder<bool>(
                                    stream: context.read<BloomeePlayerCubit>().bloomeePlayer.engine.playingStream,
                                    builder: (context, playingSnapshot) {
                                      final isPlaying = isCurrent && (playingSnapshot.data ?? false);
                                      return Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Default_Theme.accentColor2.withValues(alpha: 0.3),
                                              blurRadius: 20,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: PlayPauseButton(
                                          isPlaying: isPlaying,
                                          size: 56,
                                          onPlay: () {
                                            if (isCurrent) {
                                              context.read<BloomeePlayerCubit>().bloomeePlayer.play();
                                            } else {
                                              _playFromList(context);
                                            }
                                          },
                                          onPause: () => context.read<BloomeePlayerCubit>().bloomeePlayer.pause(),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 120),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final song = songs[index];
                          return SongCardWidget(
                            index: index + 1,
                            key: ValueKey('artist-detail-${song.id}'),
                            song: song,
                            onTap: () => _playFromList(context, index: index),
                            onOptionsTap: () {
                              showMoreBottomSheet(context, song);
                            },
                          );
                        },
                        childCount: songs.length,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.04),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Icon(icon, color: Colors.white.withValues(alpha: 0.85), size: 20),
          ),
        ),
      ),
    );
  }
}

class OfflineAlbumDetailScreen extends StatelessWidget {
  final String albumName;
  final List<Track> songs;

  const OfflineAlbumDetailScreen({
    super.key,
    required this.albumName,
    required this.songs,
  });

  void _playFromList(BuildContext context, {int? index, bool shuffle = false}) {
    if (songs.isEmpty) return;
    context.read<BloomeePlayerCubit>().bloomeePlayer.loadPlaylist(
          Playlist(
            tracks: songs,
            title: albumName,
            type: PlaylistType.album,
          ),
          idx: index ?? 0,
          doPlay: true,
          shuffling: shuffle,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final coverUrl = songs.isNotEmpty ? songs.first.thumbnail.urlHigh ?? songs.first.thumbnail.url : '';
    final artistName = songs.isNotEmpty && songs.first.artists.isNotEmpty ? songs.first.artists.first.name : 'Unknown Artist';
    final defaultBgColor = Default_Theme.themeColor;

    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Center(
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 850;
          return Stack(
            fit: StackFit.expand,
            children: [
              // Ambient Background
              Positioned.fill(
                child: RepaintBoundary(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(color: Default_Theme.themeColor),
                      Positioned(
                        top: isMobile ? -100 : -200,
                        left: isMobile ? -50 : -200,
                        width: 800,
                        height: 800,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Default_Theme.accentColor1.withValues(alpha: 0.25),
                                Colors.transparent
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (coverUrl.isNotEmpty)
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.25,
                            child: ImageFiltered(
                              imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                              child: LoadImageCached(imageUrl: coverUrl, fit: BoxFit.cover),
                            ),
                          ),
                        ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Default_Theme.themeColor.withValues(alpha: 0.1),
                              Default_Theme.themeColor.withValues(alpha: 0.85),
                              Default_Theme.themeColor,
                            ],
                            stops: const [0.0, 0.45, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Content
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Album square cover
                          Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: coverUrl.isEmpty
                                  ? Container(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      child: const Icon(MingCute.music_2_fill, size: 60, color: Colors.white24),
                                    )
                                  : LoadImageCached(imageUrl: coverUrl, fit: BoxFit.cover),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            albumName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            artistName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.playlistSongCount(songs.length),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Actions
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildActionButton(
                                icon: MingCute.shuffle_line,
                                tooltip: l10n.playlistShuffle,
                                onTap: () => _playFromList(context, shuffle: true),
                              ),
                              const SizedBox(width: 24),
                              StreamBuilder<String>(
                                stream: context.read<BloomeePlayerCubit>().bloomeePlayer.queueTitle,
                                builder: (context, snapshot) {
                                  final isCurrent = snapshot.hasData && snapshot.data == albumName;
                                  return StreamBuilder<bool>(
                                    stream: context.read<BloomeePlayerCubit>().bloomeePlayer.engine.playingStream,
                                    builder: (context, playingSnapshot) {
                                      final isPlaying = isCurrent && (playingSnapshot.data ?? false);
                                      return Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Default_Theme.accentColor1.withValues(alpha: 0.3),
                                              blurRadius: 20,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: PlayPauseButton(
                                          isPlaying: isPlaying,
                                          size: 56,
                                          onPlay: () {
                                            if (isCurrent) {
                                              context.read<BloomeePlayerCubit>().bloomeePlayer.play();
                                            } else {
                                              _playFromList(context);
                                            }
                                          },
                                          onPause: () => context.read<BloomeePlayerCubit>().bloomeePlayer.pause(),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 120),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final song = songs[index];
                          return SongCardWidget(
                            index: index + 1,
                            key: ValueKey('album-detail-${song.id}'),
                            song: song,
                            onTap: () => _playFromList(context, index: index),
                            onOptionsTap: () {
                              showMoreBottomSheet(context, song);
                            },
                          );
                        },
                        childCount: songs.length,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.04),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Icon(icon, color: Colors.white.withValues(alpha: 0.85), size: 20),
          ),
        ),
      ),
    );
  }
}
