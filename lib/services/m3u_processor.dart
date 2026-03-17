import 'dart:developer';

/// Converts the given JSON map to an M3U formatted text string.
///
/// Expected structure:
/// - `_meta`: map with generated_by, version, exportedAt, note.
/// - `playlistName`: string.
/// - `mediaItems`: list of maps; each must have title, artist, album, genre,
///   artURL, duration (num, seconds) and at least one of streamingURL /
///   permaURL (used as the URL line — typically a stable track identifier).
///
/// Items whose URL line is empty are silently skipped.
/// Throws a [FormatException] only when top-level required keys are missing.
String convertJsonToM3U(Map<String, dynamic> jsonData) {
  try {
    // Validate and extract metadata.
    final meta = jsonData['_meta'] as Map<String, dynamic>?;
    if (meta == null) {
      throw const FormatException("Missing '_meta' section in JSON.");
    }
    final generatedBy = meta['generated_by']?.toString() ?? "Bloomee";
    final version = meta['version']?.toString() ?? "Unknown";
    final exportedAt = meta['exportedAt']?.toString() ?? "Unknown";
    final note = meta['note']?.toString() ?? "";

    // Extract playlist name.
    final playlistName =
        jsonData['playlistName']?.toString().trim() ?? "Untitled Playlist";

    // Validate and extract media items.
    final mediaItems = jsonData['mediaItems'] as List<dynamic>?;
    if (mediaItems == null) {
      throw const FormatException("Missing 'mediaItems' array in JSON.");
    }

    // Initialize a buffer to build the M3U content.
    final buffer = StringBuffer();

    // Standard M3U header and playlist title.
    buffer.writeln("#EXTM3U");
    buffer.writeln("#PLAYLIST: $playlistName");
    buffer.writeln();

    // Custom Bloomee metadata (ignored by standard M3U players).
    buffer.writeln("#BLOOMEE-GENERATED_BY: $generatedBy");
    buffer.writeln("#BLOOMEE-VERSION: $version");
    buffer.writeln("#BLOOMEE-EXPORTEDAT: $exportedAt");
    buffer.writeln("#BLOOMEE-NOTE: $note");
    buffer.writeln();

    // Process each media item.
    for (final item in mediaItems) {
      if (item is Map<String, dynamic>) {
        final title = item['title']?.toString() ?? "Unknown Title";
        final artist = item['artist']?.toString() ?? "Unknown Artist";
        final album = item['album']?.toString() ?? "Unknown Album";
        final genre = item['genre']?.toString() ?? "Unknown Genre";
        final artURL = item['artURL']?.toString() ?? "";

        // Prefer the stable track identifier (permaURL) over a transient
        // streaming URL.  Fall through to streamingURL when permaURL is absent.
        final permaURL = item['permaURL']?.toString() ?? '';
        final rawStreamingURL = item['streamingURL']?.toString() ?? '';
        final urlLine = permaURL.isNotEmpty ? permaURL : rawStreamingURL;

        // Validate required fields.
        final duration = item['duration'];
        if (duration == null || duration is! num) {
          log("Skipping '$title': missing or invalid 'duration'.",
              name: 'm3u_processor');
          continue;
        }
        if (urlLine.isEmpty) {
          log("Skipping '$title': no URL or identifier available.",
              name: 'm3u_processor');
          continue;
        }

        buffer.writeln("#EXTINF:${duration.toString()}, $artist - $title");
        buffer.writeln("#EXTALB: $album");
        buffer.writeln("#EXTART: $artist");
        buffer.writeln("#EXTGENRE: $genre");
        if (artURL.isNotEmpty) {
          buffer.writeln("#EXTALBUMARTURL: $artURL");
        }
        buffer.writeln(urlLine);
      } else {
        throw FormatException(
            "Invalid media item format: expected a Map<String, dynamic> but found ${item.runtimeType}.");
      }
    }

    return buffer.toString();
  } catch (e, stacktrace) {
    log("Error converting JSON to M3U:", error: e, name: "m3u_processor");
    log("Stacktrace: $stacktrace", name: "m3u_processor");
    rethrow;
  }
}

