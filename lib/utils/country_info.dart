import 'dart:convert';
import 'dart:developer' as dev;
import 'package:Bloomee/routes_and_consts/global_str_consts.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:http/http.dart';

Future<String> getCountry() async {
  String countryCode = "US";
  await BloomeeDBService.getSettingBool(GlobalStrConsts.autoGetCountry)
      .then((value) async {
    if (value != null && value == true) {
      try {
        final response = await get(Uri.parse('http://ip-api.com/json'));
        if (response.statusCode == 200) {
          Map data = jsonDecode(utf8.decode(response.bodyBytes));
          countryCode = data['countryCode'] ?? "US";
          await BloomeeDBService.putSettingStr(
              GlobalStrConsts.countryCode, countryCode);
        }
      } catch (err) {
        await BloomeeDBService.getSettingStr(GlobalStrConsts.countryCode)
            .then((value) {
          if (value != null) {
            countryCode = value;
          } else {
            countryCode = "US";
          }
        });
      }
    } else {
      await BloomeeDBService.getSettingStr(GlobalStrConsts.countryCode)
          .then((value) {
        if (value != null) {
          countryCode = value;
        } else {
          countryCode = "US";
        }
      });
    }
  });
  dev.log("Country Code: $countryCode");
  return countryCode;
}

Future<String> getLanguage() async {
  String languageCode = "en";
  await BloomeeDBService.getSettingStr(GlobalStrConsts.languageCode)
      .then((value) {
    if (value != null) {
      languageCode = value;
    }
  });
  dev.log("Language Code: $languageCode");
  return languageCode;
}
