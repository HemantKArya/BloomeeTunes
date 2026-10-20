import 'dart:async';

import 'package:Bloomee/blocs/lyrics/lyrics_cubit.dart';
import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/blocs/mini_player/mini_player_cubit.dart';
import 'package:Bloomee/core/adapters/track_adapter.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:Bloomee/screens/screen/player_views/lyrics_search.dart';
import 'package:Bloomee/screens/widgets/artwork_ambient_background.dart';
import 'package:Bloomee/screens/widgets/player_progress_bar.dart';
import 'package:Bloomee/screens/widgets/media_metadata_links.dart';
import 'package:Bloomee/screens/widgets/play_pause_widget.dart';
import 'package:Bloomee/screens/widgets/up_next_panel.dart';
import 'package:Bloomee/utils/lyrics_timing.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class FullscreenLyricsView extends StatefulWidget {
  const FullscreenLyricsView({super.key});

  @override
  State<FullscreenLyricsView> createState() => _FullscreenLyricsViewState();
}

class _FullscreenLyricsViewState extends State<FullscreenLyricsView> {
  final _queueController = UpNextPanelController();
  bool _queueOpen = false;
  bool _lyricsOnly = false;
  bool _editingTiming = false;
  bool _saving = false;
  Duration _offset = Duration.zero;
  String? _trackId;
  Object? _document;

  @override
  void initState() {
    super.initState();
    _trackId =
        context.read<BloomeePlayerCubit>().bloomeePlayer.currentTrackInfo.id;
    final state = context.read<LyricsCubit>().state;
    if (state is LyricsLoaded && state.track.id == _trackId) {
      _offset = Duration(milliseconds: state.lyrics.offset ?? 0);
      _document = (
        state.track.id,
        state.lyrics.id,
        state.lyrics.lyricsSynced ?? state.lyrics.lyricsPlain
      );
    }
  }

  void _onLyricsChanged(LyricsState state) {
    final changedTrack = state.track.id != _trackId;
    final document = state is LyricsLoaded
        ? (
            state.track.id,
            state.lyrics.id,
            state.lyrics.lyricsSynced ?? state.lyrics.lyricsPlain
          )
        : null;
    final changedDocument =
        document != null && _document != null && document != _document;
    setState(() {
      if (changedTrack || changedDocument) {
        _trackId = state.track.id;
        _editingTiming = false;
        _offset = Duration.zero;
        _document = null;
      }
      if (document != null) _document = document;
      if (state is LyricsLoaded && (!_editingTiming || changedTrack)) {
        _offset = Duration(milliseconds: state.lyrics.offset ?? 0);
      }
    });
  }

  void _cancelTiming() {
    final state = context.read<LyricsCubit>().state;
    setState(() {
      _editingTiming = false;
      _offset = Duration(milliseconds: state.lyrics.offset ?? 0);
    });
  }

