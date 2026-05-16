import 'package:flutter/foundation.dart';

import '../models/playlist_model.dart';
import '../models/song_model.dart';
import '../services/storage_service.dart';

class PlaylistProvider extends ChangeNotifier {
  PlaylistProvider({StorageService? storageService}) : _storageService = storageService ?? StorageService();

  final StorageService _storageService;
  List<PlaylistModel> _playlists = [];
  bool _isLoading = true;

  List<PlaylistModel> get playlists => List.unmodifiable(_playlists);
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _playlists = await _storageService.loadPlaylists();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createPlaylist(String name) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      return;
    }

    _playlists = [
      ..._playlists,
      PlaylistModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: cleanName,
        songIds: const [],
        createdAt: DateTime.now(),
      ),
    ];
    await _save();
  }

  Future<void> renamePlaylist(String playlistId, String name) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      return;
    }

    _playlists = _playlists
        .map((playlist) => playlist.id == playlistId ? playlist.copyWith(name: cleanName) : playlist)
        .toList(growable: false);
    await _save();
  }

  Future<void> deletePlaylist(String playlistId) async {
    _playlists = _playlists.where((playlist) => playlist.id != playlistId).toList(growable: false);
    await _save();
  }

  Future<void> addSongToPlaylist(String playlistId, SongModel song) async {
    _playlists = _playlists.map((playlist) {
      if (playlist.id != playlistId || playlist.songIds.contains(song.id)) {
        return playlist;
      }

      return playlist.copyWith(songIds: [...playlist.songIds, song.id]);
    }).toList(growable: false);
    await _save();
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    _playlists = _playlists.map((playlist) {
      if (playlist.id != playlistId) {
        return playlist;
      }

      return playlist.copyWith(
        songIds: playlist.songIds.where((id) => id != songId).toList(growable: false),
      );
    }).toList(growable: false);
    await _save();
  }

  Future<void> _save() async {
    await _storageService.savePlaylists(_playlists);
    notifyListeners();
  }
}
