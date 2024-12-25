import 'dart:developer';
import 'dart:isolate';
import 'package:Bloomee/repository/Youtube/yt_streams.dart';
import 'package:async/async.dart';

Future<void> ytbgIsolate(List<dynamic> opts) async {
  final SendPort port = opts[2] as SendPort;

  CancelableOperation<YtStreams?> canOprn =
      CancelableOperation.fromFuture(Future.value(null));

  final ReceivePort receivePort = ReceivePort();
  port.send(receivePort.sendPort);

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
          YtStreams.fetch(data['id']),
          onCancel: () {
            log("Operation Cancelled-${data['id']}", name: "IsolateBG");
          },
        );

        YtStreams? refreshedToken = await canOprn.value;

        var time2 = DateTime.now().millisecondsSinceEpoch;
        log("Time taken: ${time2 - time}ms", name: "IsolateBG");
        if (refreshedToken != null) {
          port.send(
            {
              "mediaId": data["mediaId"],
              "id": data["id"],
              "quality": data["quality"],
              "link": refreshedToken.highestBitrateOpusAudio.url,
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
