import 'dart:async';

import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/screens/widgets/bloomee_ui_kit/bloomee_dialog.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/services/meta_resolver/smart_track_replacement_service.dart';
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
    _service =
        context.read<BloomeePlayerCubit>().bloomeePlayer.smartReplacement;
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
                  onTap: isApplying ? null : () => _applyReplacement(candidate),
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
    SmartTrackReplacementCandidate candidate,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _applyingTrackId = candidate.track.id);
    final player = context.read<BloomeePlayerCubit>().bloomeePlayer;

    try {
      // Open playlist screens update from SmartTrackReplacementService.applied.
      final applied = await _service.applyReplacement(
        original: widget.track,
        replacement: candidate.track,
      );

      final queueContainsOriginal =
          player.queueTracks.any((track) => track.id == widget.track.id);
      // In place: order, shuffle and playlist title stay as they are. Not
      // awaited: if the original is current, that waits for the new load.
      unawaited(
          player.replaceTrackInQueue(candidate.track, original: widget.track));

      if (!mounted) return;

      final playlistCount = applied.playlists.length;
      final queueSuffix =
          queueContainsOriginal ? l10n.smartReplaceQueueUpdated : '';
      final playlistMessage = playlistCount == 0
          ? l10n.smartReplaceApplied(queueSuffix)
          : l10n.smartReplaceAppliedPlaylistsSummary(
              playlistCount, queueSuffix);
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
