import 'dart:developer';

import 'package:url_launcher/url_launcher.dart';

Future<void> launch_Url(_url) async {
  if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
    log('Could not launch $_url', name: "launch_Url");
  }
}
