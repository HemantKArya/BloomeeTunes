import 'dart:developer';
import 'dart:io';
import 'package:Bloomee/model/saavnModel.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/repository/Youtube/youtube_api.dart';
import 'package:Bloomee/routes_and_consts/global_str_consts.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;

Future<Uint8List?> getSquareImg(Uint8List image) async {
  // Load the original image
  img.Image? originalImage = img.decodeImage(image);

  if (originalImage != null) {
    int maxDimension = originalImage.width > originalImage.height
        ? originalImage.width
        : originalImage.height;

    return img
        .copyResize(
            (img.copyExpandCanvas(originalImage,
                newHeight: maxDimension,
                newWidth: maxDimension,
                position: img.ExpandCanvasPosition.center)),
            width: maxDimension,
            height: maxDimension)
        .toUint8List();
  }
  return null;
}

class BloomeeDownloader {
  static Future<Uint8List> getImgBytes(String url) async {
    final client = HttpClient();
    final HttpClientRequest request = await client.getUrl(Uri.parse(url));
    final HttpClientResponse response = await request.close();
    final bytes = await consolidateHttpClientResponseBytes(response);
    return bytes;
  }

  static Future<String?> downloadFile(String url, String fileName) async {
    // download image to app cache directory
    final tempDir = (await getExternalStorageDirectory())!.path;

    final File file = File('$tempDir/$fileName');
    final bool fileExists = file.existsSync();
    if (!fileExists) {
      final client = HttpClient();
      final HttpClientRequest request = await client.getUrl(Uri.parse(url));
      final HttpClientResponse response = await request.close();
      final bytes = await consolidateHttpClientResponseBytes(response);
      await file.writeAsBytes(bytes);
      if (file.existsSync()) {
        log('Downloaded $fileName');
        return "$tempDir/$fileName";
      }
    } else {
      log('File already exists: $fileName');
      try {
        await deleteFile('$tempDir/$fileName');
        return downloadFile(url, fileName);
      } catch (e) {
        log('Failed to get valid file for $fileName');
      }
    }
    return null;
  }

  static Future<bool> alreadyDownloaded(MediaItemModel song) async {
    final tempDB = await BloomeeDBService.getDownloadDB(song);
    if (tempDB != null) {
      final File file = File("${tempDB.filePath}/${tempDB.fileName}");
      final isExist = file.existsSync();
      if (isExist) {
        return true;
      } else {
        await BloomeeDBService.removeDownloadDB(song);
      }
    }

    return false;
  }

  static Future<String?> downloadSong(MediaItemModel song,
      {required String fileName, required String filePath}) async {
    print("🔽 DEBUG: BloomeeDownloader.downloadSong() started");
    print("🔽 DEBUG: fileName: $fileName, filePath: $filePath");

    final String? taskId;
    print("🔽 DEBUG: Checking if song already downloaded...");

    if (!(await alreadyDownloaded(song))) {
      print("🔽 DEBUG: Song not downloaded yet, proceeding with download");
      try {
        String? kURL;
        print("🔽 DEBUG: Song source: ${song.extras!['source']}");
        print("🔽 DEBUG: Song perma_url: ${song.extras!['perma_url']}");

        if (song.extras!['source'] == 'youtube' ||
            (song.extras!['perma_url'].toString()).contains('youtube')) {
          print("🔽 DEBUG: YouTube source detected, getting latest YT link...");
          final videoId = song.id.replaceAll("youtube", "");
          print("🔽 DEBUG: Video ID: $videoId");
          kURL = await latestYtLink(videoId);
          print("🔽 DEBUG: YouTube URL obtained: $kURL");
        } else {
          print("🔽 DEBUG: Non-YouTube source, using direct URL");
          kURL = song.extras!['url'];
          print("🔽 DEBUG: Original URL: $kURL");
          kURL = await getJsQualityURL(kURL!, isStreaming: false);
          print("🔽 DEBUG: Quality URL: $kURL");
        }

        if (kURL == null) {
          print("🔽 DEBUG: ERROR - kURL is null, cannot proceed with download");
          return null;
        }

        print("🔽 DEBUG: Starting FlutterDownloader.enqueue...");
        print("🔽 DEBUG: Final URL: $kURL");
        print("🔽 DEBUG: Save directory: $filePath");
        print("🔽 DEBUG: File name: $fileName");

        taskId = await FlutterDownloader.enqueue(
          url: kURL,
          savedDir: filePath,
          fileName: fileName,
          showNotification: true,
          openFileFromNotification: false,
        );

        print("🔽 DEBUG: FlutterDownloader.enqueue completed");
        print("🔽 DEBUG: Task ID received: $taskId");

        return taskId;
      } catch (e) {
        print("🔽 DEBUG: Exception in downloadSong: $e");
        log("Failed to add ${song.title} to download queue",
            error: e, name: "BloomeeDownloader");
      }
    } else {
      print("🔽 DEBUG: Song already downloaded, skipping");
      log("${song.title} is already downloaded. Skipping download");
      SnackbarService.showMessage("${song.title} is already downloaded");
    }
    print("🔽 DEBUG: Returning null from downloadSong");
    return null;
  }

