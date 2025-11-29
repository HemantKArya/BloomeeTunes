import 'dart:developer';

import 'package:Bloomee/screens/screen/home_views/setting_views/check_update_view.dart';
import 'package:Bloomee/services/db/GlobalDB.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class NotificationTile extends StatelessWidget {
  final NotificationDB notification;
  const NotificationTile({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: ListTile(
        // splashColor: Default_Theme.accentColor2.withValues(alpha: 0.1),
        onTap: () {
          if (notification.type == "app_update") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CheckUpdateView(),
              ),
            );
          } else {
            log("Notification type not found: ${notification.type}");
          }
        },
        tileColor: Default_Theme.primaryColor1.withValues(alpha: 0.07),
        leading: const Icon(
          MingCute.medal_fill,
          color: Default_Theme.primaryColor1,
          size: 40,
        ),
        title: Text(
          notification.title,
          style: const TextStyle(
                  color: Default_Theme.accentColor2,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)
              .merge(Default_Theme.secondoryTextStyle),
        ),
        subtitle: Text(
          notification.body,
          style: const TextStyle(
                  color: Default_Theme.primaryColor2,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)
              .merge(Default_Theme.secondoryTextStyle),
        ),
      ),
    );
  }
}
