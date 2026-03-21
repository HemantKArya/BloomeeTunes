import 'package:Bloomee/blocs/player_overlay/player_overlay_cubit.dart';
import 'package:Bloomee/screens/widgets/player_overlay_wrapper.dart';
import 'package:Bloomee/screens/widgets/mini_player_widget.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:responsive_framework/responsive_framework.dart';

class GlobalFooter extends StatelessWidget {
  const GlobalFooter({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    // Watch overlay state so footer rebuilds when player visibility changes.
    context.watch<PlayerOverlayCubit>();
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return PlayerOverlayWrapper(
      child: BackButtonListener(
        onBackButtonPressed: () async {
          final overlayC = context.read<PlayerOverlayCubit>();
          if (!overlayC.state) return false;

          if (!overlayC.collapseUpNextPanel()) {
            overlayC.hidePlayer();
          }
          return true;
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
            body: isMobile
                ? _AnimatedPageView(navigationShell: navigationShell)
                : Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: VerticalNavBar(navigationShell: navigationShell),
                      ),
                      Expanded(
                        child:
                            _AnimatedPageView(navigationShell: navigationShell),
                      ),
                    ],
                  ),
            bottomNavigationBar: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize:
                    MainAxisSize.min, // Essential for bottom navigation
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

  /// Handles complex back navigation deterministically
  Future<void> _handleHardwareBackPress(BuildContext context) async {
    final overlayC = context.read<PlayerOverlayCubit>();
    final router = GoRouter.of(context);

    if (overlayC.state) {
      if (!overlayC.collapseUpNextPanel()) {
        overlayC.hidePlayer();
      }
      return;
    }

    if (router.canPop()) {
      router.pop();
      return;
    }

    if (navigationShell.currentIndex != 0) {
      navigationShell.goBranch(0);
      return;
    }

    if (context.mounted) {
      await SystemNavigator.pop();
    }
  }
}

class _AnimatedPageView extends StatefulWidget {
  const _AnimatedPageView({required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  State<_AnimatedPageView> createState() => _AnimatedPageViewState();
}

class _AnimatedPageViewState extends State<_AnimatedPageView>
    with SingleTickerProviderStateMixin {
  // Optimization: Use SingleTickerProvider
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.navigationShell.currentIndex;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250), // slightly smoother duration
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void didUpdateWidget(_AnimatedPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Deterministic check: Only animate if the tab ACTUALLY changed.
    // Prevents random UI jumps if parent widget rebuilds.
    if (widget.navigationShell.currentIndex != _previousIndex) {
      _previousIndex = widget.navigationShell.currentIndex;
      _animationController.forward(
          from: 0.0); // cleaner than reset() + forward()
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.navigationShell,
      ),
    );
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
      minWidth: 70, // Slightly improved touch target for desktop
      onDestinationSelected: navigationShell.goBranch, // Clean tear-off
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

    return GNav(
      gap: 7.0,
      tabBackgroundColor: Default_Theme.accentColor2.withValues(alpha: 0.22),
      color: Default_Theme.primaryColor2,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      activeColor: Default_Theme.accentColor2,
      textStyle: Default_Theme.secondoryTextStyleMedium.merge(
          const TextStyle(color: Default_Theme.accentColor2, fontSize: 18)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      backgroundColor: Default_Theme.themeColor.withValues(alpha: 0.3),
      tabs: [
        GButton(icon: MingCute.home_4_fill, text: l10n.navHome),
        GButton(icon: MingCute.book_5_fill, text: l10n.navLibrary),
        GButton(icon: MingCute.search_2_fill, text: l10n.navSearch),
        GButton(icon: MingCute.music_2_fill, text: l10n.navLocal),
        GButton(icon: MingCute.folder_download_fill, text: l10n.navOffline),
      ],
      selectedIndex: navigationShell.currentIndex,
      onTabChange: navigationShell.goBranch, // Clean tear-off
    );
  }
}