  static Future<void> songTagger(MediaItemModel song, String filePath) async {
    final hasStorageAccess =
        Platform.isAndroid ? await Permission.storage.isGranted : true;
    if (!hasStorageAccess) {
      await Permission.storage.request();
      if (!await Permission.storage.isGranted) {
        return;
      }
    }
    log("Tagging ${song.title} by ${song.artist}", name: "BloomeeDownloader");
    // final imgPath =
    //     await downloadFile(song.artUri.toString(), "${song.id}.jpg");
    // log("Image downloaded for ${imgPath}", name: "BloomeeDownloader");
    try {
      await MetadataGod.writeMetadata(
          file: filePath,
          metadata: Metadata(
            title: song.title,
            artist: song.artist,
            album: song.album,
            genre: song.genre,
            picture: Picture(
              data: (await getSquareImg(
                  await getImgBytes(song.artUri.toString())))!,
              mimeType: 'image/jpeg',
            ),
          ));
    } catch (e) {
      log("Failed to tag with image ${song.title} by ${song.artist}",
          error: e, name: "BloomeeDownloader");
      await MetadataGod.writeMetadata(
          file: filePath,
          metadata: Metadata(
            title: song.title,
            artist: song.artist,
            album: song.album,
            genre: song.genre,
          ));
    }
    // deleteFile(imgPath!);
  }

  static Future<void> deleteFile(String fileName) async {
    final String filePath = fileName;
    final File file = File(filePath);
    await file.delete();
  }

  static Future<String?> latestYtLink(String id) async {
    print("🔽 DEBUG: latestYtLink() called for ID: $id");
    final vidInfo = await BloomeeDBService.getYtLinkCache(id);

    if (vidInfo != null) {
      print("🔽 DEBUG: Cache found for video ID: $id");
      if ((DateTime.now().millisecondsSinceEpoch ~/ 1000) + 350 >
          vidInfo.expireAt) {
        print("🔽 DEBUG: Cache expired, refreshing link...");
        log("Link expired for vidId: $id", name: "BloomeeDownloader");
        return await refreshYtLink(id);
      } else {
        print("🔽 DEBUG: Cache valid, using cached link");
        log("Link found in cache for vidId: $id", name: "BloomeeDownloader");
        String kurl = vidInfo.lowQURL!;
        await BloomeeDBService.getSettingStr(GlobalStrConsts.ytDownQuality)
            .then((value) {
          if (value != null) {
            if (value == "High") {
              kurl = vidInfo.highQURL;
              print("🔽 DEBUG: Using high quality URL");
            } else {
              kurl = vidInfo.lowQURL!;
              print("🔽 DEBUG: Using low quality URL");
            }
          }
        });
        print("🔽 DEBUG: Returning cached URL: $kurl");
        return kurl;
      }
    } else {
      print("🔽 DEBUG: No cache found, refreshing link...");
      log("No cache found for vidId: $id", name: "BloomeeDownloader");
      return await refreshYtLink(id);
    }
  }

  static Future<String?> refreshYtLink(String id) async {
    print("🔽 DEBUG: refreshYtLink() called for ID: $id");
    String quality = "Low";
    await BloomeeDBService.getSettingStr(GlobalStrConsts.ytDownQuality)
        .then((value) {
      if (value != null) {
        if (value == "High") {
          quality = "High";
        } else {
          quality = "Low";
        }
      }
    });
    print("🔽 DEBUG: Download quality setting: $quality");

    print("🔽 DEBUG: Calling YouTubeServices().refreshLink()...");
    final vidMap = await YouTubeServices().refreshLink(id, quality: quality);

    if (vidMap != null) {
      print("🔽 DEBUG: YouTube link refresh successful");
      print("🔽 DEBUG: vidMap contents: $vidMap");

      final qurls = vidMap["qurls"];
      if (qurls != null && qurls is List && qurls.length >= 3) {
        final isSuccess = qurls[0] as bool;
        if (isSuccess) {
          final url =
              quality == "High" ? qurls[2] as String : qurls[1] as String;
          print("🔽 DEBUG: Refreshed URL ($quality quality): $url");
          return url;
        } else {
          print("🔽 DEBUG: ERROR - YouTube link extraction failed");
          return null;
        }
      } else {
        print("🔽 DEBUG: ERROR - Invalid qurls format: $qurls");
        return null;
      }
    } else {
      print("🔽 DEBUG: YouTube link refresh failed - vidMap is null");
      return null;
    }
  }

  static Future<String> getValidFileName(
      String fileName, String filePath) async {
    final File file = File('$filePath/$fileName');
    final bool fileExists = file.existsSync();
    if (!fileExists) {
      return fileName;
    } else {
      log('File already exists: $fileName', name: "BloomeeDownloader");
      try {
        fileName = fileName
            .replaceAll(".mp4", "(1).mp4")
            .replaceAll(".m4a", "(1).m4a");
        return getValidFileName(fileName, filePath);
      } catch (e) {
        log('Failed to get valid file for $fileName');
      }
    }
    return fileName;
  }
}
