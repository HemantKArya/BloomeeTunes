import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/setting_shared_widgets.dart';
import 'package:Bloomee/services/discord_service.dart';
import 'package:Bloomee/src/rust/api/discord.dart';
import 'package:Bloomee/utils/load_image.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';

Color get _muted => Default_Theme.primaryColor2.withValues(alpha: 0.5);

class DiscordSettings extends StatelessWidget {
  const DiscordSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(
        backgroundColor: Default_Theme.themeColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Center(
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded,
                  color: Default_Theme.primaryColor1, size: 24),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          l10n.discordTitle,
          style: const TextStyle(
            color: Default_Theme.primaryColor1,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ).merge(Default_Theme.secondoryTextStyleMedium),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ValueListenableBuilder<DiscordPresenceSettings>(
            valueListenable: DiscordService.settings,
            builder: (context, s, _) => ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                const SettingSectionHeader(label: 'Rich Presence'),
                SettingCard(children: [
                  SettingToggleTile(
                    icon: MingCute.discord_fill,
                    title: l10n.discordEnable,
                    subtitle: l10n.discordEnableSubtitle,
                    value: s.enabled,
                    onChanged: (v) =>
                        DiscordService.updateSettings(s.copyWith(enabled: v)),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: s.enabled
                        ? const Column(children: [
                            SettingDivider(),
                            _ConnectionTile(),
                          ])
                        : const SizedBox(width: double.infinity),
                  ),
                ]),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  child: s.enabled
                      ? _Options(key: const ValueKey('on'), settings: s)
                      : const SizedBox(key: ValueKey('off')),
                ),
                _Footnote(text: l10n.discordFooter),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Options extends StatelessWidget {
  final DiscordPresenceSettings settings;
  const _Options({required this.settings, super.key});

  void _set(DiscordPresenceSettings next) =>
      DiscordService.updateSettings(next);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final s = settings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 28),
        SettingSectionHeader(label: l10n.discordSectionPreview),
        _PresencePreview(settings: s),
        const SizedBox(height: 28),
        SettingSectionHeader(label: l10n.discordSectionCard),
        SettingCard(children: [
          SettingDropdownTile<DiscordStatusDisplay>(
            icon: MingCute.user_3_fill,
            title: l10n.discordStatusText,
            subtitle: l10n.discordStatusTextSubtitle,
            value: s.statusDisplay,
            items: [
              SettingDropdownItem(
                  value: DiscordStatusDisplay.appName,
                  label: l10n.discordStatusTextApp),
              SettingDropdownItem(
                  value: DiscordStatusDisplay.details,
                  label: l10n.discordStatusTextSong),
              SettingDropdownItem(
                  value: DiscordStatusDisplay.state,
                  label: l10n.discordStatusTextArtist),
            ],
            onChanged: (v) {
              if (v != null) _set(s.copyWith(statusDisplay: v));
            },
          ),
          const SettingDivider(),
          SettingToggleTile(
            icon: MingCute.pic_fill,
            title: l10n.discordShowArtwork,
            subtitle: l10n.discordShowArtworkSubtitle,
            value: s.showArtwork,
            onChanged: (v) => _set(s.copyWith(showArtwork: v)),
          ),
          const SettingDivider(),
          SettingToggleTile(
            icon: MingCute.time_fill,
            title: l10n.discordShowProgress,
            subtitle: l10n.discordShowProgressSubtitle,
            value: s.showProgress,
            onChanged: (v) => _set(s.copyWith(showProgress: v)),
          ),
          const SettingDivider(),
          SettingToggleTile(
            icon: MingCute.link_2_fill,
            title: l10n.discordShowLinks,
            subtitle: l10n.discordShowLinksSubtitle,
            value: s.showLinks,
            onChanged: (v) => _set(s.copyWith(showLinks: v)),
          ),
        ]),
        const SizedBox(height: 28),
        SettingSectionHeader(label: l10n.discordWhenPaused),
        SettingCard(children: [
          for (final (i, option) in [
            (
              DiscordPausedBehavior.hideAfterDelay,
              l10n.discordPausedHideLater,
              l10n.discordPausedHideLaterSubtitle
            ),
            (
              DiscordPausedBehavior.keep,
              l10n.discordPausedKeep,
              l10n.discordPausedKeepSubtitle
            ),
            (
              DiscordPausedBehavior.hide,
              l10n.discordPausedHide,
              l10n.discordPausedHideSubtitle
            ),
          ].indexed) ...[
            if (i > 0) const SettingDivider(),
            SettingRadioTile<DiscordPausedBehavior>(
              title: option.$2,
              subtitle: option.$3,
              value: option.$1,
              groupValue: s.whenPaused,
              onChanged: (v) {
                if (v != null) _set(s.copyWith(whenPaused: v));
              },
            ),
          ],
        ]),
        const SizedBox(height: 28),
        SettingSectionHeader(label: l10n.discordSectionPrivacy),
        SettingCard(children: [
          SettingToggleTile(
            icon: MingCute.folder_2_fill,
            title: l10n.discordShareLocal,
            subtitle: l10n.discordShareLocalSubtitle,
            value: s.shareLocalFiles,
            onChanged: (v) => _set(s.copyWith(shareLocalFiles: v)),
          ),
        ]),
      ],
    );
  }
}

