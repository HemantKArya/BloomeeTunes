// Not used right now but can be in future for caching audio files
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:crypto/crypto.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

Future<Directory> _getCacheDir() async =>
    Directory(p.join((await getTemporaryDirectory()).path, 'just_audio_cache'));

Future<LockCachingAudioSource> getLockCachingAudioSource(
  Uri uri, {
  String? fileName,
  Map<String, String>? headers,
  dynamic tag,
}) async {
  log("path: ${(await _getCacheDir()).path}  file: $fileName");
  return LockCachingAudioSource(
    uri,
    headers: headers,
    tag: tag,
    cacheFile: fileName != null
        ? File(p.joinAll([
            (await _getCacheDir()).path,
            'remote',
            sha256.convert(utf8.encode(fileName)).toString() +
                p.extension('.m4a'),
          ]))
        : null,
  );
}
