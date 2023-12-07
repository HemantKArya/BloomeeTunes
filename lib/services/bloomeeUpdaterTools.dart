import 'dart:convert';

import 'package:http/http.dart' as http;

Future<String> getLatestVersion() async {
  final response = await http.get(Uri.parse(
      'https://api.github.com/repos/HemantKArya/BloomeeTunes/releases/latest'));

  if (response.statusCode == 200) {
    Map<String, dynamic> data = json.decode(response.body);
    return data['tag_name'];
  } else {
    throw Exception('Failed to load latest version');
  }
}
