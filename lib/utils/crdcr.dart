import 'dart:convert';

import 'package:dart_des/dart_des.dart';

String decryptSongUrl(String cipherString) {
  const key = "38346591";
  // ignore: unused_local_variable
  final DES desECB = DES(key: key.codeUnits);
  final encrypted = base64.decode(cipherString);
  final decrypted = desECB.decrypt(encrypted);
  final String decoded = utf8
      .decode(decrypted)
      .replaceAll(RegExp(r'\.mp4.*'), '.mp4')
      .replaceAll(RegExp(r'\.m4a.*'), '.m4a');
  return decoded;
}
