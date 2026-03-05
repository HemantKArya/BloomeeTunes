/// Media ID utilities — THE single source of truth for ID format operations.
///
/// Every linkable object from a plugin has a composite ID:
///   `"{pluginId}::{localId}"`
///
/// Stamped in Rust before crossing FFI. Parsed here in Dart.
/// No other file in the codebase should construct or destructure this format.
library media_id;

/// The separator between pluginId and localId in a media ID.
const String kMediaIdSeparator = '::';

/// Result of parsing a composite media ID.
class MediaIdParts {
  /// The plugin that owns this object.
  final String pluginId;

  /// The plugin-local identifier.
  final String localId;

  const MediaIdParts({required this.pluginId, required this.localId});

  @override
  String toString() => '$pluginId$kMediaIdSeparator$localId';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaIdParts &&
          pluginId == other.pluginId &&
          localId == other.localId;

  @override
  int get hashCode => pluginId.hashCode ^ localId.hashCode;
}

/// Try to parse a composite media ID.
///
/// Returns `null` if [id] does not contain the separator `::`.
/// This is the "safe" variant — use [parseMediaId] when you expect a valid ID.
MediaIdParts? tryParseMediaId(String id) {
  final idx = id.indexOf(kMediaIdSeparator);
  if (idx == -1) return null;
  return MediaIdParts(
    pluginId: id.substring(0, idx),
    localId: id.substring(idx + kMediaIdSeparator.length),
  );
}

/// Parse a composite media ID, throwing [FormatException] if invalid.
///
/// Use this when you are certain the ID should be stamped (e.g., from DB
/// where we only store stamped IDs). For user-facing flows where failure
/// is possible, prefer [tryParseMediaId].
MediaIdParts parseMediaId(String id) {
  final parts = tryParseMediaId(id);
  if (parts == null) {
    throw FormatException(
      'Malformed media ID — expected "pluginId${kMediaIdSeparator}localId", '
      'got: "$id"',
    );
  }
  return parts;
}

/// Build a composite media ID from its parts.
///
/// This should only be called by infrastructure code (e.g., Rust bridge
/// stamping). Normal app code should never need to construct IDs manually.
String buildMediaId(String pluginId, String localId) =>
    '$pluginId$kMediaIdSeparator$localId';

/// Extract the plugin ID from a composite media ID.
///
/// Returns `null` if the ID is not properly formatted.
String? pluginIdOf(String id) => tryParseMediaId(id)?.pluginId;

/// Extract the local ID from a composite media ID.
///
/// Returns `null` if the ID is not properly formatted.
String? localIdOf(String id) => tryParseMediaId(id)?.localId;

/// Check whether an ID is a properly stamped composite media ID.
bool isStampedId(String id) => id.contains(kMediaIdSeparator);
