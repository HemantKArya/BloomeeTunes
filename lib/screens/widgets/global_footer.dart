import 'package:Bloomee/blocs/player_overlay/player_overlay_cubit.dart';
import 'package:Bloomee/screens/widgets/player_overlay_wrapper.dart';
import 'package:Bloomee/screens/widgets/mini_player_widget.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:icons_plus/icons_plus.dart';

/// Whether to show the bottom navigation bar (true) or the side rail (false).
///
/// Follows Android/Material guidance instead of a raw width cut-off:
/// - Phones and phablets (shortest side < 600dp, the `sw600dp` qualifier)
///   always get the bottom bar, in portrait AND landscape, and regardless of
///   a large "display size"/font-scale setting or foldable cover screens.
/// - Tablets (shortest side >= 600dp) get the rail.
/// - Desktop windows have no fixed device class, so they follow width:
///   below 600dp (Material "compact") they get the bottom bar.
bool _useBottomNav(BuildContext context) {
  final size = MediaQuery.sizeOf(context);
  switch (defaultTargetPlatform) {
    case TargetPlatform.windows:
    case TargetPlatform.linux:
    case TargetPlatform.macOS:
      return size.width < 600;
    case TargetPlatform.android:
    case TargetPlatform.iOS:
    case TargetPlatform.fuchsia:
      return size.shortestSide < 600;
  }
}