/// Parses an M3U formatted string and converts it back to a Map<String, dynamic>
/// matching the original JSON structure.  `playlistName` in the returned map
/// may be `null` when the file has no `#PLAYLIST:` tag (standard M3U files).
/// The caller is responsible for prompting the user for a name in that case.
Map<String, dynamic> parseM3UToJson(String m3uContent) {
  try {
    final lines = m3uContent.split('\n').map((e) => e.trim()).toList();

    if (lines.isEmpty || lines.first != '#EXTM3U') {
      throw const FormatException("Invalid M3U file: Missing #EXTM3U header.");
    }

    final meta = <String, dynamic>{};
    final mediaItems = <Map<String, dynamic>>[];
    String? playlistName; // null when the file has no #PLAYLIST: tag

    Map<String, dynamic> currentItem = {};
    num currentDuration = 0;

    for (final line in lines) {
      if (line.isEmpty) continue;

      // Handle custom meta tags
      if (line.startsWith('#BLOOMEE-GENERATED_BY:')) {
        meta['generated_by'] = line.split(':').last.trim();
      } else if (line.startsWith('#BLOOMEE-VERSION:')) {
        meta['version'] = line.split(':').last.trim();
      } else if (line.startsWith('#BLOOMEE-EXPORTEDAT:')) {
        meta['exportedAt'] = line.split(':').last.trim();
      } else if (line.startsWith('#BLOOMEE-NOTE:')) {
        meta['note'] = line.split(':').last.trim();
      } else if (line.startsWith('#PLAYLIST:')) {
        playlistName = line.split(':').last.trim();
      }

      // Handle media item fields
      else if (line.startsWith('#EXTINF:')) {
        final infoPart = line.substring(8);
        final parts = infoPart.split(',');
        if (parts.length != 2) {
          throw FormatException("Invalid #EXTINF line: $line");
        }
        currentDuration = num.tryParse(parts[0].trim()) ?? 0;
        final titleArtistPart = parts[1].trim();

        final artistTitleSplit = titleArtistPart.split(' - ');
        currentItem = {
          'title': artistTitleSplit.length > 1
              ? artistTitleSplit[1]
              : titleArtistPart,
          'artist': artistTitleSplit.length > 1
              ? artistTitleSplit[0]
              : "Unknown Artist",
          'duration': currentDuration,
        };
      } else if (line.startsWith('#EXTALB:')) {
        currentItem['album'] = line.split(':').last.trim();
      } else if (line.startsWith('#EXTART:')) {
        currentItem['artist'] = line.split(':').last.trim();
      } else if (line.startsWith('#EXTGENRE:')) {
        currentItem['genre'] = line.split(':').last.trim();
      } else if (line.startsWith('#EXTALBUMARTURL:')) {
        currentItem['artURL'] = line.split(':').last.trim();
      }

      // Streaming URL Line
      else if (!line.startsWith('#')) {
        currentItem['streamingURL'] = line;
        // Fill defaults if missing
        currentItem.putIfAbsent('album', () => "Unknown");
        currentItem.putIfAbsent('genre', () => "Unknown");
        currentItem.putIfAbsent('artURL', () => null);
        currentItem.putIfAbsent('language', () => "Unknown");
        currentItem.putIfAbsent('mediaID', () => null);
        currentItem.putIfAbsent('source', () => null);
        currentItem.putIfAbsent('isLiked', () => false);
        currentItem.putIfAbsent('permaURL', () => null);
        currentItem.putIfAbsent('id', () => null);

        mediaItems.add(Map<String, dynamic>.from(currentItem));
        currentItem.clear();
      }
    }

    if (playlistName == null) {
      // Not an error — standard M3U files simply omit #PLAYLIST:.
      // Callers should prompt for a name when this is null.
    }

    return {
      '_meta': meta,
      'playlistName': playlistName,
      'mediaItems': mediaItems,
    };
  } catch (e, stacktrace) {
    log("Error parsing M3U to JSON:", error: e, name: "m3u_processor");
    log("Stacktrace: $stacktrace", name: "m3u_processor");
    rethrow;
  }
}
