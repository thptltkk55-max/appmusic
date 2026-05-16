import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

import '../models/playback_state_model.dart';
import '../models/song_model.dart';

class AudioPlayerService {
  AudioPlayerService() : player = AudioPlayer();

  final AudioPlayer player;
  List<SongModel> _queue = [];

  List<SongModel> get queue => List.unmodifiable(_queue);
  Stream<Duration> get positionStream => player.positionStream;
  Stream<Duration?> get durationStream => player.durationStream;
  Stream<PlayerState> get playerStateStream => player.playerStateStream;
  Stream<int?> get currentIndexStream => player.currentIndexStream;

  SongModel? get currentSong {
    final index = player.currentIndex;
    if (index == null || index < 0 || index >= _queue.length) {
      return null;
    }
    return _queue[index];
  }

  Future<void> configureSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  Future<void> setQueue(List<SongModel> songs, {int initialIndex = 0}) async {
    _queue = songs;
    if (_queue.isEmpty) {
      await player.stop();
      return;
    }

    final safeIndex = initialIndex.clamp(0, _queue.length - 1).toInt();
    final sources = _queue.map(_sourceForSong).toList(growable: false);
    await player.setAudioSource(
      ConcatenatingAudioSource(children: sources),
      initialIndex: safeIndex,
      initialPosition: Duration.zero,
    );
  }

  Future<void> playSong(List<SongModel> songs, SongModel song) async {
    final index = songs.indexWhere((item) => item.id == song.id);
    await setQueue(songs, initialIndex: index < 0 ? 0 : index);
    await player.play();
  }

  Future<void> play() => player.play();

  Future<void> pause() => player.pause();

  Future<void> stop() => player.stop();

  Future<void> seek(Duration position) => player.seek(position);

  Future<void> next() async {
    if (player.hasNext) {
      await player.seekToNext();
      await player.play();
    }
  }

  Future<void> previous() async {
    if (player.hasPrevious) {
      await player.seekToPrevious();
      await player.play();
    } else {
      await player.seek(Duration.zero);
    }
  }

  Future<void> setShuffleEnabled(bool enabled) async {
    await player.setShuffleModeEnabled(enabled);
  }

  Future<void> setRepeatMode(PlayerRepeatMode mode) async {
    final loopMode = switch (mode) {
      PlayerRepeatMode.off => LoopMode.off,
      PlayerRepeatMode.all => LoopMode.all,
      PlayerRepeatMode.one => LoopMode.one,
    };
    await player.setLoopMode(loopMode);
  }

  Future<void> setVolume(double volume) {
    return player.setVolume(volume.clamp(0, 1).toDouble());
  }

  AudioSource _sourceForSong(SongModel song) {
    if (song.isAsset) {
      return AudioSource.asset(song.path);
    }

    final uriText = song.uri?.trim();
    if (uriText != null && uriText.isNotEmpty) {
      return AudioSource.uri(Uri.parse(uriText));
    }

    return AudioSource.uri(Uri.file(song.path));
  }

  Future<void> dispose() async {
    await player.dispose();
  }
}
