import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

bool isUpdateAvailable(
    String currentVer, String currentBuild, String newVer, String newBuild,
    {bool checkBuild = true}) {
  List<int> currentVersionParts = currentVer.split('.').map(int.parse).toList();
  List<int> newVersionParts = newVer.split('.').map(int.parse).toList();

  for (int i = 0; i < currentVersionParts.length; i++) {
    if (newVersionParts[i] > currentVersionParts[i]) {
      return true;
    } else if (newVersionParts[i] < currentVersionParts[i]) {
      return false;
    }
  }

  if (checkBuild) {
    int currentBuildNumber = int.parse(currentBuild);
    int newBuildNumber = int.parse(newBuild);

    if (newBuildNumber > currentBuildNumber) {
      return true;
    } else if (newBuildNumber < currentBuildNumber) {
      return false;
    }
  }

  return false;
}

Future<Map<String, dynamic>> sourceforgeUpdate() async {
  String platform = Platform.operatingSystem;
  if (platform == 'linux') {
    platform = 'linux';
  } else if (platform == 'android') {
    platform = 'android';
  } else {
    platform = 'win';
  }
  const url = 'https://sourceforge.net/projects/bloomee/best_release.json';
  final userAgent = {
    'win':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36',
    'linux':
        'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3868.146 Safari/537.36 OPR/54.0.4087.46',
    'android':
        'Mozilla/5.0 (Linux; Android 13;) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Mobile Safari/537.36',
  };

  final headers = {
    'user-agent': userAgent[platform]!,
  };
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  final response = await http.get(Uri.parse(url), headers: headers);
  log("response status code: ${response.statusCode}", name: 'UpdaterTools');
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final releaseUrl = data['release']['url'];
    final filename = data['release']['filename'];
    final fileNameParts = filename.split('/');
    final versionMatch =
        RegExp(r'v(\d+\.\d+\.\d+)').firstMatch(fileNameParts.last);
    final buildMatch = RegExp(r'\+(\d+)').firstMatch(fileNameParts.last);
    final version = versionMatch?.group(1);
    final build = buildMatch?.group(1);

    return {
      'newVer': version ?? '',
      'newBuild': build ?? '',
      'download_url': releaseUrl,
      'currVer': packageInfo.version,
      'currBuild': packageInfo.buildNumber,
      'results': isUpdateAvailable(
        packageInfo.version,
        packageInfo.buildNumber,
        version ?? '0.0.0',
        build ?? '0',
        checkBuild: platform == 'linux' ? false : true,
      ),
    };
  } else {
    throw Exception('Failed to load latest version!');
    // return {
    //   'results': false,
    //   'currVer': packageInfo.version,
    //   'currBuild': packageInfo.buildNumber,
    // };
  }
}

Future<Map<String, dynamic>> githubUpdate() async {
  http.Response response;
  try {
    response = await http.get(
      Uri.parse(
          'https://api.github.com/repos/HemantKArya/BloomeeTunes/releases/latest'),
    );
  } catch (e) {
    log('Failed to load latest version!', name: 'UpdaterTools');
    return {
      "results": false,
    };
  }

  if (response.statusCode == 200) {
    Map<String, dynamic> data = json.decode(response.body);
    String newBuildVer = (data['tag_name'] as String).split("+")[1];
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return {
      "results": isUpdateAvailable(
        packageInfo.version,
        packageInfo.buildNumber,
        data["tag_name"].toString().split("+")[0].replaceFirst("v", ''),
        newBuildVer,
        checkBuild: false,
      ),
      "newBuild": newBuildVer,
      "currBuild": packageInfo.buildNumber,
      "currVer": packageInfo.version,
      "newVer": data["tag_name"].toString().split("+")[0].replaceFirst("v", ''),
      // "download_url": extractUpUrl(data),
      "download_url":
          "https://sourceforge.net/projects/bloomee/files/latest/download",
    };
  } else {
    log('Failed to load latest version!', name: 'UpdaterTools');
    return {
      "results": false,
    };
  }
}

Future<Map<String, dynamic>> getLatestVersion() async {
  try {
    return await sourceforgeUpdate();
  } catch (e) {
    return await githubUpdate();
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
