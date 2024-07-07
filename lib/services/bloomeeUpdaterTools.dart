import 'dart:convert';
import 'dart:developer';
import 'dart:io';
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
      "download_url": extractUpUrl(data),
    };
  } else {
    log('Failed to load latest version!', name: 'UpdaterTools');
    return {
      "results": false,
    };
  }
}

String? extractUpUrl(Map<String, dynamic> data) {
  // List<String> urls = [];

  for (var element in (data["assets"] as List)) {
    // urls.add(element["browser_download_url"]);
    if (element["browser_download_url"].toString().contains("windows")) {
      if (Platform.isWindows) {
        return element["browser_download_url"].toString();
      }
    } else if (element["browser_download_url"].toString().contains("android")) {
      if (Platform.isAndroid) {
        return element["browser_download_url"].toString();
      }
    } else {
      continue;
    }
  }
  return null;
}
