import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:Bloomee/screens/widgets/mini_player_widget.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../theme_data/default.dart';

class GlobalFooter extends StatelessWidget {
  const GlobalFooter({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            icon: Icon(MingCute.search_2_fill), label: Text('Search')),
        NavigationRailDestination(
            icon: Icon(MingCute.folder_download_fill), label: Text('Offline')),
      ],
      selectedIndex: navigationShell.currentIndex,
      minWidth: 65,

      onDestinationSelected: (value) {
        navigationShell.goBranch(value);
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
    return GNav(
      gap: 7.0,
      tabBackgroundColor: Default_Theme.accentColor2.withOpacity(0.22),
      color: Default_Theme.primaryColor2,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      activeColor: Default_Theme.accentColor2,
      textStyle: Default_Theme.secondoryTextStyleMedium.merge(
          const TextStyle(color: Default_Theme.accentColor2, fontSize: 18)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      backgroundColor: Default_Theme.themeColor.withOpacity(0.3),
      tabs: const [
        // GButton(
        //   icon: MingCute.home_4_fill,
        //   iconSize: 27,
        //   text: "Test",
        // ),
        GButton(
          icon: MingCute.home_4_fill,
          text: "Home",
        ),
        GButton(
          icon: MingCute.book_5_fill,
          text: "Library",
        ),
        GButton(
          icon: MingCute.search_2_fill,
          text: "Search",
        ),
        GButton(
          icon: MingCute.folder_download_fill,
          text: "Offline",
        ),
      ],
      selectedIndex: navigationShell.currentIndex,
      onTabChange: (value) {
        navigationShell.goBranch(value);
      },
    );
  }
}
