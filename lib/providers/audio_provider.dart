import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../models/playback_state_model.dart';
import '../models/song_model.dart';
import '../services/audio_player_service.dart';
import '../services/background_audio_handler.dart';
import '../services/permission_service.dart';
import '../services/song_service.dart';
import '../services/storage_service.dart';

class AudioProvider extends ChangeNotifier {
  AudioProvider({
    AudioPlayerService? audioPlayerService,
    PermissionService? permissionService,
    SongService? songService,
    StorageService? storageService,
  })  : _audioPlayerService = audioPlayerService ?? AudioPlayerService(),
        _permissionService = permissionService ?? PermissionService(),
        _songService = songService ?? SongService(),
        _storageService = storageService ?? StorageService();

  final AudioPlayerService _audioPlayerService;
  final PermissionService _permissionService;
  final SongService _songService;
  final StorageService _storageService;
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  BackgroundAudioHandler? _backgroundAudioHandler;

  List<SongModel> _songs = [];
  PlaybackStateModel _playbackState = const PlaybackStateModel();
  bool _hasPermission = false;
  bool _isLoading = true;
  bool _isPermissionPermanentlyDenied = false;
  double _volume = 1;

  List<SongModel> get songs => _songs;
  PlaybackStateModel get playbackState => _playbackState;
  bool get hasPermission => _hasPermission;
  bool get isLoading => _isLoading;
  bool get isPermissionPermanentlyDenied => _isPermissionPermanentlyDenied;
  double get volume => _volume;
  SongModel? get currentSong => _audioPlayerService.currentSong;
  Stream<Duration> get positionStream => _audioPlayerService.positionStream;
  Stream<Duration?> get durationStream => _audioPlayerService.durationStream;

