import 'package:file_picker/file_picker.dart';
import 'package:on_audio_query/on_audio_query.dart' as audio_query;

import '../models/song_model.dart';

class SongService {
  SongService({audio_query.OnAudioQuery? audioQuery}) : _audioQuery = audioQuery ?? audio_query.OnAudioQuery();

  final audio_query.OnAudioQuery _audioQuery;

  Future<List<SongModel>> loadDeviceSongs() async {
    try {
      final hasPermission = await _audioQuery.permissionsStatus();
      final granted = hasPermission || await _audioQuery.permissionsRequest(retryRequest: false);
      if (!granted) {
        return [];
      }

      final songs = await _audioQuery.querySongs(
        sortType: audio_query.SongSortType.TITLE,
        orderType: audio_query.OrderType.ASC_OR_SMALLER,
        uriType: audio_query.UriType.EXTERNAL,
        ignoreCase: true,
      );

      return songs
          .where((song) => (song.duration ?? 0) > 0 && song.data.trim().isNotEmpty)
          .map(SongModel.fromDeviceSong)
          .toList(growable: false);
    } catch (_) {
      return [];
    }
  }

  Future<List<SongModel>> pickAudioFiles() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
      );

      final files = result?.files ?? const <PlatformFile>[];
      return files
          .where((file) => file.path != null && file.path!.trim().isNotEmpty)
          .map((file) => SongModel.fromPickedFile(file.path!))
          .toList(growable: false);
    } catch (_) {
      return [];
    }
  }
}
