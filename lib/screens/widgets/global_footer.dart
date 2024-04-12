import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:Bloomee/screens/widgets/mini_player_widget.dart';
import '../../theme_data/default.dart';

class GlobalFooter extends StatelessWidget {
  const GlobalFooter({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      backgroundColor: Default_Theme.themeColor,
      drawerScrimColor: Default_Theme.themeColor,
      bottomNavigationBar: SafeArea(
          child: Wrap(
        children: [
          const MiniPlayerWidget(),
          Container(
            color: Colors.transparent,
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: GNav(
              gap: 7.0,
              tabBackgroundColor: Default_Theme.accentColor2.withOpacity(0.22),
              color: Default_Theme.primaryColor2,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              activeColor: Default_Theme.accentColor2,
              textStyle: Default_Theme.secondoryTextStyleMedium.merge(
                  const TextStyle(
                      color: Default_Theme.accentColor2, fontSize: 18)),
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
                  iconSize: 27,
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
            ),
          ),
        ],
      )),
    );
  }
}
