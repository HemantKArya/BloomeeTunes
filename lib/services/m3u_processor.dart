import 'dart:developer';

/// Converts the given JSON map to an M3U formatted text string.
///
/// The JSON is expected to contain the following structure:
/// - A `_meta` map with keys: generated_by, version, exportedAt, and note.
/// - A `playlistName` key.
/// - A `mediaItems` list, with each item being a map that includes:
///     - title, artist, album, genre, artURL, duration, and streamingURL.
///
/// Throws a [FormatException] if required keys are missing or data is invalid.
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

        String streamingURL = item['streamingURL']?.toString() ?? "";
        // Use perma_url if source is youtube
        if (item["source"] == "youtube") {
          streamingURL = item['permaURL']?.toString() ?? "";
        }

        // Validate required fields.
        final duration = item['duration'];
        if (duration == null || duration is! num) {
          throw FormatException(
              "Missing or invalid 'duration' for track: $title");
        }
        if (streamingURL.isEmpty) {
          throw FormatException("Missing 'streamingURL' for track: $title");
        }

        // Create the EXTINF line with duration and display title.
        buffer.writeln("#EXTINF:${duration.toString()}, $artist - $title");
        // Optional additional tags for extended metadata.
        buffer.writeln("#EXTALB: $album");
        buffer.writeln("#EXTART: $artist");
        buffer.writeln("#EXTGENRE: $genre");
        if (artURL.isNotEmpty) {
          buffer.writeln("#EXTALBUMARTURL: $artURL");
        }
        // Append the streaming URL.
        buffer.writeln(streamingURL);
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
/// matching the original JSON structure.
///
/// Throws a [FormatException] if the M3U format is invalid or missing required data.
Map<String, dynamic> parseM3UToJson(String m3uContent) {
  try {
    final lines = m3uContent.split('\n').map((e) => e.trim()).toList();

    if (lines.isEmpty || lines.first != '#EXTM3U') {
      throw const FormatException("Invalid M3U file: Missing #EXTM3U header.");
    }

    final meta = <String, dynamic>{};
    final mediaItems = <Map<String, dynamic>>[];
    String? playlistName;

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
      throw const FormatException("Missing playlist name (#PLAYLIST:) in M3U.");
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
