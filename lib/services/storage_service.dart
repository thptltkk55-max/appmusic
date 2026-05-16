import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/playback_state_model.dart';
import '../models/playlist_model.dart';

class StorageService {
  static const _playlistsKey = 'playlists';
  static const _shuffleKey = 'shuffle_enabled';
  static const _repeatKey = 'repeat_mode';
  static const _volumeKey = 'volume';
  static const _lastSongKey = 'last_song_id';

  Future<List<PlaylistModel>> loadPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_playlistsKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(PlaylistModel.fromJson)
          .toList(growable: false);
    } catch (_) {
      return [];
    }
  }

  Future<void> savePlaylists(List<PlaylistModel> playlists) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(playlists.map((playlist) => playlist.toJson()).toList());
    await prefs.setString(_playlistsKey, encoded);
  }

  Future<bool> loadShuffleEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_shuffleKey) ?? false;
  }

  Future<void> saveShuffleEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_shuffleKey, value);
  }

  Future<PlayerRepeatMode> loadRepeatMode() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_repeatKey) ?? PlayerRepeatMode.off.index;
    if (index < 0 || index >= PlayerRepeatMode.values.length) {
      return PlayerRepeatMode.off;
    }

    return PlayerRepeatMode.values[index];
  }

  Future<void> saveRepeatMode(PlayerRepeatMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_repeatKey, mode.index);
  }

  Future<double> loadVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_volumeKey) ?? 1;
  }

  Future<void> saveVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_volumeKey, volume.clamp(0, 1).toDouble());
  }

  Future<String?> loadLastSongId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastSongKey);
  }

  Future<void> saveLastSongId(String? songId) async {
    final prefs = await SharedPreferences.getInstance();
    if (songId == null) {
      await prefs.remove(_lastSongKey);
    } else {
      await prefs.setString(_lastSongKey, songId);
    }
  }
}
