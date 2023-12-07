import 'package:url_launcher/url_launcher.dart';

Future<void> launch_Url(_url) async {
  if (!await launchUrl(_url)) {
    print('Could not launch $_url');
  }
}
