import 'dart:developer';
import 'dart:isolate';
import 'package:Bloomee/repository/Youtube/yt_streams.dart';
import 'package:Bloomee/routes_and_consts/global_str_consts.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:async/async.dart';

Future<void> cacheYtStreams({
  required String id,
  required String hURL,
  required String lURL,
}) async {
  final expireAt = RegExp('expire=(.*?)&').firstMatch(lURL)!.group(1) ??
      (DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600 * 5.5).toString();

  try {
    BloomeeDBService.putYtLinkCache(
      id,
      lURL,
      hURL,
      int.parse(expireAt),
    );
    log("Cached: $id, ExpireAt: $expireAt", name: "CacheYtStreams");
  } catch (e) {
    log(e.toString(), name: "CacheYtStreams");
  }
}

Future<void> ytbgIsolate(List<dynamic> opts) async {
  final appDocPath = opts[0] as String;
  final appSupPath = opts[1] as String;
  final SendPort port = opts[2] as SendPort;

  BloomeeDBService(appDocPath: appDocPath, appSuppPath: appSupPath);

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
        int quality = 2;
        await BloomeeDBService.getSettingStr(GlobalStrConsts.ytStrmQuality)
            .then(
          (value) {
            if (value != null) {
              switch (value) {
                case "Low":
                  quality = 1;
                  break;

                case "High":
                  quality = 2;
                  break;
                default:
                  quality = 2;
              }
            }
          },
        );
        YtStreams? refreshedToken = await canOprn.value;

        var time2 = DateTime.now().millisecondsSinceEpoch;
        log("Time taken: ${time2 - time}ms, quality: $quality",
            name: "IsolateBG");
        if (refreshedToken != null && refreshedToken.hmStreamingData[0]) {
          port.send(
            {
              "mediaId": data["mediaId"],
              "id": data["id"],
              "quality": data["quality"],
              "link": refreshedToken.hmStreamingData[quality],
            },
          );
          cacheYtStreams(
            id: data["id"],
            hURL: refreshedToken.hmStreamingData[2],
            lURL: refreshedToken.hmStreamingData[1],
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
