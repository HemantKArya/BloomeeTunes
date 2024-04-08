import 'dart:developer';
import 'dart:io';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/repository/Youtube/youtube_api.dart';
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
      final File file =
          File("${tempDB.filePath}/${song.title} by ${song.artist}.m4a");
      final isExist = file.existsSync();
      if (isExist) {
        return true;
      } else {
        await BloomeeDBService.removeDownloadDB(song);
      }
    }

    return false;
  }

  static Future<String?> downloadSong(MediaItemModel song) async {
    final String? taskId;
    if (!(await alreadyDownloaded(song))) {
      try {
        String? kURL;
        if (song.extras!['source'] == 'youtube' ||
            (song.extras!['perma_url'].toString()).contains('youtube')) {
          kURL = await latestYtLink(song.id.replaceAll("youtube", ""));

          taskId = await FlutterDownloader.enqueue(
            url: kURL!,
            savedDir: (await getExternalStorageDirectory())!.path,
            fileName: "${song.title} by ${song.artist}.m4a",
            showNotification: true,
            openFileFromNotification: false,
          );
        } else {
          kURL = song.extras!['url'];

          taskId = await FlutterDownloader.enqueue(
            url: kURL!,
            savedDir: (await getExternalStorageDirectory())!.path,
            fileName: "${song.title} by ${song.artist}.mp4",
            showNotification: true,
            openFileFromNotification: false,
          );
        }

        return taskId;
      } catch (e) {
        log("Failed to add ${song.title} to download queue",
            error: e, name: "BloomeeDownloader");
      }
    } else {
      log("${song.title} is already downloaded. Skipping download");
      SnackbarService.showMessage("${song.title} is already downloaded");
    }
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
    final vidInfo = await BloomeeDBService.getYtLinkCache(id);
    if (vidInfo != null) {
      if ((DateTime.now().millisecondsSinceEpoch ~/ 1000) + 350 >
          vidInfo.expireAt) {
        log("Link expired for vidId: $id", name: "BloomeeDownloader");
        return await refreshYtLink(id);
      } else {
        log("Link found in cache for vidId: $id", name: "BloomeeDownloader");
        return vidInfo.lowQURL;
      }
    } else {
      log("No cache found for vidId: $id", name: "BloomeeDownloader");
      return await refreshYtLink(id);
    }
  }

  static Future<String?> refreshYtLink(String id) async {
    final vidMap = await YouTubeServices().refreshLink(id);
    if (vidMap != null) {
      return vidMap["url"] as String;
    } else {
      return null;
    }
  }
}
