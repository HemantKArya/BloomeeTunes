import 'dart:developer';
import 'dart:isolate';

import 'package:Bloomee/repository/Youtube/youtube_api.dart';

Future<void> ytbgIsolate(List<dynamic> opts) async {
  final String appDocPath = opts[0] as String;
  final String appSuppPath = opts[1] as String;
  final SendPort port = opts[2] as SendPort;

  final ReceivePort receivePort = ReceivePort();
  port.send(receivePort.sendPort);
  final yt = YouTubeServices(
    appDocPath: appDocPath,
    appSuppPath: appSuppPath,
  );

  receivePort.listen(
    (dynamic data) async {
      /*
      Map<String, dynamic> =>
      {
        "mediaId": "media_id",
        "id": "video_id",
        "quality": "high"
      }*/
      if (data is Map) {
        var time = DateTime.now().millisecondsSinceEpoch;
        Map? test = await yt.refreshLink(data["id"], quality: 'Low');

        var time2 = DateTime.now().millisecondsSinceEpoch;
        log("Time taken: ${time2 - time}ms", name: "IsolateBG");
        if (test != null) {
          port.send(
            {
              "mediaId": data["mediaId"],
              "id": data["id"],
              "quality": data["quality"],
              "link": test["url"],
            },
          );
        } else {
          port.send(
            {
              "mediaId": data["mediaId"],
              "id": data["id"],
              "quality": data["quality"],
              "link": null,
            },
          );
        }
      }
    },
  );
}