class _Footnote extends StatelessWidget {
  final String text;
  const _Footnote({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 0),
      child: Text(
        text,
        style: Default_Theme.secondoryTextStyle.copyWith(
          color: Default_Theme.primaryColor2.withValues(alpha: 0.38),
          fontSize: 12,
          height: 1.5,
        ),
      ),
    );
  }
}

// ── Connection status ────────────────────────────────────────────────────────

class _ConnectionTile extends StatelessWidget {
  const _ConnectionTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ValueListenableBuilder<DiscordStatus?>(
      valueListenable: DiscordService.status,
      builder: (context, status, _) {
        final state = status?.state ?? DiscordConnectionState.idle;
        final user = status?.user;
        // Neutral icon boxes like every other settings row: the state reads
        // through the icon and how bright the text is, not through colour.
        // Only a real error gets a (soft) red.
        final (IconData icon, bool active, String title, String? detail) =
            switch (state) {
          DiscordConnectionState.connected => (
              MingCute.discord_fill,
              true,
              user == null
                  ? l10n.discordStatusConnectedNoUser
                  : l10n.discordStatusConnected(
                      user.displayName ?? user.username),
              status?.message ??
                  (user != null && user.displayName != null
                      ? '@${user.username}'
                      : null),
            ),
          DiscordConnectionState.connecting => (
              MingCute.discord_line,
              false,
              l10n.discordStatusConnecting,
              null,
            ),
          DiscordConnectionState.notFound => (
              MingCute.unlink_line,
              false,
              l10n.discordStatusNotFound,
              l10n.discordStatusRetry(status?.retryInSecs ?? 0),
            ),
          DiscordConnectionState.error => (
              MingCute.warning_line,
              false,
              l10n.discordStatusError,
              status?.message,
            ),
          DiscordConnectionState.idle => (
              MingCute.discord_line,
              false,
              l10n.discordStatusIdle,
              l10n.discordStatusIdleDetail,
            ),
        };
        final isError = state == DiscordConnectionState.error;
        final avatar =
            state == DiscordConnectionState.connected ? user?.avatarUrl : null;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: Row(
            children: [
              _StatusBadge(
                icon: icon,
                active: active,
                error: isError,
                avatarUrl: avatar,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Default_Theme.secondoryTextStyleMedium.copyWith(
                        color: Default_Theme.primaryColor2
                            .withValues(alpha: active || isError ? 1 : 0.6),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (detail != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        detail,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Default_Theme.secondoryTextStyle.copyWith(
                          color: isError
                              ? Colors.redAccent.withValues(alpha: 0.75)
                              : Default_Theme.primaryColor2
                                  .withValues(alpha: active ? 0.5 : 0.38),
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _ReconnectButton(
                busy: state == DiscordConnectionState.connecting,
                tooltip: l10n.discordReconnect,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Same 40×40 box as [SettingIconBox] so the row lines up with the toggle
/// above. Connected shows your Discord avatar with a small online pip;
/// every other state is the plain box with a greyed icon.
class _StatusBadge extends StatelessWidget {
  final IconData icon;
  final bool active;
  final bool error;
  final String? avatarUrl;

  const _StatusBadge({
    required this.icon,
    required this.active,
    required this.error,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final box = SettingIconBox(
      icon: icon,
      color: error
          ? Colors.redAccent.withValues(alpha: 0.8)
          : Default_Theme.primaryColor2.withValues(alpha: active ? 0.7 : 0.3),
    );
    final url = avatarUrl;
    if (url == null) return box;
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              url,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => box,
            ),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF23A55A),
                shape: BoxShape.circle,
                border: Border.all(color: Default_Theme.themeColor, width: 2.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReconnectButton extends StatefulWidget {
  final bool busy;
  final String tooltip;
  const _ReconnectButton({required this.busy, required this.tooltip});

  @override
  State<_ReconnectButton> createState() => _ReconnectButtonState();
}

class _ReconnectButtonState extends State<_ReconnectButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900));

  @override
  void initState() {
    super.initState();
    if (widget.busy) _spin.repeat();
  }

  @override
  void didUpdateWidget(_ReconnectButton old) {
    super.didUpdateWidget(old);
    if (widget.busy && !_spin.isAnimating) _spin.repeat();
    if (!widget.busy && _spin.isAnimating) _finishTurn();
  }

  /// Completes the current turn instead of snapping back mid-rotation.
  void _finishTurn() {
    _spin.forward(from: _spin.value).then((_) {
      if (mounted && !widget.busy) _spin.value = 0;
    });
  }

  void _tap() {
    DiscordService.reconnect();
    if (!_spin.isAnimating) _spin.forward(from: 0);
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: Material(
        color: Default_Theme.primaryColor2.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
              color: Default_Theme.primaryColor2.withValues(alpha: 0.08)),
        ),
        child: InkWell(
          onTap: widget.busy ? null : _tap,
          borderRadius: BorderRadius.circular(12),
          highlightColor: Default_Theme.primaryColor2.withValues(alpha: 0.05),
          splashColor: Default_Theme.accentColor2.withValues(alpha: 0.12),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: RotationTransition(
                turns: _spin,
                child: Icon(
                  MingCute.refresh_2_line,
                  size: 18,
                  color: Default_Theme.primaryColor2.withValues(alpha: 0.8),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Card preview ─────────────────────────────────────────────────────────────

/// Mirrors what Discord renders, using the same title/artist/album rules as
/// [DiscordService], so the preview never shows lines Discord won't.
class _PresencePreview extends StatelessWidget {
  final DiscordPresenceSettings settings;
  const _PresencePreview({required this.settings});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<BloomeePlayerCubit>();
    final player = cubit.bloomeePlayer;
    return StreamBuilder<MediaItem?>(
      stream: player.mediaItem,
      initialData: player.mediaItem.valueOrNull,
      builder: (context, snap) {
        final item = snap.data;
        final s = settings;
        final hasTrack = item != null && item.title.trim().isNotEmpty;
        final title = item?.title.trim() ?? '';
        final artist = DiscordService.artistLine(
            (item?.artist ?? '').split(', '),
            title: title,
            album: item?.album);
        final album = DiscordService.albumLine(
            title: title, album: item?.album, artists: artist);
        final heading = l10n.discordKindListening;

        return SettingCard(children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: !hasTrack
                ? _EmptyPreview(text: l10n.discordPreviewEmpty)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(MingCute.discord_fill, size: 14, color: _muted),
                        const SizedBox(width: 6),
                        Text(
                          heading.toUpperCase(),
                          style: Default_Theme.secondoryTextStyle.copyWith(
                            color: _muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        if (s.showArtwork) ...[
                          _PreviewArt(url: item.artUri?.toString()),
                          const SizedBox(width: 14),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _line(title, size: 15, alpha: 0.95, bold: true),
                              if (artist != null) _line(artist, alpha: 0.7),
                              if (album != null) _line(album, alpha: 0.45),
                            ],
                          ),
                        ),
                      ]),
                      if (s.showProgress) ...[
                        const SizedBox(height: 14),
                        _PreviewProgress(cubit: cubit),
                      ],
                      const SizedBox(height: 14),
                      const _PreviewButton(
                          label: DiscordService.getBloomeeLabel),
                    ],
                  ),
          ),
        ]);
      },
    );
  }

  static Widget _line(String text,
      {double size = 13, double alpha = 0.8, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Default_Theme.secondoryTextStyleMedium.copyWith(
          color: Default_Theme.primaryColor2.withValues(alpha: alpha),
          fontSize: size,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          letterSpacing: bold ? -0.2 : 0,
        ),
      ),
    );
  }
}

class _EmptyPreview extends StatelessWidget {
  final String text;
  const _EmptyPreview({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        const SettingIconBox(icon: MingCute.music_2_line),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: Default_Theme.secondoryTextStyle
                .copyWith(color: _muted, fontSize: 13),
          ),
        ),
      ]),
    );
  }
}

class _PreviewArt extends StatelessWidget {
  final String? url;
  const _PreviewArt({required this.url});

