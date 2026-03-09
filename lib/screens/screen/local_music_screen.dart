import 'dart:developer';

import 'package:Bloomee/blocs/local_music/cubit/local_music_cubit.dart';
import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/core/models/media_playlist_model.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/screens/widgets/more_bottom_sheet.dart';
import 'package:Bloomee/screens/widgets/sign_board_widget.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/screens/widgets/song_tile.dart';
import 'package:Bloomee/services/local_music_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:path/path.dart' as p;

class LocalMusicScreen extends StatefulWidget {
  const LocalMusicScreen({super.key});

  @override
  State<LocalMusicScreen> createState() => _LocalMusicScreenState();
}

class _LocalMusicScreenState extends State<LocalMusicScreen> {
  bool _isSearch = false;
  final TextEditingController _searchController = TextEditingController();
  List<Track> _filteredTracks = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterTracks);
    context.read<LocalMusicCubit>().load();
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterTracks);
    _searchController.dispose();
    super.dispose();
  }

  void _filterTracks() {
    final state = context.read<LocalMusicCubit>().state;
    if (state is LocalMusicLoaded) {
      _syncFilteredTracks(state.tracks);
    }
  }

  void _syncFilteredTracks(List<Track> tracks) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? tracks
        : tracks.where((track) {
            final haystack = [
              track.title,
              track.album,
              ...track.artists.map((artist) => artist.name),
            ].join(' ').toLowerCase();
            return haystack.contains(query);
          }).toList();

    if (!mounted) return;
    setState(() {
      _filteredTracks = filtered;
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearch = !_isSearch;
      if (!_isSearch) {
        _searchController.clear();
        final state = context.read<LocalMusicCubit>().state;
        _filteredTracks =
            state is LocalMusicLoaded ? List<Track>.from(state.tracks) : [];
      }
    });
  }

  String _compactFolderPath(String folder) {
    final normalized = folder.replaceAll('\\', '/');
    if (normalized.length <= 38) {
      return normalized;
    }
    return '...${normalized.substring(normalized.length - 35)}';
  }

  Future<void> _handleDelete(Track track) async {
    final cubit = context.read<LocalMusicCubit>();
    try {
      final linkedPlaylists =
          await cubit.getUserPlaylistsContainingTrack(track.id);
      final shouldConfirm = await cubit.shouldConfirmDelete();

      if (shouldConfirm) {
        final result = await showDialog<_DeleteResult>(
          context: context,
          builder: (context) => _DeleteConfirmDialog(
            trackTitle: track.title,
            linkedPlaylists: linkedPlaylists,
          ),
        );

        if (!mounted || result == null) {
          return;
        }

        if (result.neverAskAgain) {
          await cubit.setConfirmDelete(false);
        }
      }

      await cubit.deleteTrack(track);
      if (!mounted) return;
      SnackbarService.showMessage('Deleted "${track.title}"');
    } catch (error, stackTrace) {
      log('Failed to delete local track: $error\n$stackTrace',
          name: 'LocalMusicScreen');
      if (!mounted) return;
      SnackbarService.showMessage('Failed to delete "${track.title}"');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Default_Theme.themeColor,
        body: BlocConsumer<LocalMusicCubit, LocalMusicState>(
          listener: (context, state) {
            if (state is LocalMusicLoaded) {
              _syncFilteredTracks(state.tracks);
            }
          },
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                _buildSliverAppBar(context, state),
                ..._buildBody(context, state),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildBody(BuildContext context, LocalMusicState state) {
    if (state is LocalMusicLoading || state is LocalMusicInitial) {
      return [_buildLoadingSliver()];
    }
    if (state is LocalMusicNoPermission) {
      return [_buildNoPermissionSliver(context)];
    }
    if (state is LocalMusicScanning) {
      return [_buildScanningSliver()];
    }
    if (state is LocalMusicError) {
      return [_buildErrorSliver(state)];
    }
    if (state is LocalMusicLoaded) {
      return _buildLoadedSlivers(context, state);
    }
    return [const SliverToBoxAdapter(child: SizedBox.shrink())];
  }

  Widget _buildLoadingSliver() {
    return const SliverFillRemaining(
      child: Center(
        child: CircularProgressIndicator(color: Default_Theme.accentColor2),
      ),
    );
  }

  Widget _buildNoPermissionSliver(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shield_outlined,
                  color: Default_Theme.primaryColor2.withValues(alpha: 0.5),
                  size: 56),
              const SizedBox(height: 16),
              Text('Audio Access Required',
                  style: Default_Theme.secondoryTextStyleMedium.merge(
                      const TextStyle(
                          color: Default_Theme.primaryColor1, fontSize: 18))),
              const SizedBox(height: 8),
              Text(
                'Grant permission to scan and play music stored on your device.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Default_Theme.primaryColor2.withValues(alpha: 0.6),
                    fontSize: 13,
                    fontFamily: 'ReThink-Sans'),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () =>
                    context.read<LocalMusicCubit>().resolvePermissionAction(),
                icon: const Icon(Icons.lock_open_rounded, size: 18),
                label: const Text('Grant Permission'),
                style: FilledButton.styleFrom(
                  backgroundColor: Default_Theme.accentColor2,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanningSliver() {
    return const SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Default_Theme.accentColor2),
            SizedBox(height: 16),
            Text('Scanning for music…',
                style: TextStyle(
                    color: Default_Theme.primaryColor2,
                    fontSize: 14,
                    fontFamily: 'ReThink-Sans')),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorSliver(LocalMusicError state) {
    return SliverFillRemaining(
      child: Center(
        child: SignBoardWidget(
            message: 'Scan failed: ${state.message}',
            icon: Icons.error_outline),
      ),
    );
  }

  List<Widget> _buildLoadedSlivers(
      BuildContext context, LocalMusicLoaded state) {
    if (_filteredTracks.isEmpty && _searchController.text.isEmpty) {
      _filteredTracks = state.tracks;
    }

    final widgets = <Widget>[];

    if (!LocalMusicService.isMobile && state.folders.isNotEmpty) {
      widgets.add(_buildFolderChips(context, state.folders));
    }

    if (state.tracks.isNotEmpty) {
      widgets.add(SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                '${state.tracks.length} track${state.tracks.length == 1 ? '' : 's'}',
                style: TextStyle(
                    color: Default_Theme.primaryColor2.withValues(alpha: 0.6),
                    fontSize: 13,
                    fontFamily: 'ReThink-Sans'),
              ),
              const Spacer(),
              _ActionChipButton(
                icon: MingCute.shuffle_line,
                label: 'Shuffle',
                onTap: () => context
                    .read<BloomeePlayerCubit>()
                    .bloomeePlayer
                    .loadPlaylist(
                      Playlist(tracks: state.tracks, title: 'Local Music'),
                      doPlay: true,
                      shuffling: true,
                    ),
              ),
              const SizedBox(width: 8),
              _ActionChipButton(
                icon: MingCute.play_fill,
                label: 'Play All',
                onTap: () => context
                    .read<BloomeePlayerCubit>()
                    .bloomeePlayer
                    .loadPlaylist(
                      Playlist(tracks: state.tracks, title: 'Local Music'),
                      doPlay: true,
                    ),
              ),
            ],
          ),
        ),
      ));
    }

    if (state.tracks.isEmpty) {
      widgets.add(
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SignBoardWidget(
                    message: 'No local music found',
                    icon: MingCute.folder_open_line),
                const SizedBox(height: 16),
                if (!LocalMusicService.isMobile)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: FilledButton.icon(
                      onPressed: () =>
                          context.read<LocalMusicCubit>().addFolderViaPicker(),
                      icon: const Icon(Icons.create_new_folder_outlined,
                          size: 18),
                      label: const Text('Add Music Folder'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Default_Theme.accentColor2,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                OutlinedButton.icon(
                  onPressed: () => context.read<LocalMusicCubit>().scan(),
                  icon: const Icon(MingCute.refresh_2_line, size: 18),
                  label: const Text('Scan Now'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Default_Theme.primaryColor2,
                    side: BorderSide(
                        color:
                            Default_Theme.primaryColor2.withValues(alpha: 0.3)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      widgets.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final track = _filteredTracks[index];
              return SongCardWidget(
                key: ValueKey('local-track-${track.id}'),
                song: track,
                showOptions: true,
                onTap: () {
                  final selectedIndex =
                      state.tracks.indexWhere((t) => t.id == track.id);
                  if (selectedIndex < 0) {
                    SnackbarService.showMessage('Unable to play this track.');
                    return;
                  }
                  context.read<BloomeePlayerCubit>().bloomeePlayer.loadPlaylist(
                        Playlist(tracks: state.tracks, title: 'Local Music'),
                        idx: selectedIndex,
                        doPlay: true,
                      );
                },
                onOptionsTap: () {
                  showMoreBottomSheet(context, track,
                      showDelete: true, onDelete: () => _handleDelete(track));
                },
              );
            },
            childCount: _filteredTracks.length,
          ),
        ),
      );
      widgets.add(const SliverPadding(padding: EdgeInsets.only(bottom: 80)));
    }

    return widgets;
  }

  SliverToBoxAdapter _buildFolderChips(
      BuildContext context, List<String> folders) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Watched folders',
                  style: Default_Theme.secondoryTextStyleMedium.merge(
                    const TextStyle(
                      color: Default_Theme.primaryColor1,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Desktop scans only the folders you keep here.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color:
                          Default_Theme.primaryColor2.withValues(alpha: 0.56),
                      fontSize: 11,
                      fontFamily: 'ReThink-Sans',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  onPressed: () =>
                      context.read<LocalMusicCubit>().addFolderViaPicker(),
                  icon: const Icon(Icons.add_rounded, size: 15),
                  label: const Text('Add'),
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        Default_Theme.accentColor2.withValues(alpha: 0.9),
                    foregroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                    minimumSize: const Size(0, 34),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: folders.map((folder) {
                return Tooltip(
                  message: folder,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 280),
                    padding: const EdgeInsets.fromLTRB(12, 9, 8, 9),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Default_Theme.primaryColor2.withValues(alpha: 0.08),
                          Default_Theme.accentColor2.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color:
                            Default_Theme.primaryColor2.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Default_Theme.primaryColor2
                                .withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            MingCute.folder_2_line,
                            color: Default_Theme.primaryColor1,
                            size: 15,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                p.basename(folder),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Default_Theme.primaryColor1,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'ReThink-Sans',
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _compactFolderPath(folder),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Default_Theme.primaryColor2
                                      .withValues(alpha: 0.5),
                                  fontSize: 10.5,
                                  fontFamily: 'ReThink-Sans',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          tooltip: 'Remove folder',
                          onPressed: () => context
                              .read<LocalMusicCubit>()
                              .removeFolder(folder),
                          icon: Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: Default_Theme.primaryColor2
                                .withValues(alpha: 0.82),
                          ),
                          style: IconButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: Default_Theme.primaryColor2
                                .withValues(alpha: 0.08),
                            minimumSize: const Size(30, 30),
                            maximumSize: const Size(30, 30),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context, LocalMusicState state) {
    return SliverAppBar(
      floating: true,
      pinned: false,
      surfaceTintColor: Default_Theme.themeColor,
      backgroundColor: Default_Theme.themeColor,
      automaticallyImplyLeading: false,
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _isSearch
            ? TextField(
                key: const ValueKey('search'),
                controller: _searchController,
                autofocus: true,
                cursorColor: Default_Theme.primaryColor1,
                decoration: InputDecoration(
                  hintText: 'Search local music…',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                      color:
                          Default_Theme.primaryColor1.withValues(alpha: 0.5)),
                ),
                style: Default_Theme.secondoryTextStyle.merge(const TextStyle(
                    color: Default_Theme.primaryColor1, fontSize: 16.0)),
              )
            : Row(
                key: const ValueKey('title'),
                children: [
                  Text('Local',
                      style: Default_Theme.primaryTextStyle.merge(
                          const TextStyle(
                              fontSize: 34,
                              color: Default_Theme.primaryColor1,
                              fontWeight: FontWeight.w700))),
                  const Spacer(),
                ],
              ),
      ),
      actions: [
        if (!_isSearch && state is LocalMusicLoaded)
          Tooltip(
            message: 'Scan for music',
            child: IconButton(
              icon: const Icon(MingCute.refresh_2_line,
                  color: Default_Theme.primaryColor1),
              onPressed: () => context.read<LocalMusicCubit>().scan(),
            ),
          ),
        if (!_isSearch && !LocalMusicService.isMobile)
          Tooltip(
            message: 'Add folder',
            child: IconButton(
              icon: const Icon(Icons.create_new_folder_outlined,
                  color: Default_Theme.primaryColor1),
              onPressed: () =>
                  context.read<LocalMusicCubit>().addFolderViaPicker(),
            ),
          ),
        Tooltip(
          message: _isSearch ? 'Close search' : 'Search',
          child: IconButton(
            icon: Icon(_isSearch ? Icons.close : Icons.search,
                color: Default_Theme.primaryColor1),
            onPressed: _toggleSearch,
          ),
        ),
      ],
    );
  }
}

