import 'package:on_audio_query/on_audio_query.dart' as audio_query;

class SongModel {
  const SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.path,
    required this.uri,
    required this.duration,
    this.isAsset = false,
  });

  final String id;
  final String title;
  final String artist;
  final String album;
  final String path;
  final String? uri;
  final Duration duration;
  final bool isAsset;

  factory SongModel.fromDeviceSong(audio_query.SongModel song) {
    return SongModel(
      id: song.id.toString(),
      title: song.title.trim().isEmpty ? song.displayNameWOExt : song.title,
      artist: (song.artist?.trim().isNotEmpty ?? false) ? song.artist!.trim() : 'Unknown artist',
      album: (song.album?.trim().isNotEmpty ?? false) ? song.album!.trim() : 'Unknown album',
      path: song.data,
      uri: song.uri,
      duration: Duration(milliseconds: song.duration ?? 0),
    );
  }

  factory SongModel.fromPickedFile(String path) {
    final normalizedPath = path.replaceAll('\\', '/');
    final fileName = normalizedPath.split('/').last;
    final title = fileName.contains('.') ? fileName.substring(0, fileName.lastIndexOf('.')) : fileName;

    return SongModel(
      id: path,
      title: title.isEmpty ? 'Picked audio' : title,
      artist: 'Local file',
      album: 'Picked audio',
      path: path,
      uri: null,
      duration: Duration.zero,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'path': path,
      'uri': uri,
      'duration': duration.inMilliseconds,
      'isAsset': isAsset,
    };
  }

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Unknown title',
      artist: json['artist'] as String? ?? 'Unknown artist',
      album: json['album'] as String? ?? 'Unknown album',
      path: json['path'] as String? ?? '',
      uri: json['uri'] as String?,
      duration: Duration(milliseconds: json['duration'] as int? ?? 0),
      isAsset: json['isAsset'] as bool? ?? false,
    );
  }
}
