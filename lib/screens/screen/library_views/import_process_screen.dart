import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';

import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:Bloomee/plugins/blocs/import/content_import_cubit.dart';
import 'package:Bloomee/plugins/blocs/import/content_import_state.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_bloc.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_state.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/src/rust/api/plugin/models.dart';

// ── Theme shorthand helpers ─────────────────────────────────────────────────

const _kBg = Default_Theme.themeColor;
const _kSurface = Color(0xFF0F1B2E);
const _kSurfaceHigh = Color(0xFF1A2840);
const _kPrimary = Default_Theme.primaryColor1;
const _kSecondary = Default_Theme.primaryColor2;
const _kAccent = Default_Theme.accentColor1;

// ── Screen ──────────────────────────────────────────────────────────────────

/// Full-screen import process.
/// [ContentImportCubit] is provided globally (main.dart) — state survives navigation.
class ImportProcessScreen extends StatefulWidget {
  final String pluginId;
  const ImportProcessScreen({super.key, required this.pluginId});

  @override
  State<ImportProcessScreen> createState() => _ImportProcessScreenState();
}

class _ImportProcessScreenState extends State<ImportProcessScreen> {
  final _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _startImport(ContentImportCubit cubit) {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;
    cubit.checkUrl(widget.pluginId, url);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PluginBloc, PluginState>(
      listenWhen: (prev, curr) =>
          prev.loadedPluginIds.contains(widget.pluginId) &&
          !curr.loadedPluginIds.contains(widget.pluginId),
      listener: (context, _) {
        if (context.mounted) context.pop();
      },
      child: Scaffold(
        backgroundColor: _kBg,
        appBar: _buildAppBar(context),
        body: BlocConsumer<ContentImportCubit, ContentImportState>(
          listener: (context, state) {
            if (state.phase == ImportPhase.done) {
              SnackbarService.showMessage(
                  AppLocalizations.of(context)!.snackbarPlaylistSaved);
            }
            if (state.phase == ImportPhase.error && state.error != null) {
              SnackbarService.showMessage(state.error!);
            }
          },
          builder: (context, state) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: _buildPhaseContent(context, state),
            );
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _kBg,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      title: BlocBuilder<ContentImportCubit, ContentImportState>(
        builder: (context, state) {
          final title = state.collectionInfo?.title;
          return Text(
            title?.isNotEmpty == true
                ? title!
                : AppLocalizations.of(context)!.importTitle,
            style: Default_Theme.secondoryTextStyle.merge(
              const TextStyle(
                color: _kPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        },
      ),
    );
  }

  Widget _buildPhaseContent(BuildContext context, ContentImportState state) {
    final cubit = context.read<ContentImportCubit>();
    switch (state.phase) {
      case ImportPhase.idle:
        return _UrlInputView(
          key: const ValueKey('url_input'),
          controller: _urlController,
          onSubmit: () => _startImport(cubit),
        );
      case ImportPhase.checkingUrl:
      case ImportPhase.fetchingInfo:
        return _LoadingView(
          key: const ValueKey('checking'),
          message: AppLocalizations.of(context)!.importCheckingUrl,
          collectionInfo: state.collectionInfo,
        );
      case ImportPhase.fetchingTracks:
        return _LoadingView(
          key: const ValueKey('fetching_tracks'),
          message: AppLocalizations.of(context)!.importFetchingTracks,
          collectionInfo: state.collectionInfo,
        );
      case ImportPhase.resolving:
        return _ResolvingView(
          key: const ValueKey('resolving'),
          state: state,
        );
      case ImportPhase.review:
        return _ReviewView(
          key: const ValueKey('review'),
          state: state,
          onSave: () => cubit.saveToLibrary(),
          onReset: () => cubit.reset(),
        );
      case ImportPhase.saving:
        return _LoadingView(
          key: const ValueKey('saving'),
          message: AppLocalizations.of(context)!.importSavingToLibrary,
          collectionInfo: state.collectionInfo,
        );
      case ImportPhase.done:
        return _DoneView(
          key: const ValueKey('done'),
          state: state,
          onDone: () => context.pop(),
          onImportMore: () => cubit.reset(),
        );
      case ImportPhase.error:
        return _ErrorView(
          key: const ValueKey('error'),
          error:
              state.error ?? AppLocalizations.of(context)!.importUnknownError,
          onRetry: () => cubit.reset(),
        );
    }
  }
}

// ── URL Input ────────────────────────────────────────────────────────────────

class _UrlInputView extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;

  const _UrlInputView({
    super.key,
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _kAccent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(MingCute.link_fill, color: _kAccent, size: 32),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.importPasteUrlHint,
            textAlign: TextAlign.center,
            style: Default_Theme.secondoryTextStyle.merge(
              TextStyle(
                  color: _kSecondary.withValues(alpha: 0.8), fontSize: 15),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kAccent.withValues(alpha: 0.18)),
            ),
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.go,
              autofocus: true,
              cursorColor: _kAccent,
              style: Default_Theme.secondoryTextStyle
                  .merge(const TextStyle(color: _kPrimary, fontSize: 15)),
              decoration: InputDecoration(
                hintText: 'https://',
                hintStyle: TextStyle(
                    color: _kSecondary.withValues(alpha: 0.4), fontSize: 15),
                prefixIcon: Icon(MingCute.link_fill,
                    color: _kSecondary.withValues(alpha: 0.5), size: 18),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (_, v, __) => v.text.isEmpty
                      ? const SizedBox.shrink()
                      : IconButton(
                          icon: Icon(MingCute.close_fill,
                              size: 16,
                              color: _kSecondary.withValues(alpha: 0.5)),
                          onPressed: controller.clear,
                        ),
                ),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              onSubmitted: (_) => onSubmit(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onSubmit,
            style: FilledButton.styleFrom(
              backgroundColor: _kAccent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(AppLocalizations.of(context)!.importAction,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3)),
          ),
        ],
      ),
    );
  }
}

