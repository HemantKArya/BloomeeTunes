import 'dart:io';

import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/setting_shared_widgets.dart';
import 'package:Bloomee/services/desktop_tray.dart';
import 'package:Bloomee/services/desktop_window.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';

/// Window and tray behaviour on desktop.
class WindowSettings extends StatelessWidget {
  const WindowSettings({super.key});

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
          l10n.settingsWindow,
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
          child: ValueListenableBuilder<DesktopCloseAction>(
            valueListenable: DesktopWindow.closeAction,
            builder: (context, action, _) => ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                SettingSectionHeader(label: l10n.windowCloseSection),
                _CloseOptions(selected: action),
                if (!DesktopTray.isAvailable &&
                    action == DesktopCloseAction.tray)
                  _Note(text: l10n.windowTrayUnavailable),
                const SizedBox(height: 28),
                SettingSectionHeader(label: l10n.windowTrayMenuSection),
                const _TrayMenuPreview(),
                _Note(text: _trayFootnote(l10n), muted: true),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _trayFootnote(AppLocalizations l10n) => Platform.isMacOS
      ? l10n.windowTrayFootnoteMac
      : Platform.isLinux
          ? l10n.windowTrayFootnoteLinux
          : l10n.windowTrayFootnote;
}

class _CloseOptions extends StatelessWidget {
  const _CloseOptions({required this.selected});

  final DesktopCloseAction selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mac = Platform.isMacOS;
    final options = [
      (
        DesktopCloseAction.tray,
        MingCute.music_3_fill,
        mac ? l10n.windowCloseTrayMac : l10n.windowCloseTray,
        l10n.windowCloseTraySubtitle,
      ),
      (
        DesktopCloseAction.minimize,
        MingCute.minimize_fill,
        l10n.windowCloseMinimize,
        mac
            ? l10n.windowCloseMinimizeSubtitleMac
            : l10n.windowCloseMinimizeSubtitle,
      ),
      (
        DesktopCloseAction.quit,
        MingCute.power_fill,
        l10n.windowCloseQuit,
        l10n.windowCloseQuitSubtitle,
      ),
    ];

    return SettingCard(children: [
      for (final (i, o) in options.indexed) ...[
        if (i > 0) const SettingDivider(),
        _CloseOptionTile(
          icon: o.$2,
          title: o.$3,
          subtitle: o.$4,
          selected: o.$1 == selected,
          first: i == 0,
          last: i == options.length - 1,
          onTap: () => DesktopWindow.setCloseAction(o.$1),
        ),
      ],
    ]);
  }
}

class _CloseOptionTile extends StatelessWidget {
  const _CloseOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.first,
    required this.last,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final bool first;
  final bool last;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.vertical(
      top: Radius.circular(first ? 20 : 0),
      bottom: Radius.circular(last ? 20 : 0),
    );
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          highlightColor: Default_Theme.primaryColor2.withValues(alpha: 0.04),
          splashColor: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
            decoration: BoxDecoration(
              borderRadius: radius,
              color: selected
                  ? Default_Theme.accentColor2.withValues(alpha: 0.06)
                  : Colors.transparent,
            ),
            child: Row(
              children: [
                SettingIconBox(
                  icon: icon,
                  color: selected
                      ? Default_Theme.accentColor2
                      : Default_Theme.primaryColor2.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Default_Theme.secondoryTextStyleMedium.copyWith(
                          color: Default_Theme.primaryColor2
                              .withValues(alpha: selected ? 1 : 0.75),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: Default_Theme.secondoryTextStyle.copyWith(
                          color: Default_Theme.primaryColor2
                              .withValues(alpha: 0.45),
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _RadioMark(selected: selected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RadioMark extends StatelessWidget {
  const _RadioMark({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? Default_Theme.accentColor2 : Colors.transparent,
        border: Border.all(
          color: selected
              ? Default_Theme.accentColor2
              : Default_Theme.primaryColor2.withValues(alpha: 0.28),
          width: 2,
        ),
      ),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: selected ? 1 : 0,
        child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
      ),
    );
  }
}

/// A live picture of the tray menu, so the controls are discoverable.
class _TrayMenuPreview extends StatelessWidget {
  const _TrayMenuPreview();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final player = context.read<BloomeePlayerCubit>().bloomeePlayer;
    return StreamBuilder<MediaItem?>(
      stream: player.mediaItem,
      initialData: player.mediaItem.valueOrNull,
      builder: (context, snapshot) {
        final item = snapshot.data;
        final nowPlaying = item == null
            ? l10n.trayNothingPlaying
            : [item.title, if ((item.artist ?? '').isNotEmpty) item.artist]
                .join(' — ');
        return Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 300),
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1C141E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _MenuRow(
                  icon: MingCute.music_2_fill,
                  label: nowPlaying,
                  dim: true,
                ),
                const _MenuDivider(),
                _MenuRow(icon: MingCute.play_fill, label: l10n.trayPlay),
                _MenuRow(
                    icon: MingCute.skip_forward_fill, label: l10n.trayNext),
                _MenuRow(
                    icon: MingCute.skip_previous_fill,
                    label: l10n.trayPrevious),
                const _MenuDivider(),
                _MenuRow(icon: MingCute.eye_2_fill, label: l10n.trayHideWindow),
                const _MenuDivider(),
                _MenuRow(icon: MingCute.power_fill, label: l10n.trayQuit),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.icon, required this.label, this.dim = false});

  final IconData icon;
  final String label;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    final color =
        Default_Theme.primaryColor2.withValues(alpha: dim ? 0.45 : 0.85);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Default_Theme.secondoryTextStyle.copyWith(
                color: color,
                fontSize: 13,
                fontWeight: dim ? FontWeight.w500 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  const _MenuDivider();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Divider(
          height: 1,
          color: Colors.white.withValues(alpha: 0.07),
        ),
      );
}

class _Note extends StatelessWidget {
  const _Note({required this.text, this.muted = false});

  final String text;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 14, 4, 0),
      child: Text(
        text,
        textAlign: muted ? TextAlign.center : TextAlign.start,
        style: Default_Theme.secondoryTextStyle.copyWith(
          color:
              Default_Theme.primaryColor2.withValues(alpha: muted ? 0.38 : 0.6),
          fontSize: 12,
          height: 1.5,
        ),
      ),
    );
  }
}
