import 'package:Bloomee/routes_and_consts/global_str_consts.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';

Future<Map<String, String>> initializeHeaders({String language = 'en'}) async {
  Map<String, String> h = {
    "User-Agent":
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/105.0.0.0 Safari/537.36 Edg/105.0.1343.42",
    'accept': '*/*',
    'accept-encoding': 'gzip, deflate',
    'content-type': 'application/json',
    'content-encoding': 'gzip',
    "Origin": "https://music.youtube.com",
    'cookie': 'CONSENT=YES+1',
    'Accept-Language': language,
  };
  // String? visitorId = Hive.box('SETTINGS').get('VISITOR_ID');
  String? visitorId = await BloomeeDBService.getAPICache("VISITOR_ID");
  if (visitorId != null) {
    h['X-Goog-Visitor-Id'] = visitorId;
  }
  return h;
}

Future<Map<String, dynamic>> initializeContext() async {
  final DateTime now = DateTime.now();
  final String year = now.year.toString();
  final String month = now.month.toString().padLeft(2, '0');
  final String day = now.day.toString().padLeft(2, '0');
  final String date = year + month + day;
  return {
    'context': {
      'client': {
        "hl": "en-IN",
        "gl": await BloomeeDBService.getSettingStr(GlobalStrConsts.countryCode,
            defaultValue: "IN"),
        'clientName': 'WEB_REMIX',
        'clientVersion': '1.$date.01.00',
      },
      'user': {}
    }
  };
}

dynamic nav(dynamic root, List<dynamic> items, {bool noneIfAbsent = false}) {
  try {
    for (var k in items) {
      root = root?[k];
    }
    return root;
  } catch (err) {
    if (noneIfAbsent) {
      return null;
    } else {
      rethrow;
    }
  }
}

String getContinuationString(dynamic ctoken) {
  return "&ctoken=$ctoken&continuation=$ctoken";
}
