import 'package:Bloomee/services/scrobble/lastfm_api.dart';

/// A scrobbling backend (Last.fm today, ListenBrainz later).
abstract class ScrobbleProvider {
  /// Stable id, used to namespace the persistent queue.
  String get id;

  /// True when credentials/session are available.
  bool get isReady;

  Future<void> nowPlaying(ScrobbleTrack track);

  /// Submit up to [maxBatch] listens. Must never throw.
  Future<ScrobbleOutcome> submit(List<ScrobbleTrack> batch);

  int get maxBatch;
}

class LastFmProvider implements ScrobbleProvider {
  @override
  String get id => 'lastfm';

  @override
  bool get isReady => LastFmAPI.initialized;

  @override
  int get maxBatch => 50;

  @override
  Future<void> nowPlaying(ScrobbleTrack track) =>
      LastFmAPI.updateNowPlaying(track);

  @override
  Future<ScrobbleOutcome> submit(List<ScrobbleTrack> batch) =>
      LastFmAPI.scrobble(batch);
}
