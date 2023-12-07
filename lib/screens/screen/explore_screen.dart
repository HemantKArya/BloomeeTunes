import 'package:flutter/material.dart';
import 'package:Bloomee/screens/screen/home_views/notification_view.dart';
import 'package:Bloomee/screens/screen/home_views/setting_view.dart';
import 'package:Bloomee/screens/screen/home_views/timer_view.dart';
import 'package:Bloomee/theme_data/default.dart';
import '../widgets/carousal_widget.dart';
import '../widgets/tabList_widget.dart';
import '../widgets/unicode_icons.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          customDiscoverBar(context), //AppBar
          SliverList(
              delegate: SliverChildListDelegate([
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: CaraouselWidget(),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: TabSongListWidget(),
            ),
          ]))
        ],
      ),
      backgroundColor: Default_Theme.themeColor,
    );
  }

  SliverAppBar customDiscoverBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      surfaceTintColor: Default_Theme.themeColor,
      backgroundColor: Default_Theme.themeColor,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Discover",
              style: Default_Theme.primaryTextStyle.merge(const TextStyle(
                  fontSize: 34, color: Default_Theme.primaryColor1))),
          const Spacer(),
          InkWell(
            splashColor: Colors.transparent,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NotificationView()));
            },
            child: const UnicodeIcon(
              strCode: "\uf0f3",
              font: Default_Theme.fontAwesomeRegularFont,
              fontSize: 25.0,
              padding: EdgeInsets.only(left: 15),
            ),
          ),
          InkWell(
            splashColor: Colors.transparent,
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const TimerView()));
            },
            child: const UnicodeIcon(
              strCode: "\uf1da",
              font: Default_Theme.fontAwesomeSolidFont,
              fontSize: 24.0,
              padding: EdgeInsets.only(left: 15),
            ),
          ),
          InkWell(
            splashColor: Colors.transparent,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsView()));
            },
            child: const UnicodeIcon(
              strCode: "\uf013",
              font: Default_Theme.fontAwesomeSolidFont,
              fontSize: 25.0,
              padding: EdgeInsets.only(left: 15, right: 5),
            ),
          ),
        ],
      ),
    );
  }
}
