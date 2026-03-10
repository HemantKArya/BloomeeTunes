import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/screens/screen/library_views/cubit/current_playlist_cubit.dart';
import 'package:Bloomee/screens/widgets/bloomee_ui_kit/bloomee_dialog.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/services/smart_track_replacement_service.dart';
import 'package:Bloomee/src/rust/api/plugin/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:icons_plus/icons_plus.dart';

Future<void> showSmartReplaceDialog(BuildContext context, Track track) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => _SmartReplaceDialog(track: track),
  );
}

class _SmartReplaceDialog extends StatefulWidget {
  final Track track;

  const _SmartReplaceDialog({required this.track});

  @override
  State<_SmartReplaceDialog> createState() => _SmartReplaceDialogState();
}

class _SmartReplaceDialogState extends State<_SmartReplaceDialog> {
  late final SmartTrackReplacementService _service;
  late final Future<List<SmartTrackReplacementCandidate>> _future;
  String? _applyingTrackId;

  @override
  void initState() {
    super.initState();
    _service = SmartTrackReplacementService.create(
      context.read<BloomeePlayerCubit>().bloomeePlayer.pluginService,
    );
    _future = _service.searchCandidates(widget.track);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BloomeeDialogSurface(
      title: l10n.smartReplaceTitle,
      subtitle: l10n.smartReplaceSubtitle(widget.track.title),
      icon: MingCute.transfer_4_line,
      actions: [
        BloomeeDialogAction.text(l10n.smartReplaceClose),
      ],
      body: FutureBuilder<List<SmartTrackReplacementCandidate>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const SizedBox(
              height: 160,
              child: Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Default_Theme.accentColor2,
                  ),
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return _SmartReplaceEmptyState(
              icon: MingCute.alert_fill,
              title: l10n.smartReplaceSearchFailed,
              subtitle: snapshot.error.toString(),
            );
          }

          final candidates = snapshot.data ?? const [];
          if (candidates.isEmpty) {
            return _SmartReplaceEmptyState(
              icon: MingCute.search_2_line,
              title: l10n.smartReplaceNoMatch,
              subtitle: l10n.smartReplaceNoMatchSubtitle,
            );
          }

          return ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: candidates.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final candidate = candidates[index];
                final isApplying = _applyingTrackId == candidate.track.id;
                final artistNames = candidate.track.artists
                    .map((artist) => artist.name)
                    .join(', ');
                final thumbUrl = candidate.track.thumbnail.urlLow ??
                    candidate.track.thumbnail.url;

                return BloomeeDialogTile(
                  title: candidate.track.title,
                  subtitle: artistNames.isEmpty
                      ? candidate.pluginName
                      : '$artistNames • ${candidate.pluginName}',
                  imageUrl: thumbUrl,
                  selected: index == 0,
                  onTap: isApplying
                      ? null
                      : () => _applyReplacement(context, candidate),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (index == 0)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: BloomeeDialogBadge(l10n.smartReplaceBestMatch),
                        ),
                      isApplying
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Default_Theme.accentColor2,
                              ),
                            )
                          : BloomeeDialogBadge(
                              '${(candidate.confidence * 100).round()}%'),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _applyReplacement(
    BuildContext context,
    SmartTrackReplacementCandidate candidate,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _applyingTrackId = candidate.track.id);
    final player = context.read<BloomeePlayerCubit>().bloomeePlayer;

    try {
      final applyResult = await _service.applyReplacement(
        originalTrack: widget.track,
        replacement: candidate.track,
      );

      final queueTracks = player.queueTracks;
      final queueContainsOriginal =
          queueTracks.any((track) => track.id == widget.track.id);
      if (queueContainsOriginal) {
        final updatedQueue = queueTracks
            .map((track) =>
                track.id == widget.track.id ? candidate.track : track)
            .toList(growable: false);
        await player.updateQueueTracks(
          updatedQueue,
          startIndex: player.currentQueueIndex,
          doPlay: player.currentTrackInfo.id == widget.track.id,
        );
      }

      if (!mounted) return;

      // If the currently open playlist was affected, update it in-place so
      // the playlist screen reflects the change without requiring a reload.
      try {
        final playlistCubit = context.read<CurrentPlaylistCubit>();
        if (applyResult.updatedPlaylists
            .contains(playlistCubit.currentPlaylistName)) {
          playlistCubit.replaceTrack(widget.track, candidate.track);
        }
      } catch (_) {
        // CurrentPlaylistCubit not in scope (not called from playlist screen).
      }

      final playlistCount = applyResult.updatedPlaylists.length;
      final queueSuffix =
          queueContainsOriginal ? l10n.smartReplaceQueueUpdated : '';
      final playlistMessage = playlistCount == 0
          ? l10n.smartReplaceApplied(queueSuffix)
          : l10n.smartReplaceAppliedPlaylists(
              playlistCount, playlistCount == 1 ? '' : 's', queueSuffix);
      SnackbarService.showMessage(playlistMessage);
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        SnackbarService.showMessage(l10n.smartReplaceApplyFailed(e.toString()));
        setState(() => _applyingTrackId = null);
      }
    }
  }
}

class _SmartReplaceEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SmartReplaceEmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: Default_Theme.primaryColor2.withValues(alpha: 0.6),
                size: 28),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Default_Theme.primaryColor1,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Default_Theme.primaryColor2.withValues(alpha: 0.55),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
