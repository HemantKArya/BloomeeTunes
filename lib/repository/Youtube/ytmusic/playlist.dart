String playlistIdTrimmer(String playlistId) {
  if (playlistId.startsWith('VL')) {
    return playlistId.substring(2);
  } else {
    return playlistId;
  }
}

String playlistIdExtender(String playlistId) {
  if (playlistId.startsWith('VL')) {
    return playlistId;
  } else {
    return 'VL$playlistId';
  }
}
