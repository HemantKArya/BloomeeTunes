import 'dart:convert';
import 'dart:developer';
import 'package:Bloomee/core/constants/setting_keys.dart';
import 'package:Bloomee/services/db/db_provider.dart';
import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:http/http.dart';

Future<String> getCountry() async {
  String countryCode = "IN";
  final settingsDao = SettingsDAO(DBProvider.db);
  await settingsDao
      .getSettingBool(SettingKeys.autoGetCountry)
      .then((value) async {
    if (value != null && value == true) {
      try {
        final response = await get(Uri.parse('http://ip-api.com/json'));
        if (response.statusCode == 200) {
          Map data = jsonDecode(utf8.decode(response.bodyBytes));
          countryCode = data['countryCode'];
          await settingsDao.putSettingStr(SettingKeys.countryCode, countryCode);
        }
      } catch (err) {
        await settingsDao.getSettingStr(SettingKeys.countryCode).then((value) {
          if (value != null) {
            countryCode = value;
          } else {
            countryCode = "IN";
          }
        });
      }
    } else {
      await settingsDao.getSettingStr(SettingKeys.countryCode).then((value) {
        if (value != null) {
          countryCode = value;
        } else {
          countryCode = "IN";
        }
      });
    }
  });
  log("Country Code: $countryCode");
  return countryCode;
}
