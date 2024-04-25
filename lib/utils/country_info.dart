import 'dart:convert';

import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:http/http.dart';

Future<String> getCountry() async {
  String countryCode = "IN";
  try {
    final response = await get(Uri.parse('http://ip-api.com/json'));
    if (response.statusCode == 200) {
      Map data = jsonDecode(utf8.decode(response.bodyBytes));
      countryCode = data['countryCode'];
      await BloomeeDBService.putSettingStr('locationCode', countryCode);
    }
  } catch (err) {
    BloomeeDBService.getSettingStr('locationCode').then((value) {
      if (value != null) {
        countryCode = value;
      } else {
        countryCode = "IN";
      }
    });
  }
  return countryCode;
}
