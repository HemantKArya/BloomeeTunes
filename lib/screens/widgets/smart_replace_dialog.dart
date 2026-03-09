import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/services/smart_track_replacement_service.dart';
import 'package:Bloomee/src/rust/api/plugin/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';

Future<void> showSmartReplaceDialog(BuildContext context, Track track) {
  return showDialog<void>(
    context: context,
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
    return AlertDialog(
      backgroundColor: const Color(0xFF0D1B2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Smart Replace',
            style: Default_Theme.secondoryTextStyleMedium.merge(
              const TextStyle(
                color: Default_Theme.primaryColor1,
                fontSize: 19,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose a playable replacement for "${widget.track.title}" and update saved playlist references without changing their order.',
            style: TextStyle(
              color: Default_Theme.primaryColor2.withValues(alpha: 0.72),
              fontSize: 12,
              fontFamily: 'ReThink-Sans',
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: FutureBuilder<List<SmartTrackReplacementCandidate>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SizedBox(
                height: 180,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Default_Theme.accentColor2,
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return _SmartReplaceEmptyState(
                icon: MingCute.alert_fill,
                title: 'Search failed',
                subtitle: snapshot.error.toString(),
              );
            }

            final candidates = snapshot.data ?? const [];
            if (candidates.isEmpty) {
              return const _SmartReplaceEmptyState(
                icon: MingCute.search_2_line,
                title: 'No replacement found',
                subtitle:
                    'None of the currently loaded resolver plugins returned a strong enough match.',
              );
            }

            return ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 420),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: candidates.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final candidate = candidates[index];
                  final isApplying = _applyingTrackId == candidate.track.id;
                  final artistNames = candidate.track.artists
                      .map((artist) => artist.name)
                      .join(', ');

                  return InkWell(
                    onTap: isApplying
                        ? null
                        : () => _applyReplacement(context, candidate),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color:
                            Default_Theme.primaryColor2.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: index == 0
                              ? Default_Theme.accentColor2
                                  .withValues(alpha: 0.45)
                              : Default_Theme.primaryColor2
                                  .withValues(alpha: 0.08),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Default_Theme.accentColor2
                                  .withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              index == 0
                                  ? MingCute.sparkles_2_fill
                                  : MingCute.music_2_line,
                              color: Default_Theme.accentColor2,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        candidate.track.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Default_Theme.primaryColor1,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'ReThink-Sans',
                                        ),
                                      ),
                                    ),
                                    if (index == 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Default_Theme.accentColor2
                                              .withValues(alpha: 0.14),
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: const Text(
                                          'Best match',
                                          style: TextStyle(
                                            color: Default_Theme.accentColor2,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  artistNames.isEmpty
                                      ? candidate.pluginName
                                      : '$artistNames • ${candidate.pluginName}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Default_Theme.primaryColor2
                                        .withValues(alpha: 0.68),
                                    fontSize: 12,
                                    fontFamily: 'ReThink-Sans',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          isApplying
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Default_Theme.accentColor2,
                                  ),
                                )
                              : Text(
                                  '${(candidate.confidence * 100).round()}%',
                                  style: const TextStyle(
                                    color: Default_Theme.accentColor2,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Close',
            style: TextStyle(
              color: Default_Theme.primaryColor2.withValues(alpha: 0.72),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _applyReplacement(
    BuildContext context,
    SmartTrackReplacementCandidate candidate,
  ) async {
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
      final playlistCount = applyResult.updatedPlaylists.length;
      final queueMessage =
          queueContainsOriginal ? ' and updated the queue' : '';
      final playlistMessage = playlistCount == 0
          ? 'Applied replacement$queueMessage.'
          : 'Replaced in $playlistCount playlist${playlistCount == 1 ? '' : 's'}$queueMessage.';
      SnackbarService.showMessage(playlistMessage);
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        SnackbarService.showMessage('Smart Replace failed: $e');
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
      height: 180,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Default_Theme.primaryColor2, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Default_Theme.primaryColor1,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Default_Theme.primaryColor2.withValues(alpha: 0.7),
                fontSize: 12,
                fontFamily: 'ReThink-Sans',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
