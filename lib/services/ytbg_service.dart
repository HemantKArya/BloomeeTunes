import 'dart:developer';
import 'dart:isolate';
import 'package:async/async.dart';
import 'package:Bloomee/repository/Youtube/youtube_api.dart';

Future<void> ytbgIsolate(List<dynamic> opts) async {
  final String appDocPath = opts[0] as String;
  final String appSuppPath = opts[1] as String;
  final SendPort port = opts[2] as SendPort;

  CancelableOperation<Map?> canOprn =
      CancelableOperation.fromFuture(Future.value(null));

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
        // Map? refreshedToken = await yt.refreshLink(data["id"], quality: 'Low');
        await canOprn.cancel();
        canOprn = CancelableOperation.fromFuture(
          yt.refreshLink(data["id"], quality: data["quality"]),
          onCancel: () {
            log("Operation Cancelled-${data['id']}", name: "IsolateBG");
          },
        );

        Map? refreshedToken = await canOprn.value;

        var time2 = DateTime.now().millisecondsSinceEpoch;
        log("Time taken: ${time2 - time}ms", name: "IsolateBG");
        if (refreshedToken != null) {
          port.send(
            {
              "mediaId": data["mediaId"],
              "id": data["id"],
              "quality": data["quality"],
              "link": refreshedToken["url"],
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