// ── Loading / Fetching ───────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  final String message;
  final ImportCollectionSummary? collectionInfo;

  const _LoadingView({super.key, required this.message, this.collectionInfo});

  @override
  Widget build(BuildContext context) {
    final info = collectionInfo;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (info != null) ...[
              _CollectionHeader(info: info),
              const SizedBox(height: 32),
            ],
            const CircularProgressIndicator(color: _kAccent, strokeWidth: 3),
            const SizedBox(height: 16),
            Text(
              message,
              style: Default_Theme.secondoryTextStyle.merge(
                TextStyle(
                    color: _kSecondary.withValues(alpha: 0.7), fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Collection Header ────────────────────────────────────────────────────────

class _CollectionHeader extends StatelessWidget {
  final ImportCollectionSummary info;
  const _CollectionHeader({required this.info});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 64,
            height: 64,
            child: info.thumbnailUrl?.isNotEmpty == true
                ? CachedNetworkImage(
                    imageUrl: info.thumbnailUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _thumb(),
                    errorWidget: (_, __, ___) => _thumb(),
                  )
                : _thumb(),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                info.title,
                style: Default_Theme.primaryTextStyle.merge(
                  const TextStyle(
                      color: _kPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (info.owner != null)
                Text(
                  info.owner!,
                  style: Default_Theme.secondoryTextStyle.merge(
                    TextStyle(
                        color: _kSecondary.withValues(alpha: 0.7),
                        fontSize: 13),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              if (info.trackCount != null)
                Text(
                  AppLocalizations.of(context)!
                      .importTrackCount(info.trackCount!),
                  style: Default_Theme.secondoryTextStyle.merge(
                    TextStyle(
                        color: _kAccent.withValues(alpha: 0.8), fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _thumb() => Container(
        color: _kSurfaceHigh,
        child: Icon(MingCute.playlist_fill,
            color: _kSecondary.withValues(alpha: 0.4), size: 28),
      );
}

// ── Resolving View ───────────────────────────────────────────────────────────

class _ResolvingView extends StatelessWidget {
  final ContentImportState state;
  const _ResolvingView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final total = state.totalTracks;
    final done = state.resolvedCount + state.failedCount;
    final progress = total > 0 ? done / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.collectionInfo != null)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            color: _kSurface,
            child: _CollectionHeader(info: state.collectionInfo!),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: _kBg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!
                          .importResolvingProgress(done, total),
                      style: Default_Theme.secondoryTextStyle.merge(
                        TextStyle(
                            color: _kSecondary.withValues(alpha: 0.8),
                            fontSize: 13),
                      ),
                    ),
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: Default_Theme.secondoryTextStyle.merge(
                      const TextStyle(color: _kAccent, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: _kSecondary.withValues(alpha: 0.12),
                  valueColor: const AlwaysStoppedAnimation(_kAccent),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 4, bottom: 16),
            itemCount: state.tracks.length,
            itemBuilder: (context, index) =>
                _ResolvingTrackTile(entry: state.tracks[index]),
          ),
        ),
      ],
    );
  }
}

// ── Review View ──────────────────────────────────────────────────────────────

class _ReviewView extends StatefulWidget {
  final ContentImportState state;
  final VoidCallback onSave;
  final VoidCallback onReset;

  const _ReviewView({
    super.key,
    required this.state,
    required this.onSave,
    required this.onReset,
  });

  @override
  State<_ReviewView> createState() => _ReviewViewState();
}

class _ReviewViewState extends State<_ReviewView> {
  final Map<int, bool> _expanded = {};

  void _toggle(int i) =>
      setState(() => _expanded[i] = !(_expanded[i] ?? false));

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final toSave = s.tracks.where((t) => t.effectiveTrack != null).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          color: _kSurface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (s.collectionInfo != null)
                _CollectionHeader(info: s.collectionInfo!),
              const SizedBox(height: 10),
              Row(
                children: [
                  _StatChip(
                    icon: Icons.check_circle_rounded,
                    label: '${s.resolvedCount}',
                    color: const Color(0xFF4ADE80),
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    icon: Icons.cancel_rounded,
                    label: '${s.failedCount}',
                    color: Default_Theme.accentColor2,
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    icon: Icons.format_list_numbered_rounded,
                    label: '${s.totalTracks}',
                    color: _kSecondary.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 4, bottom: 8),
            itemCount: s.tracks.length,
            itemBuilder: (context, i) => _ReviewTrackTile(
              key: ValueKey(i),
              entry: s.tracks[i],
              index: i,
              isExpanded: _expanded[i] ?? false,
              onToggle: () => _toggle(i),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          decoration: BoxDecoration(
            color: _kSurface,
            border: Border(
              top: BorderSide(
                  color: _kSecondary.withValues(alpha: 0.1), width: 1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onReset,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _kSecondary.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(AppLocalizations.of(context)!.buttonCancel,
                      style:
                          TextStyle(color: _kSecondary.withValues(alpha: 0.8))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: toSave > 0 ? widget.onSave : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: _kAccent,
                    disabledBackgroundColor: _kAccent.withValues(alpha: 0.25),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.importSaveTracks(toSave),
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Stat chip ────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ── Resolving Track Tile ─────────────────────────────────────────────────────

class _ResolvingTrackTile extends StatelessWidget {
  final ImportTrackEntry entry;
  const _ResolvingTrackTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final src = entry.sourceTrack;
    final statusWidget = switch (entry.status) {
      TrackResolutionStatus.pending => const SizedBox(
          width: 18,
          height: 18,
          child:
              Icon(Icons.hourglass_empty_rounded, size: 14, color: Colors.grey),
        ),
      TrackResolutionStatus.resolving => const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: _kAccent),
        ),
      TrackResolutionStatus.resolved => const Icon(
          Icons.check_circle_rounded,
          size: 18,
          color: Color(0xFF4ADE80),
        ),
      TrackResolutionStatus.failed => const Icon(
          Icons.cancel_rounded,
          size: 18,
          color: Default_Theme.accentColor2,
        ),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 40,
              height: 40,
              child: src.thumbnailUrl?.isNotEmpty == true
                  ? CachedNetworkImage(
                      imageUrl: src.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _mini(),
                    )
                  : _mini(),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(src.title,
                    style: Default_Theme.secondoryTextStyle
                        .merge(const TextStyle(color: _kPrimary, fontSize: 13)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(src.artists.join(', '),
                    style: Default_Theme.secondoryTextStyle.merge(TextStyle(
                        color: _kSecondary.withValues(alpha: 0.6),
                        fontSize: 11)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          statusWidget,
        ],
      ),
    );
  }

  Widget _mini() => Container(
      color: _kSurfaceHigh,
      child: Icon(MingCute.music_2_fill,
          color: _kSecondary.withValues(alpha: 0.3), size: 16));
}

// ── Review Track Tile (expandable) ───────────────────────────────────────────

class _ReviewTrackTile extends StatelessWidget {
  final ImportTrackEntry entry;
  final int index;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _ReviewTrackTile({
    super.key,
    required this.entry,
    required this.index,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final src = entry.sourceTrack;
    final effective = entry.effectiveTrack;
    final cubit = context.read<ContentImportCubit>();

    final Color statusColor = entry.isSkipped
        ? _kSecondary.withValues(alpha: 0.5)
        : effective != null
            ? const Color(0xFF4ADE80)
            : Default_Theme.accentColor2;

    final IconData statusIcon = entry.isSkipped
        ? Icons.remove_circle_outline
        : effective != null
            ? Icons.check_circle_rounded
            : Icons.cancel_rounded;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded
              ? _kAccent.withValues(alpha: 0.25)
              : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: entry.candidates.isNotEmpty ? onToggle : null,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Row(
                children: [
                  // Source thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: src.thumbnailUrl?.isNotEmpty == true
                          ? CachedNetworkImage(
                              imageUrl: src.thumbnailUrl!,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => _mini(),
                            )
                          : _mini(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(src.title,
                            style: Default_Theme.secondoryTextStyle.merge(
                                const TextStyle(
                                    color: _kPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text(src.artists.join(', '),
                            style: Default_Theme.secondoryTextStyle.merge(
                                TextStyle(
                                    color: _kSecondary.withValues(alpha: 0.55),
                                    fontSize: 11)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        if (effective != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Row(
                              children: [
                                Icon(MingCute.arrow_right_fill,
                                    size: 10,
                                    color: _kAccent.withValues(alpha: 0.7)),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Text(
                                    '${effective.title} — ${effective.artists.map((a) => a.name).join(', ')}',
                                    style: Default_Theme.secondoryTextStyle
                                        .merge(TextStyle(
                                            color:
                                                _kAccent.withValues(alpha: 0.8),
                                            fontSize: 11)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (entry.isSkipped)
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(
                              AppLocalizations.of(context)!.importSkipped,
                              style: Default_Theme.secondoryTextStyle.merge(
                                TextStyle(
                                    color: _kSecondary.withValues(alpha: 0.45),
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Column(
                    children: [
                      Icon(statusIcon, color: statusColor, size: 18),
                      if (entry.candidates.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(Icons.expand_more_rounded,
                              color: _kSecondary.withValues(alpha: 0.5),
                              size: 16),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded && entry.candidates.isNotEmpty)
            _CandidateList(entry: entry, index: index, cubit: cubit),
        ],
      ),
    );
  }

  Widget _mini() => Container(
      color: _kSurfaceHigh,
      child: Icon(MingCute.music_2_fill,
          color: _kSecondary.withValues(alpha: 0.3), size: 16));
}

// ── Candidate Picker ─────────────────────────────────────────────────────────

class _CandidateList extends StatelessWidget {
  final ImportTrackEntry entry;
  final int index;
  final ContentImportCubit cubit;
  const _CandidateList(
      {required this.entry, required this.index, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final selected = entry.selectedCandidateIndex;
    final autoIdx = entry.resolvedTrack != null ? 0 : null;
    final effectiveSelected = selected ?? autoIdx;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(
            height: 1,
            color: _kSecondary.withValues(alpha: 0.1),
            indent: 10,
            endIndent: 10),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 2),
          child: Text(
            AppLocalizations.of(context)!.importMatchOptions,
            style: Default_Theme.secondoryTextStyle.merge(
              TextStyle(
                  color: _kAccent.withValues(alpha: 0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6),
            ),
          ),
        ),
        ...List.generate(entry.candidates.length, (ci) {
          return _CandidateTile(
            track: entry.candidates[ci],
            isSelected: effectiveSelected == ci,
            onTap: () => cubit.pickCandidate(index, ci),
          );
        }),
        _SkipTile(
          isSelected: selected == -1,
          onTap: () => cubit.pickCandidate(index, -1),
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}

class _CandidateTile extends StatelessWidget {
  final Track track;
  final bool isSelected;
  final VoidCallback onTap;
  const _CandidateTile(
      {required this.track, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Row(
          children: [
            _RadioDot(isSelected: isSelected, color: _kAccent),
            const SizedBox(width: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: SizedBox(
                width: 34,
                height: 34,
                child: track.thumbnail.url.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: track.thumbnail.url,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _mini(),
                      )
                    : _mini(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(track.title,
                      style: Default_Theme.secondoryTextStyle.merge(TextStyle(
                          color: isSelected
                              ? _kPrimary
                              : _kPrimary.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(track.artists.map((a) => a.name).join(', '),
                      style: Default_Theme.secondoryTextStyle.merge(TextStyle(
                          color: _kSecondary.withValues(alpha: 0.55),
                          fontSize: 11)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mini() => Container(
      color: _kSurfaceHigh,
      child: Icon(MingCute.music_2_fill,
          color: _kSecondary.withValues(alpha: 0.25), size: 14));
}

class _SkipTile extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  const _SkipTile({required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Row(
          children: [
            _RadioDot(
                isSelected: isSelected, color: Default_Theme.accentColor2),
            const SizedBox(width: 8),
            SizedBox(
              width: 34,
              height: 34,
              child: Center(
                child: Icon(Icons.block_rounded,
                    size: 20,
                    color: Default_Theme.accentColor2.withValues(alpha: 0.6)),
              ),
            ),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.importSkipTrack,
                style: Default_Theme.secondoryTextStyle.merge(TextStyle(
                    color: Default_Theme.accentColor2.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontStyle: FontStyle.italic))),
          ],
        ),
      ),
    );
  }
}

/// Radio dot indicator (canvas-based, no external image).
class _RadioDot extends StatelessWidget {
  final bool isSelected;
  final Color color;
  const _RadioDot({required this.isSelected, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? color : _kSecondary.withValues(alpha: 0.3),
          width: 2,
        ),
        color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            )
          : null,
    );
  }
}

// ── Done View ────────────────────────────────────────────────────────────────

class _DoneView extends StatelessWidget {
  final ContentImportState state;
  final VoidCallback onDone;
  final VoidCallback onImportMore;

  const _DoneView(
      {super.key,
      required this.state,
      required this.onDone,
      required this.onImportMore});

  @override
  Widget build(BuildContext context) {
    final thumb = state.collectionInfo?.thumbnailUrl;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                if (thumb?.isNotEmpty == true)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                      child: SizedBox(
                        width: 90,
                        height: 90,
                        child: CachedNetworkImage(
                            imageUrl: thumb!, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ADE80).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF4ADE80), size: 38),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!
                  .importTracksSaved(state.resolvedCount),
              style: Default_Theme.primaryTextStyle.merge(
                const TextStyle(
                    color: _kPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
              ),
            ),
            if (state.collectionInfo?.title.isNotEmpty == true) ...[
              const SizedBox(height: 6),
              Text(state.collectionInfo!.title,
                  style: Default_Theme.secondoryTextStyle.merge(TextStyle(
                      color: _kSecondary.withValues(alpha: 0.6),
                      fontSize: 14))),
            ],
            const SizedBox(height: 32),
            FilledButton(
              onPressed: onDone,
              style: FilledButton.styleFrom(
                backgroundColor: _kAccent,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(AppLocalizations.of(context)!.importDone,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: onImportMore,
              child: Text(AppLocalizations.of(context)!.importMore,
                  style: const TextStyle(color: _kAccent)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error View ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({super.key, required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Default_Theme.accentColor2.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded,
                  color: Default_Theme.accentColor2, size: 36),
            ),
            const SizedBox(height: 20),
            Text(error,
                textAlign: TextAlign.center,
                style: Default_Theme.secondoryTextStyle.merge(TextStyle(
                    color: _kSecondary.withValues(alpha: 0.8), fontSize: 14))),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(AppLocalizations.of(context)!.importTryAgain),
              style: FilledButton.styleFrom(
                backgroundColor: Default_Theme.accentColor2,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
