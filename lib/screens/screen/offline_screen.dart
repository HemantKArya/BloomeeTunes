import 'package:flutter/material.dart';
import 'package:Bloomee/screens/screen/offline_views/downloads_status.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:icons_plus/icons_plus.dart';

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
            const Text(
              "Coming Soon...",
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
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DownloadsView()));
            },
            child: const Icon(
              FontAwesome.download_solid,
              size: 25,
            ),
          ),
        ],
      ),
    );
  }
}