  Future<void> _save(LyricsLoaded state, {bool timing = false}) async {
    if (_saving) return;
    setState(() => _saving = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      await context.read<LyricsCubit>().setLyricsToDB(
            state.lyrics,
            state.track.id,
            offset: timing ? _offset.inMilliseconds : state.lyrics.offset,
          );
      if (!mounted) return;
      if (timing && state.track.id == _trackId) {
        setState(() => _editingTiming = false);
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.lyricsSaved)));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.lyricsSaveFailed)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _openSettings() async {
    final cubit = context.read<LyricsCubit>();
    final state = cubit.state;
    final player = context.read<BloomeePlayerCubit>().bloomeePlayer;
    final track = player.currentTrackInfo;
    final loaded = state is LyricsLoaded && state.track.id == track.id;
    final action = await showModalBottomSheet<_LyricsAction>(
      context: context,
      backgroundColor: const Color(0xFF14151A),
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 560),
      builder: (context) => _LyricsSettingsMenu(
        loaded: loaded,
        synced:
            loaded && (state.lyrics.parsedLyrics?.lyrics.isNotEmpty ?? false),
      ),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case _LyricsAction.search:
        final l10n = AppLocalizations.of(context)!;
        await showSearch(
          context: context,
          delegate: LyricsSearchDelegate(
            mediaID: track.id,
            searchFieldLabelText: l10n.lyricsSearchFieldLabel,
          ),
          query: buildLyricsSearchSeedQuery(
            title: track.title,
            artists: track.artists.map((artist) => artist.name).toList(),
            album: track.album?.title,
          ),
        );
      case _LyricsAction.timing:
        if (loaded && player.currentTrackInfo.id == track.id) {
          setState(() {
            _offset = Duration(milliseconds: state.lyrics.offset ?? 0);
            _editingTiming = true;
          });
        }
      case _LyricsAction.save:
        if (state is LyricsLoaded) await _save(state);
      case _LyricsAction.delete:
        try {
          await cubit.deleteLyricsFromDB(track);
        } catch (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(AppLocalizations.of(context)!.lyricsDeleteFailed),
            ));
          }
        }
    }
  }

  void _back() {
    if (_lyricsOnly) {
      setState(() => _lyricsOnly = false);
      return;
    }
    if (_saving) return;
    if (_queueController.collapse()) return;
    if (_queueOpen) {
      setState(() => _queueOpen = false);
    } else if (_editingTiming) {
      _cancelTiming();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final player = context.read<BloomeePlayerCubit>().bloomeePlayer;
    final desktop = MediaQuery.sizeOf(context).width > 800;
    return CallbackShortcuts(
        bindings: {const SingleActivator(LogicalKeyboardKey.escape): _back},
        child: Focus(
            autofocus: true,
            child: PopScope(
              canPop: !_lyricsOnly && !_editingTiming && !_queueOpen,
              onPopInvokedWithResult: (didPop, result) {
                if (!didPop) _back();
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: StreamBuilder<MediaItem?>(
                      stream: player.mediaItem,
                      initialData: player.mediaItem.valueOrNull,
                      builder: (context, snapshot) {
                        final track = snapshot.data == null
                            ? player.currentTrackInfo
                            : mediaItemToTrack(snapshot.data!);
                        return ArtworkAmbientBackground(
                          imageUrl:
                              track.thumbnail.urlHigh ?? track.thumbnail.url,
                          fallbackUrl:
                              track.thumbnail.urlLow ?? track.thumbnail.url,
                        );
                      },
                    ),
                  ),
                  Scaffold(
                    backgroundColor: Colors.transparent,
                    appBar: _lyricsOnly
                        ? null
                        : AppBar(
                            backgroundColor: Colors.transparent,
                            surfaceTintColor: Colors.transparent,
                            leading: IconButton(
                              tooltip: MaterialLocalizations.of(context)
                                  .backButtonTooltip,
                              onPressed: _saving ? null : _back,
                              icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 30),
                            ),
                            title: _LyricsTrackHeader(title: l10n.lyricsTitle),
                            actions: [
                              IconButton(
                                tooltip: l10n.lyricsEnterFullscreen,
                                icon: const Icon(Icons.fullscreen_rounded),
                                onPressed: () {
                                  _queueController.collapse();
                                  setState(() {
                                    _lyricsOnly = true;
                                    _queueOpen = false;
                                  });
                                },
                              ),
                              IconButton(
                                tooltip: l10n.upNextTitle,
                                icon: const Icon(Icons.queue_music_rounded),
                                onPressed: () {
                                  if (desktop) {
                                    setState(() => _queueOpen = !_queueOpen);
                                  } else {
                                    _queueController.toggle();
                                  }
                                },
                              ),
                              IconButton(
                                tooltip: l10n.tooltipMoreOptions,
                                onPressed: _saving ? null : _openSettings,
                                icon: const Icon(MingCute.more_2_fill),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                    body: BlocListener<LyricsCubit, LyricsState>(
                      listener: (context, state) => _onLyricsChanged(state),
                      child: SafeArea(
                        top: false,
                        child: LayoutBuilder(builder: (context, viewport) {
                          return Stack(
                            children: [
                              Column(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Expanded(child: _buildLyrics(desktop)),
                                        if (desktop && !_lyricsOnly)
                                          ClipRect(
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 240),
                                              curve: Curves.easeInOutCubic,
                                              width: _queueOpen ? 360 : 0,
                                              child: Visibility(
                                                visible: _queueOpen,
                                                maintainState: true,
                                                child: OverflowBox(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  minWidth: 360,
                                                  maxWidth: 360,
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(
                                                        0, 12, 16, 12),
                                                    child: UpNextPanel(
                                                      peekHeight: 60,
                                                      parentHeight:
                                                          viewport.maxHeight,
                                                      isDesktopMode: true,
                                                      onDesktopCollapse: () =>
                                                          setState(() =>
                                                              _queueOpen =
                                                                  false),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (_editingTiming && !_lyricsOnly)
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                          maxHeight: viewport.maxHeight * 0.45),
                                      child: SingleChildScrollView(
                                          child: _buildTimingControls()),
                                    ),
                                  if (!_lyricsOnly) const _LyricsTransport(),
                                ],
                              ),
                              if (!desktop && !_lyricsOnly)
                                UpNextPanel(
                                  controller: _queueController,
                                  peekHeight: 60,
                                  parentHeight: viewport.maxHeight,
                                  canBeHidden: true,
                                ),
                              if (_lyricsOnly)
                                Positioned(
                                  top: MediaQuery.paddingOf(context).top + 8,
                                  right: 16,
                                  child: IconButton(
                                    tooltip: l10n.lyricsExitFullscreen,
                                    onPressed: () =>
                                        setState(() => _lyricsOnly = false),
                                    icon: const Icon(
                                        Icons.fullscreen_exit_rounded),
                                  ),
                                ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            )));
  }

  Widget _buildLyrics(bool desktop) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<LyricsCubit, LyricsState>(
      builder: (context, state) {
        if (state is LyricsInitial || state is LyricsLoading) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        if (state is LyricsLoaded) {
          final key = ValueKey((
            state.track.id,
            state.lyrics.id,
            state.lyrics.lyricsSynced ?? state.lyrics.lyricsPlain
          ));
          if (state.lyrics.parsedLyrics?.lyrics.isNotEmpty ?? false) {
            return FullscreenSyncedLyrics(
              key: key,
              state: state,
              lyricOffset: _offset,
              isDesktop: desktop,
              showFollowButton: !_lyricsOnly,
            );
          }
          if (state.lyrics.lyricsPlain.trim().isNotEmpty) {
            return _PlainLyrics(
                key: key, text: state.lyrics.lyricsPlain, desktop: desktop);
          }
        }
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(MingCute.music_2_line,
                    size: 32, color: Colors.white54),
                const SizedBox(height: 16),
                Text(
                    state is LyricsNoPlugin
                        ? l10n.playerLyricsNoPlugin
                        : l10n.playerNoLyricsFound,
                    textAlign: TextAlign.center,
                    style: Default_Theme.secondoryTextStyle
                        .copyWith(fontSize: 18, color: Colors.white70)),
                const SizedBox(height: 16),
                if (!_lyricsOnly)
                  TextButton.icon(
                    onPressed: _openSettings,
                    icon: const Icon(Icons.search_rounded, size: 20),
                    label: Text(l10n.lyricsSettingsSearchTitle),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimingControls() {
    final l10n = AppLocalizations.of(context)!;
    final seconds = _offset.inMilliseconds / 1000;
    return Material(
      color: Colors.black.withValues(alpha: 0.25),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _saving
                    ? null
                    : () => setState(
                        () => _offset += const Duration(milliseconds: 50)),
                icon: const Icon(Icons.remove_rounded, size: 18),
                label: Text(l10n.lyricsTimingEarlier),
              ),
              TextButton(
                onPressed: _saving
                    ? null
                    : () => setState(() => _offset = Duration.zero),
                child: Tooltip(
                  message: l10n.lyricsSyncTapToReset,
                  child: Text(
                      '${seconds >= 0 ? '+' : ''}${seconds.toStringAsFixed(2)} s',
                      style: const TextStyle(
                          fontFeatures: [FontFeature.tabularFigures()])),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _saving
                    ? null
                    : () => setState(
                        () => _offset -= const Duration(milliseconds: 50)),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(l10n.lyricsTimingLater),
              ),
              TextButton(
                  onPressed: _saving ? null : _cancelTiming,
                  child: Text(l10n.buttonCancel)),
              FilledButton(
                onPressed: _saving
                    ? null
                    : () {
                        final state = context.read<LyricsCubit>().state;
                        if (state is LyricsLoaded) _save(state, timing: true);
                      },
                child: Text(l10n.lyricsTimingSave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LyricsTrackHeader extends StatelessWidget {
  final String title;
  const _LyricsTrackHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final player = context.read<BloomeePlayerCubit>().bloomeePlayer;
    return StreamBuilder<MediaItem?>(
      stream: player.mediaItem,
      initialData: player.mediaItem.valueOrNull,
      builder: (context, snapshot) {
        final track = snapshot.data == null
            ? player.currentTrackInfo
            : mediaItemToTrack(snapshot.data!);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(track.id == 'Null' ? title : track.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Default_Theme.secondoryTextStyle
                    .copyWith(fontSize: 17, fontWeight: FontWeight.w600)),
            TrackMetadataLinks(
                track: track,
                maxLines: 1,
                style: Default_Theme.secondoryTextStyle
                    .copyWith(fontSize: 12, color: Colors.white60)),
          ],
        );
      },
    );
  }
}

class _LyricsTransport extends StatelessWidget {
  const _LyricsTransport();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BloomeePlayerCubit>();
    final player = cubit.bloomeePlayer;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.07))),
      ),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const PlayerProgressBar(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                        onPressed: player.skipToPrevious,
                        icon: const Icon(MingCute.skip_previous_fill),
                        iconSize: 28),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: BlocBuilder<MiniPlayerCubit, MiniPlayerState>(
                        builder: (context, state) {
                          if (state.isLoading || state.isResolving) {
                            return const SizedBox.square(
                                dimension: 48,
                                child: Center(
                                    child: SizedBox.square(
                                        dimension: 22,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2))));
                          }
                          return PlayPauseButton(
                            size: 48,
                            isPlaying: state.isPlaying,
                            onPause: player.pause,
                            onPlay: () async {
                              if (state.isCompleted) {
                                await player.seek(Duration.zero);
                              }
                              await player.play();
                            },
                          );
                        },
                      ),
                    ),
                    IconButton(
                        onPressed: player.skipToNext,
                        icon: const Icon(MingCute.skip_forward_fill),
                        iconSize: 28),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlainLyrics extends StatelessWidget {
  final String text;
  final bool desktop;
  const _PlainLyrics({super.key, required this.text, required this.desktop});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 880),
        child: Scrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
            child: SelectableText(text,
                style: Default_Theme.secondoryTextStyle.copyWith(
                    fontSize: desktop ? 25 : 21,
                    height: 1.75,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.85))),
          ),
        ),
      ),
    );
  }
}

class FullscreenSyncedLyrics extends StatefulWidget {
  final LyricsLoaded state;
  final Duration lyricOffset;
  final bool isDesktop;
  final bool showFollowButton;

  const FullscreenSyncedLyrics({
    super.key,
    required this.state,
    required this.lyricOffset,
    this.isDesktop = false,
    this.showFollowButton = true,
  });

  @override
  State<FullscreenSyncedLyrics> createState() => _FullscreenSyncedLyricsState();
}

class _FullscreenSyncedLyricsState extends State<FullscreenSyncedLyrics> {
  final _scrollController = ItemScrollController();
  StreamSubscription<Duration>? _positionSubscription;
  int _currentIndex = -1;
  bool _following = true;
  Size? _viewport;

  @override
  void initState() {
    super.initState();
    final engine = context.read<BloomeePlayerCubit>().bloomeePlayer.engine;
    _currentIndex = lyricIndexAt(widget.state.lyrics.parsedLyrics!.lyrics,
        engine.position + widget.lyricOffset);
    _positionSubscription = engine.positionStream.listen(_onPosition);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.sizeOf(context);
    if (_viewport != size) {
      _viewport = size;
      _scheduleScroll(jump: true);
    }
  }

  @override
  void didUpdateWidget(FullscreenSyncedLyrics oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.track.id != widget.state.track.id ||
        oldWidget.state.lyrics.lyricsSynced !=
            widget.state.lyrics.lyricsSynced) {
      _following = true;
    }
    final position =
        context.read<BloomeePlayerCubit>().bloomeePlayer.engine.position;
    _onPosition(position);
  }

  void _onPosition(Duration rawPosition) {
    if (!mounted) return;
    final next = lyricIndexAt(widget.state.lyrics.parsedLyrics!.lyrics,
        rawPosition + widget.lyricOffset);
    if (next == _currentIndex) return;
    setState(() => _currentIndex = next);
    _scheduleScroll();
  }

  void _scheduleScroll({bool jump = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_following || !_scrollController.isAttached) return;
      final target = _currentIndex < 0 ? 0 : _currentIndex;
      if (jump || MediaQuery.disableAnimationsOf(context)) {
        _scrollController.jumpTo(index: target, alignment: 0.35);
      } else {
        _scrollController.scrollTo(
            index: target,
            alignment: 0.35,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic);
      }
    });
  }

  void _resume() {
    setState(() => _following = true);
    _scheduleScroll();
  }

  Future<void> _seek(int index) async {
    final player = context.read<BloomeePlayerCubit>().bloomeePlayer;
    final position = lyricSeekPosition(
        widget.state.lyrics.parsedLyrics!.lyrics[index].start,
        widget.lyricOffset,
        player.mediaItem.valueOrNull?.duration ?? Duration.zero);
    _resume();
    await player.seek(position);
    if (mounted) _onPosition(position);
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lines = widget.state.lyrics.parsedLyrics!.lyrics;
    return LayoutBuilder(builder: (context, constraints) {
      final horizontal =
          ((constraints.maxWidth - 800) / 2).clamp(24.0, double.infinity);
      return Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is UserScrollNotification &&
                  notification.direction != ScrollDirection.idle &&
                  _following) {
                setState(() => _following = false);
              }
              return false;
            },
            child: ScrollablePositionedList.builder(
              itemScrollController: _scrollController,
              initialScrollIndex: _currentIndex < 0 ? 0 : _currentIndex,
              initialAlignment: 0.35,
              itemCount: lines.length,
              padding: EdgeInsets.fromLTRB(
                  horizontal,
                  constraints.maxHeight * 0.35,
                  horizontal,
                  constraints.maxHeight * 0.6),
              itemBuilder: (context, index) {
                final active = index == _currentIndex;
                if (lines[index].text.trim().isEmpty) {
                  return const SizedBox(height: 28);
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Semantics(
                    selected: active,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _seek(index),
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          child: AnimatedDefaultTextStyle(
                            duration: MediaQuery.disableAnimationsOf(context)
                                ? Duration.zero
                                : const Duration(milliseconds: 160),
                            style: Default_Theme.secondoryTextStyle.copyWith(
                              fontSize: widget.isDesktop ? 34 : 26,
                              fontWeight: FontWeight.w600,
                              height: 1.45,
                              color: Colors.white.withValues(
                                  alpha: active
                                      ? 1
                                      : index < _currentIndex
                                          ? 0.4
                                          : 0.55),
                            ),
                            child: Text(lines[index].text),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (!_following && widget.showFollowButton)
            Positioned(
              right: 24,
              bottom: 16,
              child: IconButton(
                onPressed: _resume,
                icon: const Icon(Icons.my_location_rounded, size: 18),
                tooltip: AppLocalizations.of(context)!.lyricsFollowPlayback,
              ),
            ),
        ],
      );
    });
  }
}

enum _LyricsAction { search, timing, save, delete }

class _LyricsSettingsMenu extends StatelessWidget {
  final bool loaded;
  final bool synced;
  const _LyricsSettingsMenu({required this.loaded, required this.synced});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Widget item(
            _LyricsAction action, IconData icon, String title, String subtitle,
            {bool enabled = true}) =>
        ListTile(
          enabled: enabled,
          leading: Icon(icon, size: 22),
          title:
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle),
          onTap: () => Navigator.pop(context, action),
        );
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            item(
                _LyricsAction.search,
                MingCute.search_2_line,
                l10n.lyricsSettingsSearchTitle,
                l10n.lyricsSettingsSearchSubtitle),
            item(_LyricsAction.timing, MingCute.time_line,
                l10n.lyricsSettingsSyncTitle, l10n.lyricsSettingsSyncSubtitle,
                enabled: synced),
            const Divider(indent: 16, endIndent: 16),
            item(_LyricsAction.save, MingCute.save_2_line,
                l10n.lyricsSettingsSaveTitle, l10n.lyricsSettingsSaveSubtitle,
                enabled: loaded),
            item(
                _LyricsAction.delete,
                MingCute.delete_3_line,
                l10n.lyricsSettingsDeleteTitle,
                l10n.lyricsSettingsDeleteSubtitle,
                enabled: loaded),
          ],
        ),
      ),
    );
  }
}