  @override
  Widget build(BuildContext context) {
    final placeholder = ColoredBox(
      color: Default_Theme.primaryColor2.withValues(alpha: 0.06),
      child: Icon(MingCute.music_2_fill, color: _muted),
    );
    final u = url;
    return SizedBox(
      width: 76,
      height: 76,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: u == null || u.isEmpty
                  ? placeholder
                  : Image(
                      image: ResizeImage.resizeIfNeeded(
                          152, 152, getImageProviderSync(u)),
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                      errorBuilder: (_, __, ___) => placeholder,
                    ),
            ),
          ),
          Positioned(
            right: -5,
            bottom: -5,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Default_Theme.accentColor2,
                shape: BoxShape.circle,
                border: Border.all(color: Default_Theme.themeColor, width: 3),
              ),
              child:
                  const Icon(MingCute.play_fill, size: 10, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewProgress extends StatelessWidget {
  final BloomeePlayerCubit cubit;
  const _PreviewProgress({required this.cubit});

  static String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final style = Default_Theme.secondoryTextStyle.copyWith(
      color: _muted,
      fontSize: 11,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return StreamBuilder<ProgressBarStreams>(
      stream: cubit.progressStreams,
      builder: (context, snap) {
        final p = snap.data;
        final total = p?.duration ?? Duration.zero;
        final pos = p?.position ?? Duration.zero;
        final value = total.inMilliseconds > 0
            ? (pos.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0)
            : 0.0;
        return Row(children: [
          Text(_fmt(pos), style: style),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 4,
                backgroundColor:
                    Default_Theme.primaryColor2.withValues(alpha: 0.08),
                valueColor:
                    const AlwaysStoppedAnimation(Default_Theme.primaryColor2),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(_fmt(total), style: style),
        ]);
      },
    );
  }
}

class _PreviewButton extends StatelessWidget {
  final String label;
  const _PreviewButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        color: Default_Theme.primaryColor2.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: Default_Theme.primaryColor2.withValues(alpha: 0.06)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: Default_Theme.secondoryTextStyleMedium.copyWith(
          color: Default_Theme.primaryColor2.withValues(alpha: 0.9),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