class _ActionChipButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChipButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Default_Theme.accentColor2.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Default_Theme.accentColor2),
              const SizedBox(width: 6),
              Text(label,
                  style: const TextStyle(
                      color: Default_Theme.accentColor2,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'ReThink-Sans')),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeleteResult {
  final bool neverAskAgain;
  const _DeleteResult({required this.neverAskAgain});
}

class _DeleteConfirmDialog extends StatefulWidget {
  final String trackTitle;
  final List<String> linkedPlaylists;

  const _DeleteConfirmDialog({
    required this.trackTitle,
    required this.linkedPlaylists,
  });

  @override
  State<_DeleteConfirmDialog> createState() => _DeleteConfirmDialogState();
}

class _DeleteConfirmDialogState extends State<_DeleteConfirmDialog> {
  bool _dontAskAgain = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF0D1B2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Delete Track',
          style: Default_Theme.secondoryTextStyleMedium.merge(const TextStyle(
              color: Default_Theme.primaryColor1, fontSize: 18))),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delete "${widget.trackTitle}" from your device? This cannot be undone.',
            style: TextStyle(
                color: Default_Theme.primaryColor2.withValues(alpha: 0.8),
                fontSize: 14,
                fontFamily: 'ReThink-Sans'),
          ),
          if (widget.linkedPlaylists.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              'It will also be removed from:',
              style: TextStyle(
                color: Default_Theme.primaryColor2.withValues(alpha: 0.72),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'ReThink-Sans',
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.linkedPlaylists
                  .map(
                    (playlist) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            Default_Theme.primaryColor2.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Default_Theme.primaryColor2
                              .withValues(alpha: 0.16),
                        ),
                      ),
                      child: Text(
                        playlist,
                        style: const TextStyle(
                          color: Default_Theme.primaryColor1,
                          fontSize: 12,
                          fontFamily: 'ReThink-Sans',
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: _dontAskAgain,
                  onChanged: (v) => setState(() => _dontAskAgain = v ?? false),
                  activeColor: Default_Theme.accentColor2,
                  side: BorderSide(
                      color:
                          Default_Theme.primaryColor2.withValues(alpha: 0.5)),
                ),
              ),
              const SizedBox(width: 8),
              Text("Don't ask again",
                  style: TextStyle(
                      color: Default_Theme.primaryColor2.withValues(alpha: 0.7),
                      fontSize: 13,
                      fontFamily: 'ReThink-Sans')),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel',
              style: TextStyle(
                  color: Default_Theme.primaryColor2.withValues(alpha: 0.7))),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
              context, _DeleteResult(neverAskAgain: _dontAskAgain)),
          style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent.shade200,
              foregroundColor: Colors.white),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
