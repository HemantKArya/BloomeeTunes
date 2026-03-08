import 'dart:ui';
import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/core/models/media_playlist_model.dart';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/screens/screen/library_views/cubit/current_playlist_cubit.dart';
import 'package:Bloomee/screens/screen/library_views/more_opts_sheet.dart';
import 'package:Bloomee/blocs/downloader/cubit/downloader_cubit.dart';
import 'package:Bloomee/screens/widgets/more_bottom_sheet.dart';
import 'package:Bloomee/screens/widgets/play_pause_widget.dart';
import 'package:Bloomee/screens/widgets/sign_board_widget.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/screens/widgets/song_tile.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/utils/load_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';

part 'playlist_info_dialog.dart';

class PlaylistView extends StatefulWidget {
  const PlaylistView({super.key});

  @override
  State<PlaylistView> createState() => _PlaylistViewState();
}

class _PlaylistViewState extends State<PlaylistView> {
  final double titleScale = 1.5;
  final double titleFontSize = 16;

  // Memoised TextPainter — computed once per (title, screenWidth), never on scroll frames.
  String? _textHeightTitle;
  double _textHeightForWidth = -1;
  double _textHeightValue = 0;

  double _getOrComputeTextHeight(String title, double maxWidth) {
    if (_textHeightTitle == title && _textHeightForWidth == maxWidth) {
      return _textHeightValue;
    }
    // Always use the narrowest padding (endPadding=60) so the result is layout-stable
    // across the entire scroll range. Avoids TextPainter creation on every scroll frame.
    const endPadding = 60.0;
    final span = TextSpan(
      text: title,
      style: Default_Theme.secondoryTextStyleMedium.merge(
        TextStyle(fontSize: titleFontSize, color: Colors.white),
      ),
    );
    final tp = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
      maxLines: 3,
      textScaler: TextScaler.linear(titleScale),
    )..layout(maxWidth: (maxWidth - endPadding).clamp(100.0, double.infinity));
    _textHeightTitle = title;
    _textHeightForWidth = maxWidth;
    _textHeightValue = tp.height;
    tp.dispose();
    return _textHeightValue;
  }

  Color _adjustColor(Color color, bool darken, {double amount = 0.1}) {
    final hsl = HSLColor.fromColor(color);
    HSLColor adjustedHsl = darken
        ? hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        : hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    if (!darken && adjustedHsl.lightness < 0.75) {
      adjustedHsl = adjustedHsl.withLightness(0.85);
    }
    return adjustedHsl.toColor();
  }

  List<Color> getFBColor(BuildContext context) {
    // get foreground and background color from current playlist pallete
    Color? color = context
        .read<CurrentPlaylistCubit>()
        .getCurrentPlaylistPallete()
        ?.lightVibrantColor
        ?.color;
    Color? bgColor = context
        .read<CurrentPlaylistCubit>()
        .getCurrentPlaylistPallete()
        ?.darkMutedColor
        ?.color;
    if (bgColor != null && color != null) {
      //calculate contrast between two color and bgcolor
      final double contrast =
          bgColor.computeLuminance() / color.computeLuminance();
      if (contrast > 0.05) {
        color = _adjustColor(color, false);
        bgColor = _adjustColor(bgColor, true);
      }
      return [color, bgColor];
    }
    return [Colors.white, Colors.black];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: BlocBuilder<CurrentPlaylistCubit, CurrentPlaylistState>(
          builder: (context, state) {
            // Compute palette colours once per rebuild instead of 15+ times.
            final colors = getFBColor(context);
            final fgColor = colors[0];
            final bgColor = colors[1];
            const double maxExtent = 300;
            return (state is CurrentPlaylistInitial ||
                    state is CurrentPlaylistLoading)
                ? const CustomScrollView(
                    slivers: [
                      SliverAppBar(),
                      SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    ],
                  )
                : state.playlist.tracks.isEmpty
                    ? const CustomScrollView(
                        slivers: [
                          SliverAppBar(),
                          SliverFillRemaining(
                            child: Center(
                              child: SignBoardWidget(
                                message: "No Songs Yet!",
                                icon: MingCute.playlist_line,
                              ),
                            ),
                          )
                        ],
                      )
                    : CustomScrollView(
                        key: ValueKey(state.playlist.title),
                        physics: const BouncingScrollPhysics(),
                        primary: true,
                        slivers: [
                          SliverAppBar(
                            leading: IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                              ),
                              hoverColor: bgColor.withValues(alpha: 0.3),
                              highlightColor: fgColor.withValues(alpha: 0.6),
                              color: fgColor,
                              style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(
                                    bgColor.withValues(alpha: 0.1)),
                              ),
                              onPressed: () {
                                context.pop();
                              },
                            ),
                            backgroundColor: Default_Theme.themeColor,
                            surfaceTintColor: Default_Theme.themeColor,
                            expandedHeight: maxExtent,
                            floating: false,
                            pinned: true,
                            centerTitle: false,
                            flexibleSpace:
                                LayoutBuilder(builder: (context, constraints) {
                              final double percentage =
                                  (constraints.maxHeight - kToolbarHeight) /
                                      (maxExtent - kToolbarHeight);
                              const double startPadding = 20.0;
                              const double endPadding = 60.0;
                              final double horizontalPadding = startPadding +
                                  (endPadding - startPadding) *
                                      (1.0 - percentage);
                              final bool isCollapsed = percentage < 0.4;

                              // Memoised — zero TextPainter allocation after first frame.
                              final textHeight = _getOrComputeTextHeight(
                                state.playlist.title,
                                constraints.maxWidth,
                              );

                              return FlexibleSpaceBar(
                                expandedTitleScale: titleScale,
                                titlePadding: EdgeInsets.only(
                                    left: horizontalPadding,
                                    bottom: isCollapsed ? 16 : 10),
                                title: Text(
                                  state.playlist.title,
                                  maxLines: isCollapsed ? 1 : 3,
                                  style: Default_Theme.secondoryTextStyleMedium
                                      .merge(
                                    TextStyle(
                                      fontSize: titleFontSize,
                                      overflow: TextOverflow.ellipsis,
                                      color: fgColor,
                                    ),
                                  ),
                                ),
                                background: LayoutBuilder(
                                    builder: (context, constraints) {
                                  return Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      LoadImageCached(
                                          imageUrl: state.playlist.tracks.first
                                                  .thumbnail.urlLow ??
                                              state.playlist.tracks.first
                                                  .thumbnail.url,
                                          fallbackUrl: state.playlist.tracks
                                              .first.thumbnail.url),
                                      Positioned(
                                          child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              bgColor.withValues(alpha: 0.0),
                                              bgColor.withValues(alpha: 1),
                                            ],
                                            stops: const [0.5, 1],
                                          ),
                                        ),
                                      )),

                                      // Lower portion with blur
                                      Positioned.fill(
                                        top: MediaQuery.of(context)
                                                .size
                                                .height *
                                            0.6, // Adjust this position as needed
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                              sigmaX: 30, sigmaY: 30),
                                          child: Container(
                                            color: Colors.black.withValues(
                                                alpha:
                                                    0), // Keep the container color transparent
                                          ),
                                        ),
                                      ),
                                      Positioned.fill(
                                        top: 10,
                                        child: Align(
                                          alignment: Alignment.topCenter,
                                          child: SizedBox(
                                            height: constraints.maxHeight -
                                                (textHeight + 30),
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 80, right: 80),
                                                child: Container(
                                                  // shadow effect
                                                  decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color:
                                                            bgColor.withValues(
                                                                alpha: 0.2),
                                                        spreadRadius: 5,
                                                        blurRadius: 7,
                                                        offset: const Offset(0,
                                                            3), // changes position of shadow
                                                      ),
                                                    ],
                                                  ),
                                                  child: LoadImageCached(
                                                    imageUrl: state
                                                            .playlist
                                                            .tracks
                                                            .first
                                                            .thumbnail
                                                            .urlHigh ??
                                                        state
                                                            .playlist
                                                            .tracks
                                                            .first
                                                            .thumbnail
                                                            .url,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                          right: 8,
                                          top: 8,
                                          child: IconButton(
                                            icon: const Icon(
                                              MingCute.information_line,
                                            ),
                                            hoverColor:
                                                bgColor.withValues(alpha: 0.2),
                                            color: fgColor,
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  WidgetStatePropertyAll(bgColor
                                                      .withValues(alpha: 0.05)),
                                            ),
                                            onPressed: () {
                                              // dialog to show all infromation about the playlist (playlist name, source, description, original link, type, etc  )
                                              showPlaylistInfo(context, state,
                                                  fgColor: fgColor,
                                                  bgColor: bgColor);
                                            },
                                          )),
                                      // blur fade effect bottom edge
                                    ],
                                  );
                                }),
                              );
                            }),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 12,
                                bottom: 12,
                                left: 20,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                "${(state.playlist.type == PlaylistType.album) ? 'Album' : 'Playlist'} • ${state.playlist.tracks.length} Songs",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: Default_Theme
                                                    .secondoryTextStyle
                                                    .merge(TextStyle(
                                                  color: Default_Theme
                                                      .primaryColor1
                                                      .withValues(alpha: 0.9),
                                                  fontSize: 12,
                                                )),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'by ${state.playlist.artists?.map((a) => a.name).join(', ') ?? 'You'}',
                                          style: Default_Theme
                                              .secondoryTextStyle
                                              .merge(TextStyle(
                                            color: Default_Theme.primaryColor1
                                                .withValues(alpha: 0.8),
                                            fontSize: 12,
                                          )),
                                        ),
                                      ],
                                    ),
                                  ),
                                  OverflowBar(
                                    spacing: 0,
                                    overflowAlignment: OverflowBarAlignment.end,
                                    children: [
                                      Builder(builder: (ctx) {
                                        final downloaded = ctx
                                            .watch<DownloaderCubit>()
                                            .state
                                            .downloaded;
                                        final allDownloaded = state
                                                .playlist.tracks.isNotEmpty &&
                                            state.playlist.tracks.every((s) =>
                                                downloaded
                                                    .any((d) => d.id == s.id));

                                        if (allDownloaded) {
                                          return Tooltip(
                                            message: 'Available Offline',
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: bgColor.withValues(
                                                    alpha: 0.08),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.offline_pin_rounded,
                                                size: 22,
                                                color: fgColor.withValues(
                                                    alpha: 0.85),
                                              ),
                                            ),
                                          );
                                        }

                                        return IconButton(
                                          padding: const EdgeInsets.fromLTRB(
                                              6, 2, 6, 2),
                                          constraints: const BoxConstraints(
                                              minWidth: 36, minHeight: 36),
                                          tooltip: 'Download playlist',
                                          icon: Icon(
                                            MingCute.download_2_fill,
                                            size: 20,
                                            color:
                                                fgColor.withValues(alpha: 0.9),
                                          ),
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStatePropertyAll(bgColor
                                                    .withValues(alpha: 0.06)),
                                            shape: MaterialStatePropertyAll(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                            ),
                                          ),
                                          onPressed: () async {
                                            final items = state.playlist.tracks;
                                            final count = items.length;
                                            final confirmed =
                                                await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                backgroundColor:
                                                    Default_Theme.themeColor,
                                                title: const Text(
                                                    'Download playlist'),
                                                content: Text(
                                                    'Do you want to download $count songs from "${state.playlist.title}"? This will add them to the download queue.'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            context, false),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Default_Theme
                                                              .accentColor2,
                                                      foregroundColor:
                                                          Default_Theme
                                                              .primaryColor2,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 14,
                                                        vertical: 10,
                                                      ),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(18),
                                                      ),
                                                      elevation: 0,
                                                    ),
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            context, true),
                                                    child: const Text(
                                                        'Download All'),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (confirmed == true) {
                                              // Show a progress dialog and enqueue items slowly
                                              await _showAddToDownloadProgress(
                                                  context, items);
                                              SnackbarService.showMessage(
                                                  'Added $count songs to download queue');
                                            }
                                          },
                                        );
                                      }),
                                      // --- END: DOWNLOAD / DOWNLOADED INDICATOR ---
                                      Tooltip(
                                        message: 'Shuffle',
                                        child: IconButton(
                                            onPressed: () {
                                              context
                                                  .read<BloomeePlayerCubit>()
                                                  .bloomeePlayer
                                                  .loadPlaylist(
                                                      Playlist(
                                                          tracks: state
                                                              .playlist.tracks,
                                                          title: state
                                                              .playlist.title),
                                                      doPlay: true,
                                                      shuffling: true);
                                            },
                                            padding: EdgeInsets.zero,
                                            icon: Icon(MingCute.shuffle_line,
                                                color: Default_Theme
                                                    .primaryColor1
                                                    .withValues(alpha: 0.8))),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: 2, left: 5),
                                        child: BlocBuilder<CurrentPlaylistCubit,
                                            CurrentPlaylistState>(
                                          builder: (context, state) {
                                            return StreamBuilder<String>(
                                                stream: context
                                                    .watch<BloomeePlayerCubit>()
                                                    .bloomeePlayer
                                                    .queueTitle,
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData &&
                                                      snapshot.data ==
                                                          state
                                                              .playlist.title) {
                                                    return StreamBuilder<bool>(
                                                        stream: context
                                                            .read<
                                                                BloomeePlayerCubit>()
                                                            .bloomeePlayer
                                                            .engine
                                                            .playingStream,
                                                        builder: (context,
                                                            snapshot2) {
                                                          if (snapshot2
                                                                  .hasData &&
                                                              (snapshot2.data ??
                                                                  false)) {
                                                            return PlayPauseButton(
                                                              onPause: () => context
                                                                  .read<
                                                                      BloomeePlayerCubit>()
                                                                  .bloomeePlayer
                                                                  .pause(),
                                                              onPlay: () => context
                                                                  .read<
                                                                      BloomeePlayerCubit>()
                                                                  .bloomeePlayer
                                                                  .play(),
                                                              isPlaying: true,
                                                              size: 40,
                                                            );
                                                          } else {
                                                            return PlayPauseButton(
                                                              onPause: () => context
                                                                  .read<
                                                                      BloomeePlayerCubit>()
                                                                  .bloomeePlayer
                                                                  .pause(),
                                                              onPlay: () => context
                                                                  .read<
                                                                      BloomeePlayerCubit>()
                                                                  .bloomeePlayer
                                                                  .play(),
                                                              isPlaying: false,
                                                              size: 40,
                                                            );
                                                          }
                                                        });
                                                  } else {
                                                    return PlayPauseButton(
                                                      onPause: () => context
                                                          .read<
                                                              BloomeePlayerCubit>()
                                                          .bloomeePlayer
                                                          .pause(),
                                                      onPlay: () {
                                                        context
                                                            .read<
                                                                BloomeePlayerCubit>()
                                                            .bloomeePlayer
                                                            .loadPlaylist(
                                                                Playlist(
                                                                    tracks: state
                                                                        .playlist
                                                                        .tracks,
                                                                    title: state
                                                                        .playlist
                                                                        .title),
                                                                doPlay: true);
                                                      },
                                                      size: 40,
                                                    );
                                                  }
                                                });
                                          },
                                        ),
                                      ),
                                      Tooltip(
                                        message: 'More Options',
                                        child: IconButton(
                                            onPressed: () {
                                              showPlaylistOptsInrSheet(
                                                  context, state.playlist);
                                            },
                                            icon: Icon(MingCute.more_2_line,
                                                color: Default_Theme
                                                    .primaryColor1
                                                    .withValues(alpha: 0.8))),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                if (index >= state.playlist.tracks.length) {
                                  return null;
                                }
                                final track = state.playlist.tracks[index];
                                return SongCardWidget(
                                  key: ValueKey(track.id),
                                  song: track,
                                  onTap: () {
                                    context
                                        .read<BloomeePlayerCubit>()
                                        .bloomeePlayer
                                        .loadPlaylist(
                                            Playlist(
                                                tracks: state.playlist.tracks,
                                                title: state.playlist.title),
                                            idx: index,
                                            doPlay: true);
                                  },
                                  onOptionsTap: () {
                                    showMoreBottomSheet(
                                      context,
                                      track,
                                      onDelete: () {
                                        _removeTrack(context, track);
                                      },
                                      showDelete: true,
                                      showSinglePlay: true,
                                    );
                                  },
                                );
                              },
                              childCount: state.playlist.tracks.length,
                            ),
                          ),
                        ],
                      );
          },
        ),
      ),
    );
  }

  void _removeTrack(BuildContext context, Track track) {
    final cubit = context.read<CurrentPlaylistCubit>();
    final playlistTitle = cubit.state.playlist.title;
    cubit.removeTrack(track);
    SnackbarService.showMessage('${track.title} removed from $playlistTitle');
  }

  Future<void> _showAddToDownloadProgress(
      BuildContext context, List<Track> items) async {
    if (items.isEmpty) return;

    // Use a dialog with StatefulBuilder to update progress
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        int completed = 0;
        String currentTitle = '';
        void Function(void Function()) setStateRef = (_) {};

        // Start the enqueue process after the dialog is built
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          for (final song in items) {
            // update current title and rebuild
            setStateRef(() {
              currentTitle = song.title;
            });

            // enqueue the song via cubit
            try {
              context
                  .read<DownloaderCubit>()
                  .downloadSong(song, showSnackbar: false);
            } catch (_) {}

            // small delay so UI remains responsive and progress is visible
            await Future.delayed(const Duration(milliseconds: 180));

            setStateRef(() {
              completed++;
            });
          }

          // close dialog when done
          if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();

          // Show single snackbar for bulk download
          if (dialogCtx.mounted) {
            SnackbarService.showMessage("Playlist added to download queue");
          }
        });

        return StatefulBuilder(builder: (sbCtx, sbSetState) {
          // capture setState so the enqueue loop can update the dialog
          setStateRef = sbSetState;

          final double progress =
              items.isEmpty ? 0 : (completed / items.length).clamp(0.0, 1.0);

          return AlertDialog(
            backgroundColor: Default_Theme.themeColor,
            contentPadding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            content: SizedBox(
              width: 320,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Adding to download queue',
                    style: Default_Theme.secondoryTextStyleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${completed}/${items.length} ${completed == 1 ? 'item' : 'items'}',
                    style: Default_Theme.secondoryTextStyle,
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor:
                        Default_Theme.primaryColor1.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Default_Theme.primaryColor1.withValues(alpha: 0.95)),
                    minHeight: 6,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Default_Theme.secondoryTextStyle
                        .merge(const TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}
