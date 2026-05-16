import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart' as audio_query;
import 'package:path_provider/path_provider.dart';

import '../models/playback_state_model.dart';
import '../models/song_model.dart';
import 'audio_player_service.dart';

class BackgroundAudioHandler extends BaseAudioHandler with SeekHandler {
  BackgroundAudioHandler(this._playerService) {
    _subscriptions
      ..add(_playerService.player.playbackEventStream.listen(_broadcastState))
      ..add(_playerService.player.currentIndexStream.listen((index) {
        _updateCurrentMediaItem(index);
      }))
      ..add(_playerService.player.shuffleModeEnabledStream.listen((enabled) {
        playbackState.add(
          playbackState.value.copyWith(
            shuffleMode: enabled ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
          ),
        );
      }));
  }

  final AudioPlayerService _playerService;
  final audio_query.OnAudioQuery _audioQuery = audio_query.OnAudioQuery();
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  List<SongModel> _songs = [];

  Future<void> playSong(List<SongModel> songs, SongModel song) async {
    _songs = songs;
    queue.add(await _songsToMediaItems(songs));
    await _playerService.playSong(songs, song);
    _updateCurrentMediaItem(_playerService.player.currentIndex);
  }

  Future<void> setShuffleEnabled(bool enabled) async {
    await _playerService.setShuffleEnabled(enabled);
    playbackState.add(
      playbackState.value.copyWith(
        shuffleMode: enabled ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
      ),
    );
  }

  Future<void> setAppRepeatMode(PlayerRepeatMode mode) async {
    await _playerService.setRepeatMode(mode);
    playbackState.add(
      playbackState.value.copyWith(repeatMode: _audioServiceRepeatMode(mode)),
    );
  }

  Future<void> setVolume(double volume) {
    return _playerService.setVolume(volume);
  }

  @override
  Future<void> play() => _playerService.play();

  @override
  Future<void> pause() => _playerService.pause();

  @override
  Future<void> stop() async {
    await _playerService.stop();
    playbackState.add(
      playbackState.value.copyWith(
        processingState: AudioProcessingState.idle,
        playing: false,
      ),
    );
  }

  @override
  Future<void> seek(Duration position) => _playerService.seek(position);

  @override
  Future<void> skipToNext() => _playerService.next();

  @override
  Future<void> skipToPrevious() => _playerService.previous();

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= _songs.length) {
      return;
    }

    await _playerService.player.seek(Duration.zero, index: index);
    await _playerService.play();
  }

  Future<void> dispose() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
  }

  Future<List<MediaItem>> _songsToMediaItems(List<SongModel> songs) {
    return Future.wait(songs.map(_songToMediaItem));
  }

  Future<MediaItem> _songToMediaItem(SongModel song) async {
    return MediaItem(
      id: song.id,
      title: song.title,
      artist: song.artist,
      album: song.album,
      duration: song.duration == Duration.zero ? null : song.duration,
      artUri: await _artUriForSong(song),
      extras: {
        'path': song.path,
        'uri': song.uri,
      },
    );
  }

  Future<Uri?> _artUriForSong(SongModel song) async {
    final audioId = int.tryParse(song.id);
    if (audioId == null) {
      return null;
    }

    try {
      final artwork = await _audioQuery.queryArtwork(
        audioId,
        audio_query.ArtworkType.AUDIO,
        format: audio_query.ArtworkFormat.JPEG,
        size: 512,
        quality: 90,
      );
      if (artwork == null || artwork.isEmpty) {
        return null;
      }

      final cacheDir = await getTemporaryDirectory();
      final file = File('${cacheDir.path}${Platform.pathSeparator}song_art_$audioId.jpg');
      await file.writeAsBytes(artwork, flush: true);
      return file.uri;
    } catch (_) {
      return null;
    }
  }

  void _updateCurrentMediaItem(int? index) {
    final safeIndex = index ?? _playerService.player.currentIndex;
    if (safeIndex == null || safeIndex < 0 || safeIndex >= queue.value.length) {
      return;
    }

    mediaItem.add(queue.value[safeIndex]);
  }

  void _broadcastState(PlaybackEvent event) {
    final playing = _playerService.player.playing;
    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        androidCompactActionIndices: const [0, 1, 2],
        systemActions: const {
          MediaAction.seek,
          MediaAction.skipToPrevious,
          MediaAction.skipToNext,
          MediaAction.stop,
        },
        processingState: _audioProcessingState(_playerService.player.processingState),
        playing: playing,
        updatePosition: _playerService.player.position,
        bufferedPosition: _playerService.player.bufferedPosition,
        speed: _playerService.player.speed,
        queueIndex: event.currentIndex,
      ),
    );
  }

  AudioProcessingState _audioProcessingState(ProcessingState state) {
    return switch (state) {
      ProcessingState.idle => AudioProcessingState.idle,
      ProcessingState.loading => AudioProcessingState.loading,
      ProcessingState.buffering => AudioProcessingState.buffering,
      ProcessingState.ready => AudioProcessingState.ready,
      ProcessingState.completed => AudioProcessingState.completed,
    };
  }

  AudioServiceRepeatMode _audioServiceRepeatMode(PlayerRepeatMode mode) {
    return switch (mode) {
      PlayerRepeatMode.off => AudioServiceRepeatMode.none,
      PlayerRepeatMode.all => AudioServiceRepeatMode.all,
      PlayerRepeatMode.one => AudioServiceRepeatMode.one,
    };
  }
}

Future<BackgroundAudioHandler> initBackgroundAudioHandler(AudioPlayerService playerService) async {
  return AudioService.init(
    builder: () => BackgroundAudioHandler(playerService),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.appmusic.channel.audio',
      androidNotificationChannelName: 'Music playback',
      androidNotificationChannelDescription: 'Offline music playback controls',
      androidNotificationIcon: 'mipmap/ic_launcher',
      androidShowNotificationBadge: true,
      androidStopForegroundOnPause: false,
      androidNotificationOngoing: false,
    ),
  );
}