  Future<void> initialize() async {
    await _audioPlayerService.configureSession();
    try {
      _backgroundAudioHandler = await initBackgroundAudioHandler(_audioPlayerService);
    } catch (_) {
      _backgroundAudioHandler = null;
    }
    _bindPlayerStreams();

    final shuffle = await _storageService.loadShuffleEnabled();
    final repeatMode = await _storageService.loadRepeatMode();
    final volume = await _storageService.loadVolume();
    _volume = volume;
    _playbackState = _playbackState.copyWith(
      shuffleEnabled: shuffle,
      repeatMode: repeatMode,
    );
    await _setShuffleEnabledOnPlayer(shuffle);
    await _setRepeatModeOnPlayer(repeatMode);
    await _setVolumeOnPlayer(volume);

    _hasPermission = await _permissionService.hasAudioPermission();
    _isPermissionPermanentlyDenied = await _permissionService.isAudioPermissionPermanentlyDenied();
    if (_hasPermission) {
      await loadSongs();
    } else {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> requestPermissionAndLoad() async {
    _isLoading = true;
    notifyListeners();

    _hasPermission = await _permissionService.requestAudioPermission();
    _isPermissionPermanentlyDenied = await _permissionService.isAudioPermissionPermanentlyDenied();
    if (_hasPermission) {
      await loadSongs();
    } else {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSongs() async {
    _isLoading = true;
    notifyListeners();

    final deviceSongs = await _songService.loadDeviceSongs();
    final merged = <String, SongModel>{
      for (final song in _songs.where((song) => song.artist == 'Local file')) song.id: song,
      for (final song in deviceSongs) song.id: song,
    };
    _songs = merged.values.toList(growable: false);
    _hasPermission = true;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> pickAudioFiles() async {
    final pickedSongs = await _songService.pickAudioFiles();
    if (pickedSongs.isEmpty) {
      return;
    }

    final merged = <String, SongModel>{
      for (final song in _songs) song.id: song,
      for (final song in pickedSongs) song.id: song,
    };
    _songs = merged.values.toList(growable: false);
    notifyListeners();
  }

  Future<void> playSong(SongModel song, {List<SongModel>? queue}) async {
    final playQueue = queue == null || queue.isEmpty ? _songs : queue;
    if (playQueue.isEmpty) {
      return;
    }

    unawaited(_permissionService.requestNotificationPermission());
    if (_backgroundAudioHandler != null) {
      await _backgroundAudioHandler!.playSong(playQueue, song);
    } else {
      await _audioPlayerService.playSong(playQueue, song);
    }
    await _storageService.saveLastSongId(song.id);
    _playbackState = _playbackState.copyWith(currentSongId: song.id);
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (_playbackState.isPlaying) {
      await (_backgroundAudioHandler?.pause() ?? _audioPlayerService.pause());
    } else if (currentSong != null) {
      unawaited(_permissionService.requestNotificationPermission());
      await (_backgroundAudioHandler?.play() ?? _audioPlayerService.play());
    } else if (_songs.isNotEmpty) {
      await playSong(_songs.first);
    }
  }

  Future<void> stop() async {
    await (_backgroundAudioHandler?.stop() ?? _audioPlayerService.stop());
  }

  Future<void> seek(Duration position) async {
    await (_backgroundAudioHandler?.seek(position) ?? _audioPlayerService.seek(position));
  }

  Future<void> next() async {
    await (_backgroundAudioHandler?.skipToNext() ?? _audioPlayerService.next());
  }

  Future<void> previous() async {
    await (_backgroundAudioHandler?.skipToPrevious() ?? _audioPlayerService.previous());
  }

  Future<void> toggleShuffle() async {
    final enabled = !_playbackState.shuffleEnabled;
    await _setShuffleEnabledOnPlayer(enabled);
    await _storageService.saveShuffleEnabled(enabled);
    _playbackState = _playbackState.copyWith(shuffleEnabled: enabled);
    notifyListeners();
  }

  Future<void> cycleRepeatMode() async {
    final nextMode = switch (_playbackState.repeatMode) {
      PlayerRepeatMode.off => PlayerRepeatMode.all,
      PlayerRepeatMode.all => PlayerRepeatMode.one,
      PlayerRepeatMode.one => PlayerRepeatMode.off,
    };
    await _setRepeatModeOnPlayer(nextMode);
    await _storageService.saveRepeatMode(nextMode);
    _playbackState = _playbackState.copyWith(repeatMode: nextMode);
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0, 1);
    await _setVolumeOnPlayer(_volume);
    await _storageService.saveVolume(_volume);
    notifyListeners();
  }

  Future<void> openAppSettings() {
    return _permissionService.openSystemSettings();
  }

  void _bindPlayerStreams() {
    _subscriptions
      ..add(_audioPlayerService.playerStateStream.listen((playerState) {
        _playbackState = _playbackState.copyWith(
          isPlaying: playerState.playing && playerState.processingState != ProcessingState.completed,
        );
        notifyListeners();
      }))
      ..add(_audioPlayerService.currentIndexStream.listen((_) {
        final song = currentSong;
        if (song != null) {
          _playbackState = _playbackState.copyWith(currentSongId: song.id);
          unawaited(_storageService.saveLastSongId(song.id));
        }
        notifyListeners();
      }));
  }

  Future<void> _setShuffleEnabledOnPlayer(bool enabled) {
    return _backgroundAudioHandler?.setShuffleEnabled(enabled) ?? _audioPlayerService.setShuffleEnabled(enabled);
  }

  Future<void> _setRepeatModeOnPlayer(PlayerRepeatMode mode) {
    return _backgroundAudioHandler?.setAppRepeatMode(mode) ?? _audioPlayerService.setRepeatMode(mode);
  }

  Future<void> _setVolumeOnPlayer(double volume) {
    return _backgroundAudioHandler?.setVolume(volume) ?? _audioPlayerService.setVolume(volume);
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    unawaited(_backgroundAudioHandler?.dispose());
    unawaited(_audioPlayerService.dispose());
    super.dispose();
  }
}
