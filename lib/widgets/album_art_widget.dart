import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart' as audio_query;

import '../models/song_model.dart';
import '../utils/constants.dart';

class AlbumArtWidget extends StatelessWidget {
  const AlbumArtWidget({
    super.key,
    required this.song,
    this.size = 48,
    this.radius = 6,
    this.iconSize = 24,
  });

  final SongModel song;
  final double size;
  final double radius;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final numericId = int.tryParse(song.id);

    return RepaintBoundary(
      key: ValueKey('album-art-${song.id}-$size'),
      child: SizedBox.square(
        dimension: size,
        child: numericId == null
            ? _DefaultArtwork(size: size, radius: radius, iconSize: iconSize)
            : audio_query.QueryArtworkWidget(
                key: ValueKey('query-artwork-${song.id}-$size'),
                id: numericId,
                type: audio_query.ArtworkType.AUDIO,
                artworkFit: BoxFit.cover,
                artworkWidth: size,
                artworkHeight: size,
                artworkBorder: BorderRadius.circular(radius),
                keepOldArtwork: true,
                nullArtworkWidget: _DefaultArtwork(
                  size: size,
                  radius: radius,
                  iconSize: iconSize,
                ),
              ),
      ),
    );
  }
}

class _DefaultArtwork extends StatelessWidget {
  const _DefaultArtwork({
    required this.size,
    required this.radius,
    required this.iconSize,
  });

  final double size;
  final double radius;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppConstants.card,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(Icons.music_note, size: iconSize, color: AppConstants.spotifyGreen),
    );
  }
}
