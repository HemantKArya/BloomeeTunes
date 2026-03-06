import 'package:Bloomee/core/events/global_event_bus.dart';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/plugins/blocs/plugin/plugin_bloc.dart';
import 'package:Bloomee/plugins/utils/media_id.dart';
import 'package:Bloomee/screens/screen/common_views/album_view.dart';
import 'package:Bloomee/screens/screen/common_views/artist_view.dart';
import 'package:Bloomee/screens/screen/common_views/playlist_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TrackMetadataLinks extends StatelessWidget {
  final Track track;
  final TextStyle? style;
  final int maxLines;
  final TextOverflow overflow;
  final TextAlign textAlign;
  final bool showAlbum;
  final String emptyText;

  const TrackMetadataLinks({
    super.key,
    required this.track,
    this.style,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.textAlign = TextAlign.start,
    this.showAlbum = false,
    this.emptyText = 'Unknown',
  });

  @override
  Widget build(BuildContext context) {
    final segments = <_MetadataSegment>[];
    segments.addAll(_artistSegments(context, track.artists));

    final album = track.album;
    if (showAlbum && album != null && album.title.trim().isNotEmpty) {
      if (segments.isNotEmpty) {
        segments.add(const _MetadataSegment(text: ' • '));
      }
      segments.add(_summarySegment(
        context,
        id: album.id,
        label: album.title,
        onTap: (pluginId) => _openAlbum(context, album, pluginId),
      ));
    }

    if (segments.isEmpty) {
      segments.add(_MetadataSegment(text: emptyText));
    }

    return _InlineMetadataText(
      segments: segments,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}

class ArtistListLinks extends StatelessWidget {
  final List<ArtistSummary> artists;
  final TextStyle? style;
  final int maxLines;
  final TextOverflow overflow;
  final TextAlign textAlign;
  final String emptyText;

  const ArtistListLinks({
    super.key,
    required this.artists,
    this.style,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.textAlign = TextAlign.start,
    this.emptyText = 'Unknown',
  });

  @override
  Widget build(BuildContext context) {
    final segments = _artistSegments(context, artists);
    if (segments.isEmpty) {
      segments.add(_MetadataSegment(text: emptyText));
    }
    return _InlineMetadataText(
      segments: segments,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}

class AlbumLinkText extends StatelessWidget {
  final AlbumSummary album;
  final TextStyle? style;
  final int maxLines;
  final TextOverflow overflow;
  final TextAlign textAlign;

  const AlbumLinkText({
    super.key,
    required this.album,
    this.style,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return _InlineMetadataText(
      segments: [
        _summarySegment(
          context,
          id: album.id,
          label: album.title,
          onTap: (pluginId) => _openAlbum(context, album, pluginId),
        ),
      ],
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}

class PlaylistLinkText extends StatelessWidget {
  final PlaylistSummary playlist;
  final TextStyle? style;
  final int maxLines;
  final TextOverflow overflow;
  final TextAlign textAlign;

  const PlaylistLinkText({
    super.key,
    required this.playlist,
    this.style,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return _InlineMetadataText(
      segments: [
        _summarySegment(
          context,
          id: playlist.id,
          label: playlist.title,
          onTap: (pluginId) => _openPlaylist(context, playlist, pluginId),
        ),
      ],
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}

class _InlineMetadataText extends StatefulWidget {
  final List<_MetadataSegment> segments;
  final TextStyle? style;
  final int maxLines;
  final TextOverflow overflow;
  final TextAlign textAlign;

  const _InlineMetadataText({
    required this.segments,
    this.style,
    required this.maxLines,
    required this.overflow,
    required this.textAlign,
  });

  @override
  State<_InlineMetadataText> createState() => _InlineMetadataTextState();
}

class _InlineMetadataTextState extends State<_InlineMetadataText> {
  final Set<int> _hoveredIndexes = <int>{};
  List<TapGestureRecognizer?> _recognizers = const [];

  @override
  void initState() {
    super.initState();
    _syncRecognizers();
  }

  @override
  void didUpdateWidget(covariant _InlineMetadataText oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncRecognizers();
  }

  @override
  void dispose() {
    for (final recognizer in _recognizers) {
      recognizer?.dispose();
    }
    super.dispose();
  }

  void _syncRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer?.dispose();
    }

    _recognizers = widget.segments
        .map(
          (segment) => segment.onTap == null
              ? null
              : (TapGestureRecognizer()..onTap = segment.onTap),
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = DefaultTextStyle.of(context).style.merge(widget.style);

    return Text.rich(
      TextSpan(
        children: [
          for (var index = 0; index < widget.segments.length; index++)
            _buildSpan(index, widget.segments[index], baseStyle),
        ],
      ),
      maxLines: widget.maxLines,
      overflow: widget.overflow,
      textAlign: widget.textAlign,
    );
  }

  TextSpan _buildSpan(
      int index, _MetadataSegment segment, TextStyle baseStyle) {
    final isInteractive = segment.onTap != null;
    final isHovered = _hoveredIndexes.contains(index);
    final style = isInteractive && isHovered
        ? baseStyle.copyWith(
            decoration: TextDecoration.underline,
            decorationThickness: 1.5,
          )
        : baseStyle;

    return TextSpan(
      text: segment.text,
      style: style,
      recognizer: _recognizers[index],
      mouseCursor: isInteractive ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: isInteractive
          ? (_) => setState(() => _hoveredIndexes.add(index))
          : null,
      onExit: isInteractive
          ? (_) => setState(() => _hoveredIndexes.remove(index))
          : null,
    );
  }
}

class _MetadataSegment {
  final String text;
  final VoidCallback? onTap;

  const _MetadataSegment({required this.text, this.onTap});
}

typedef _PluginNavigationCallback = void Function(String pluginId);

List<_MetadataSegment> _artistSegments(
  BuildContext context,
  List<ArtistSummary> artists,
) {
  final segments = <_MetadataSegment>[];
  for (var index = 0; index < artists.length; index++) {
    final artist = artists[index];
    if (artist.name.trim().isEmpty) {
      continue;
    }
    if (segments.isNotEmpty) {
      segments.add(const _MetadataSegment(text: ', '));
    }
    segments.add(_summarySegment(
      context,
      id: artist.id,
      label: artist.name,
      onTap: (pluginId) => _openArtist(context, artist, pluginId),
    ));
  }
  return segments;
}

_MetadataSegment _summarySegment(
  BuildContext context, {
  required String id,
  required String label,
  required _PluginNavigationCallback onTap,
}) {
  final parts = tryParseMediaId(id);
  if (parts == null || label.trim().isEmpty) {
    return _MetadataSegment(text: label);
  }

  final loadedPluginIds = context.read<PluginBloc>().state.loadedPluginIds;
  if (!loadedPluginIds.contains(parts.pluginId)) {
    return _MetadataSegment(text: label);
  }

  return _MetadataSegment(
    text: label,
    onTap: () => onTap(parts.pluginId),
  );
}

void _openArtist(BuildContext context, ArtistSummary artist, String pluginId) {
  if (!requirePlugin(
      pluginId, context.read<PluginBloc>().state.loadedPluginIds)) {
    return;
  }
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ArtistView(artist: artist, pluginId: pluginId),
    ),
  );
}

void _openAlbum(BuildContext context, AlbumSummary album, String pluginId) {
  if (!requirePlugin(
      pluginId, context.read<PluginBloc>().state.loadedPluginIds)) {
    return;
  }
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => AlbumView(album: album, pluginId: pluginId),
    ),
  );
}

void _openPlaylist(
  BuildContext context,
  PlaylistSummary playlist,
  String pluginId,
) {
  if (!requirePlugin(
      pluginId, context.read<PluginBloc>().state.loadedPluginIds)) {
    return;
  }
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => OnlPlaylistView(playlist: playlist, pluginId: pluginId),
    ),
  );
}
