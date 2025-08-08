import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:Bloomee/screens/screen/music_reels_screen.dart';
import 'package:Bloomee/screens/widgets/mini_player_widget.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../theme_data/default.dart';
import 'package:Bloomee/blocs/mediaPlayer/bloomee_player_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GlobalFooter extends StatelessWidget {
  const GlobalFooter({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: navigationShell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          navigationShell.goBranch(0);
        }
      },
      child: Scaffold(
        body: ResponsiveBreakpoints.of(context).isMobile
            ? navigationShell
            : Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: VerticalNavBar(navigationShell: navigationShell),
                  ),
                  Expanded(child: navigationShell),
                ],
              ),
        backgroundColor: Default_Theme.themeColor,
        drawerScrimColor: Default_Theme.themeColor,
        bottomNavigationBar: SafeArea(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const MiniPlayerWidget(),
            Container(
              color: Colors.transparent,
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: ResponsiveBreakpoints.of(context).isMobile
                  ? HorizontalNavBar(navigationShell: navigationShell)
                  : const Wrap(),
            ),
          ],
        )),
      ),
    );
  }
}

class VerticalNavBar extends StatelessWidget {
  const VerticalNavBar({
    super.key,
    required this.navigationShell,
  });
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      backgroundColor: Default_Theme.themeColor.withOpacity(0.3),
      destinations: const [
        NavigationRailDestination(
            icon: Icon(MingCute.home_4_fill), label: Text('Home')),
        NavigationRailDestination(
            icon: Icon(MingCute.book_5_fill), label: Text('Library')),
        NavigationRailDestination(
            icon: Icon(MingCute.music_2_fill), label: Text('Reels')),
        NavigationRailDestination(
            icon: Icon(MingCute.search_2_fill), label: Text('Search')),
        NavigationRailDestination(
            icon: Icon(MingCute.folder_download_fill), label: Text('Offline')),
      ],
      selectedIndex: navigationShell.currentIndex,
      minWidth: 65,
      onDestinationSelected: (value) async {
        if (value == 2) {
          int previousIndex = navigationShell.currentIndex;
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                final playerCubit = context.read<BloomeePlayerCubit>();
                final previousIndex =
                    playerCubit.bloomeePlayer.currentPlayingIdx;
                return MusicReelsScreen(previousIndex: previousIndex);
              },
            ),
          );
          if (result is int) {
            navigationShell.goBranch(result);
          }
        } else {
          navigationShell.goBranch(value > 2 ? value - 1 : value);
        }
      },
      groupAlignment: 0.0,
      // selectedIconTheme: IconThemeData(color: Default_Theme.accentColor2),
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
  const HorizontalNavBar({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Default_Theme.themeColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(25),
      ),
      child: GNav(
        gap: 0,
        tabBackgroundColor: Default_Theme.accentColor2.withOpacity(0.22),
        color: Default_Theme.primaryColor2,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        activeColor: Default_Theme.accentColor2,
        iconSize: 26,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        duration: const Duration(milliseconds: 400),
        tabs: const [
          GButton(
            icon: MingCute.home_4_fill,
            iconSize: 26,
          ),
          GButton(
            icon: MingCute.book_5_fill,
            iconSize: 26,
          ),
          GButton(
            icon: MingCute.music_2_fill,
            iconSize: 26,
          ),
          GButton(
            icon: MingCute.search_2_fill,
            iconSize: 26,
          ),
          GButton(
            icon: MingCute.folder_download_fill,
            iconSize: 26,
          ),
        ],
        selectedIndex: navigationShell.currentIndex,
        onTabChange: (value) {
          if (value == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  final playerCubit = context.read<BloomeePlayerCubit>();
                  final previousIndex =
                      playerCubit.bloomeePlayer.currentPlayingIdx;
                  return MusicReelsScreen(previousIndex: previousIndex);
                },
              ),
            );
          } else {
            navigationShell.goBranch(value > 2 ? value - 1 : value);
          }
        },
      ),
    );
  }
}
