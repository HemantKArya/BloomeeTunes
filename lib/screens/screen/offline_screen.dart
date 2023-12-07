// ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'package:feather_icons/feather_icons.dart';
// import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/screens/screen/offline_views/downloads_status.dart';

import 'package:Bloomee/theme_data/default.dart';
// import 'package:unicons/unicons.dart';
import '../widgets/unicode_icons.dart';

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          customDiscoverBar(context), //AppBar
          SliverList(
              delegate: SliverChildListDelegate([
            Text(
              "data",
              style: TextStyle(fontSize: 600),
            )
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
          Text("Offline",
              style: Default_Theme.primaryTextStyle.merge(const TextStyle(
                  fontSize: 34, color: Default_Theme.primaryColor1))),
          const Spacer(),
          const UnicodeIcon(
            strCode: "\uf002",
            font: Default_Theme.fontAwesomeSolidFont,
            fontSize: 24.0,
            padding: EdgeInsets.only(left: 15),
          ),
          InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => DownloadsView()));
            },
            child: const UnicodeIcon(
              strCode: "\uf019",
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
