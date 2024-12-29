import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

final Map<String, String> headers = {
  'accept': '*/*',
  'content-type': 'application/json',
  'content-encoding': 'gzip',
  "Referer": "https://wwww.youtube.com/",
  'origin': "https://www.youtube.com/",
};

final ANDROID_CONTEXT = {
  'client': {
    'clientName': 'ANDROID_MUSIC',
    'clientVersion': '5.22.1',
    'androidSdkVersion': 31,
    'userAgent':
        'com.google.android.youtube/19.29.1  (Linux; U; Android 11) gzip',
    'hl': 'en',
    'timeZone': 'UTC',
    'utcOffsetMinutes': 0,
  },
};

final IOS_CONTEXT = {
  'client': {
    'clientName': 'IOS',
    'clientVersion': '19.29.1',
    'deviceMake': 'Apple',
    'deviceModel': 'iPhone16,2',
    'hl': 'en',
    'osName': 'iPhone',
    'osVersion': '17.5.1.21F90',
    'timeZone': 'UTC',
    'userAgent':
        'com.google.ios.youtube/19.29.1 (iPhone16,2; U; CPU iOS 17_5_1 like Mac OS X;)',
    'utcOffsetMinutes': 0
  }
};

const kPartIOS = "AIzaSyB-63vPrdThhKuerbB2N_l7Kwwcxj6yUAc";
const kPartAndroid = "AIzaSyAOghZGza2MQSZkY_zfZ370N-PUdXEo8AI";
const allKeys = [kPartIOS, kPartAndroid];

String getUrl(int option) =>
    "https://www.youtube.com/youtubei/v1/player?key=${allKeys[option]}&prettyPrint=false";

Map<String, dynamic> getBody(int option) => {
      "context": option == 0 ? IOS_CONTEXT : ANDROID_CONTEXT,
    };

enum Codec { mp4a, opus }

class YtStreams {
  final bool playable;
  final List<Audio> audioFormats;
  YtStreams({required this.playable, required this.audioFormats});
  static int retry = 0;

  static Future<YtStreams?> fetch(String videoId, {int option = 0}) async {
    final url = getUrl(option);
    final body = getBody(option);
    body['videoId'] = videoId;

    if (retry == 1) {
      body['contentCheckOk'] = true;
      body['racyCheckOk'] = true;
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        final playable = res["playabilityStatus"]["status"] == "OK";

        //if playable then return the response
        if (playable) {
          retry = 0;
          return YtStreams.fromJson(res);
        }

        //if not playable and not retried yet then retry once
        if (!playable && retry == 0) {
          retry++;
          return fetch(videoId);
        } else {
          retry = 0;
          return YtStreams(playable: false, audioFormats: []);
        }
      } else {
        return null;
      }
    } catch (e) {
      if (kDebugMode || kProfileMode) {
        log(e.toString(), name: 'YtStreams');
      }
      return null;
    }
  }

  factory YtStreams.fromJson(json) {
    final availableAudioFormats =
        (json["streamingData"]["adaptiveFormats"] as List)
            .where((item) => item['mimeType'].contains("audio"));
    return YtStreams(
        playable: true,
        audioFormats:
            availableAudioFormats.map((item) => Audio.fromJson(item)).toList());
  }

  Audio get highestBitrateAudio => sortByBitrate[0];

  Audio get highestQualityAudio => audioFormats.lastWhere(
        (item) => item.itag == 251 || item.itag == 140,
        orElse: () => sortByBitrate.first,
      );

  Audio get highestBitrateMp4aAudio =>
      audioFormats.lastWhere((item) => item.itag == 140 || item.itag == 139,
          orElse: () => highestBitrateOpusAudio);

  Audio get highestBitrateOpusAudio =>
      audioFormats.lastWhere((item) => item.itag == 251 || item.itag == 250,
          orElse: () => highestBitrateMp4aAudio);

  Audio get lowQualityAudio =>
      audioFormats.lastWhere((item) => item.itag == 249 || item.itag == 139,
          orElse: () => audioFormats.last);

  List<Audio> get sortByBitrate {
    final audioFormatsCopy = audioFormats.toList();
    audioFormatsCopy
        .sort((audio1, audio2) => audio1.bitrate.compareTo(audio2.bitrate));
    return audioFormatsCopy;
  }

  List<dynamic> get hmStreamingData {
    if (!playable) return [false, null, null];
    return [
      true,
      lowQualityAudio.url,
      highestQualityAudio.url,
    ];
  }
}

class Audio {
  final int itag;
  final Codec audioCodec;
  final int bitrate;
  final int duration;
  final int size;
  final double loudnessDb;
  final String url;
  Audio(
      {required this.itag,
      required this.audioCodec,
      required this.bitrate,
      required this.duration,
      required this.loudnessDb,
      required this.url,
      required this.size});

  factory Audio.fromJson(json) => Audio(
      audioCodec: (json["mimeType"] as String).contains("mp4a")
          ? Codec.mp4a
          : Codec.opus,
      itag: json['itag'],
      duration: int.tryParse(json["approxDurationMs"]) ?? 0,
      bitrate: json["bitrate"] ?? 0,
      loudnessDb: (json['loudnessDb'])?.toDouble() ?? 0.0,
      url: json['url'],
      size: int.tryParse(json["contentLength"]) ?? 0);

  Map<String, dynamic> toJson() => {
        "itag": itag,
        "audioCodec": audioCodec.toString(),
        "bitrate": bitrate,
        "loudnessDb": loudnessDb,
        "url": url,
        "approxDurationMs": duration,
        "size": size
      };
}
