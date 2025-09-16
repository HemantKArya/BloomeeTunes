import 'dart:developer';

import 'package:url_launcher/url_launcher.dart';

Future<void> launch_Url(url) async {
  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    log('Could not launch $url', name: "launch_Url");
  }
}
