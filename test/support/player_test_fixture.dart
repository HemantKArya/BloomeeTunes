import 'package:Bloomee/core/adapters/track_adapter.dart';
import 'package:Bloomee/core/models/exported.dart' hide MediaItem;
import 'package:Bloomee/services/bloomee_player.dart';
import 'package:Bloomee/services/player/player_engine.dart';
import 'package:audio_service/audio_service.dart';
import 'package:rxdart/rxdart.dart';

// Exercise the production screen and controls without native audio or a DB.
class TestPlayerEngine implements PlayerEngine {
  final positions =
      BehaviorSubject<Duration>.seeded(const Duration(seconds: 31));
  @override
  Duration get position => positions.value;
  @override
  Stream<Duration> get positionStream => positions.stream;
  @override
  Stream<Duration> get durationStream =>
      Stream.value(const Duration(minutes: 3));
  @override
  Stream<Duration> get bufferedStream =>
      Stream.value(const Duration(minutes: 1));
  @override
  Stream<bool> get playingStream => Stream.value(true);
  @override
  Stream<EngineState> get stateStream => Stream.value(EngineState.ready);
  @override
  Stream<double> get volumeStream => Stream.value(0.7);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class TestMusicPlayer implements BloomeeMusicPlayer {
  @override
  PlayerEngine engine = TestPlayerEngine();
  Duration? lastSeek;
  @override
  final mediaItem = BehaviorSubject<MediaItem?>();
  @override
  final queue = BehaviorSubject<List<MediaItem>>();
  @override
  final queueTitle = BehaviorSubject.seeded('Recently');
  @override
  final loopMode = BehaviorSubject.seeded(LoopMode.off);
  @override
  final shuffleMode = BehaviorSubject.seeded(false);
  @override
  final isResolving = BehaviorSubject.seeded(false);
  @override
  final currentTrackInfo = const Track(
    id: 'current',
    title: 'Good For You (feat. A\$AP Rocky)',
    artists: [],
    thumbnail: Artwork(url: '', layout: ImageLayout.square),
    isExplicit: false,
  );
  @override
  Track get currentMedia => currentTrackInfo;

  TestMusicPlayer() {
    final current = trackToMediaItem(currentTrackInfo).copyWith(
      artUri: Uri.parse('asset:preview-artwork'),
    );
    mediaItem.add(current);
    queue.add([
      current,
      ...List.generate(
          12,
          (i) => MediaItem(
                id: 'song_$i',
                title: 'Queue track ${i + 1}',
                artist: 'Artist',
              ))
    ]);
  }

  @override
  void syncPublicState() {}
  @override
  Future<void> skipToPrevious() async {}
  @override
  Future<void> skipToNext() async {}
  @override
  Future<void> moveQueueItem(int oldIndex, int newIndex) async {}
  @override
  Future<void> seek(Duration position) async {
    lastSeek = position;
    if (engine is TestPlayerEngine) {
      (engine as TestPlayerEngine).positions.add(position);
    }
  }

  @override
  Future<void> pause() async {}
  @override
  Future<void> play() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  Future<void> closeStreams() async {
    if (engine is TestPlayerEngine) {
      await (engine as TestPlayerEngine).positions.close();
    }
    await Future.wait([
      mediaItem.close(),
      queue.close(),
      queueTitle.close(),
      loopMode.close(),
      shuffleMode.close(),
      isResolving.close(),
    ]);
  }
}
