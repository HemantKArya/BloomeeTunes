import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

Future<Map<String, dynamic>> getLatestVersion() async {
  final response = await http.get(
    Uri.parse(
        'https://api.github.com/repos/HemantKArya/BloomeeTunes/releases/latest'),
  );

  if (response.statusCode == 200) {
    Map<String, dynamic> data = json.decode(response.body);
    String newBuildVer = (data['tag_name'] as String).split("+")[1];
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return {
      "results": true,
      "newBuild": newBuildVer,
      "currBuild": packageInfo.buildNumber,
      "currVer": packageInfo.version,
      "newVer": data["tag_name"].toString().split("+")[0].replaceFirst("v", ''),
      "download_url": data["assets"][0]["browser_download_url"],
    };
  } else {
    print('Failed to load latest version! - updater tools');
    return {
      "results": false,
    };
  }
}