class GlobalFooter extends StatelessWidget {
  const GlobalFooter({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final isMobile = _useBottomNav(context);

    return PlayerOverlayWrapper(
      child: BackButtonListener(
        // FIX H-04: Back button priority order:
        // ① Navigator routes (FullscreenLyricsView, PlayerSettings, TimerView, etc.)
        // ② UpNext panel collapse
        // ③ Player overlay hide
        // ④ GoRouter shell navigation
        // ⑤ System exit
        //
        // Previously the handler short-circuited at step ③ whenever the player
        // was visible, swallowing Navigator pops and causing sub-screens to
        // appear orphaned over a hidden/collapsed player.
        onBackButtonPressed: () async {
          final overlayC = context.read<PlayerOverlayCubit>();
          final router = GoRouter.of(context);

          // ① Navigator MUST have first priority — always.
          if (router.canPop()) {
            router.pop();
            return true;
          }

          // ② Collapse UpNext panel if expanded (player must be visible).
          if (overlayC.state && overlayC.collapseUpNextPanel()) {
            return true;
          }

          // ③ Hide the player overlay.
          if (overlayC.state) {
            overlayC.hidePlayer();
            return true;
          }

          // ④ Let PopScope handle tab/exit navigation below.
          return false;
        },
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            await _handleHardwareBackPress(context);
          },
          child: Scaffold(
            backgroundColor: Default_Theme.themeColor,
            drawerScrimColor: Default_Theme.themeColor,
            // The shell must not resize for the keyboard: its body holds every
            // tab, so each keyboard frame would relayout all of them. The
            // active tab handles insets itself (see ShellBranchContainer).
            resizeToAvoidBottomInset: false,
            // Tabs switch instantly. A fade/scale transition here wrapped the
            // whole page in an offscreen layer for every frame of the switch,
            // which measured at 25-115ms raster frames per tab change.
            body: isMobile
                ? navigationShell
                : Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: VerticalNavBar(navigationShell: navigationShell),
                      ),
                      Expanded(
                        child: navigationShell,
                      ),
                    ],
                  ),
            bottomNavigationBar: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const MiniPlayerWidget(),
                  if (isMobile)
                    Container(
                      color: Colors.transparent,
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      child: HorizontalNavBar(navigationShell: navigationShell),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Handles PopScope back presses using the same priority order as
  /// BackButtonListener above.
  Future<void> _handleHardwareBackPress(BuildContext context) async {
    final overlayC = context.read<PlayerOverlayCubit>();
    final router = GoRouter.of(context);

    // ① Navigator routes first
    if (router.canPop()) {
      router.pop();
      return;
    }

    // ② Collapse UpNext panel
    if (overlayC.state && overlayC.collapseUpNextPanel()) return;

    // ③ Hide player
    if (overlayC.state) {
      overlayC.hidePlayer();
      return;
    }

    // ④ Navigate to home tab
    if (navigationShell.currentIndex != 0) {
      navigationShell.goBranch(0);
      return;
    }

    // ⑤ Exit app
    if (context.mounted) {
      await SystemNavigator.pop();
    }
  }
}

class VerticalNavBar extends StatelessWidget {
  const VerticalNavBar({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return NavigationRail(
      backgroundColor: Default_Theme.themeColor.withValues(alpha: 0.3),
      destinations: [
        NavigationRailDestination(
            icon: const Icon(MingCute.home_4_fill), label: Text(l10n.navHome)),
        NavigationRailDestination(
            icon: const Icon(MingCute.book_5_fill),
            label: Text(l10n.navLibrary)),
        NavigationRailDestination(
            icon: const Icon(MingCute.search_2_fill),
            label: Text(l10n.navSearch)),
        NavigationRailDestination(
            icon: const Icon(MingCute.music_2_fill),
            label: Text(l10n.navLocal)),
        NavigationRailDestination(
            icon: const Icon(MingCute.folder_download_fill),
            label: Text(l10n.navOffline)),
      ],
      selectedIndex: navigationShell.currentIndex,
      minWidth: 70,
      onDestinationSelected: navigationShell.goBranch,
      groupAlignment: 0.0,
      unselectedIconTheme:
          const IconThemeData(color: Default_Theme.primaryColor2),
      indicatorColor: Default_Theme.accentColor2,
      indicatorShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
    );
  }
}

class HorizontalNavBar extends StatelessWidget {
  const HorizontalNavBar({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(builder: (context, constraints) {
      final labels = [
        l10n.navHome,
        l10n.navLibrary,
        l10n.navSearch,
        l10n.navLocal,
        l10n.navOffline,
      ];
      final textStyle = Default_Theme.secondoryTextStyleMedium.merge(
          const TextStyle(color: Default_Theme.accentColor2, fontSize: 18));
      final compact = constraints.maxWidth < 420 ||
          labels.any((label) {
            final painter = TextPainter(
              text: TextSpan(text: label, style: textStyle),
              textDirection: Directionality.of(context),
              textScaler: MediaQuery.textScalerOf(context),
            )..layout();
            final fits =
                painter.width + labels.length * 56 + 16 <= constraints.maxWidth;
            painter.dispose();
            return !fits;
          });
      const icons = [
        MingCute.home_4_fill,
        MingCute.book_5_fill,
        MingCute.search_2_fill,
        MingCute.music_2_fill,
        MingCute.folder_download_fill,
      ];
      // Each icon keeps a 48px target. Cap the selected label at the
      // remaining space, while letting short labels keep their natural width.
      const selectedLabelEndPadding = 8.0;
      final labelWidth = (constraints.maxWidth -
              labels.length * 48 -
              7 -
              selectedLabelEndPadding)
          .clamp(1.0, double.infinity);
      return GNav(
        gap: 7,
        tabBackgroundColor: Default_Theme.accentColor2.withValues(alpha: 0.22),
        color: Default_Theme.primaryColor2,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        activeColor: Default_Theme.accentColor2,
        textStyle: textStyle,
        padding:
            EdgeInsets.symmetric(horizontal: compact ? 12 : 16, vertical: 12),
        backgroundColor: Default_Theme.themeColor.withValues(alpha: 0.3),
        tabs: List.generate(labels.length, (index) {
          final selected = index == navigationShell.currentIndex;
          return GButton(
            icon: icons[index],
            text: compact ? '' : labels[index],
            semanticLabel: labels[index],
            leading: compact
                ? Tooltip(
                    message: labels[index],
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(icons[index],
                          size: 24,
                          color: selected
                              ? Default_Theme.accentColor2
                              : Default_Theme.primaryColor2),
                      if (selected) ...[
                        const SizedBox(width: 7),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: labelWidth),
                          child: Text(labels[index],
                              style: Default_Theme.secondoryTextStyleMedium
                                  .copyWith(
                                      fontSize: 16,
                                      color: Default_Theme.accentColor2)),
                        ),
                        const SizedBox(width: selectedLabelEndPadding),
                      ],
                    ]),
                  )
                : null,
          );
        }),
        selectedIndex: navigationShell.currentIndex,
        onTabChange: navigationShell.goBranch,
      );
    });
  }
}
