// ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'package:feather_icons/feather_icons.dart';
// import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:Bloomee/screens/screen/explore_screen.dart';
import 'package:Bloomee/screens/screen/library_screen.dart';
import 'package:Bloomee/screens/screen/search_screen.dart';
import 'package:Bloomee/screens/screen/test_screen.dart';

import 'package:Bloomee/theme_data/default.dart';

import 'offline_screen.dart';

final _pageOptions = [
  const TestView(),
  const ExploreScreen(),
  const LibraryScreen(),
  const SearchScreen(),
  const OfflineScreen(),
];

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedPage = 0;
  final _pageController = PageController(initialPage: 0);
  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: _pageOptions,
        controller: _pageController,
        scrollDirection: Axis.horizontal,
        onPageChanged: (value) {
          setState(() {
            _selectedPage = value;
          });
        },
      ),
      // body: _pageOptions[_selectedPage],
      backgroundColor: Default_Theme.themeColor,
      bottomNavigationBar: SafeArea(
        child: Container(
          // height: 55,
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
              GButton(
                icon: FluentIcons.bin_full_20_filled,
                iconSize: 27,
                text: "Home",
              ),
              GButton(
                icon: FluentIcons.home_heart_24_filled,
                iconSize: 27,
                text: "Home",
              ),
              GButton(
                icon: FluentIcons.book_add_24_filled,
                text: "Library",
              ),
              GButton(
                icon: FluentIcons.search_24_filled,
                text: "Search",
              ),
              GButton(
                icon: FluentIcons.arrow_download_24_filled,
                text: "Offline",
              ),
            ],
            selectedIndex: _selectedPage,
            onTabChange: (value) {
              setState(() {
                _selectedPage = value;
                _pageController.jumpToPage(value);
              });
            },
          ),
        ),
      ),
    );
  }
}
