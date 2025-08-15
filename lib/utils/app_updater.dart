import 'dart:developer';
import 'package:Bloomee/screens/widgets/gradient_alert_widget.dart';
import 'package:Bloomee/services/bloomeeUpdaterTools.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> updateDialog(BuildContext context) async {
  // if (Platform.isAndroid) {
  Map<String, dynamic> updateData = await getLatestVersion();
  log("Update data fetched: $updateData");
  if (updateData["results"]) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GradientDialog(
          "Update Available",
          content:
              "New Version of Bloomee🌸 is now available!!\n\nVersion: ${updateData["newVer"]} + ${updateData["newBuild"]}",
          presetIndex: 0,
          actions: [
            GradientDialogAction('Later', onPressed: () {}, isText: true),
            GradientDialogAction('Update Now', onPressed: () {
              openURL("https://bloomee.sourceforge.io/");
            }),
          ],
        );
      },
    );
  }
  // }
}

Future<void> openURL(String url) async {
  launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}
