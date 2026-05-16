import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../utils/constants.dart';
import '../widgets/playback_mode_status.dart';
import '../widgets/player_controls.dart';
import '../widgets/progress_bar.dart';
import '../widgets/turntable_art.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Now Playing')),
      body: Selector<AudioProvider, SongModel?>(
        selector: (context, provider) => provider.currentSong,
        builder: (context, song, child) {
          if (song == null) {
            return const Center(child: Text('No song is playing'));
          }

          return SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 650;
                final sidePadding = compact ? 16.0 : 20.0;
                final discSize = _discSizeFor(
                  height: constraints.maxHeight,
                  width: constraints.maxWidth,
                );

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(sidePadding, compact ? 8 : 12, sidePadding, 12),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight - 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _VinylSection(song: song, size: discSize),
                        SizedBox(height: compact ? 14 : 18),
                        Text(
                          song.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          song.artist,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppConstants.mutedText),
                        ),
                        SizedBox(height: compact ? 10 : 14),
                        const _NowPlayingProgress(),
                        const SizedBox(height: 8),
                        const PlaybackModeStatus(),
                        SizedBox(height: compact ? 6 : 8),
                        const PlayerControls(),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  double _discSizeFor({
    required double height,
    required double width,
  }) {
    final maxByWidth = (width - 72).clamp(220.0, 300.0);
    final maxByHeight = (height * 0.36).clamp(220.0, 300.0);
    return maxByWidth < maxByHeight ? maxByWidth : maxByHeight;
  }
}

class _VinylSection extends StatelessWidget {
  const _VinylSection({
    required this.song,
    required this.size,
  });

  final SongModel song;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Selector<AudioProvider, bool>(
      selector: (context, provider) => provider.playbackState.isPlaying,
      builder: (context, isPlaying, child) {
        return FittedBox(
          fit: BoxFit.scaleDown,
          child: TurntableArt(
            song: song,
            isPlaying: isPlaying,
            size: size,
          ),
        );
      },
    );
  }
}

class _NowPlayingProgress extends StatelessWidget {
  const _NowPlayingProgress();

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.read<AudioProvider>();

    return StreamBuilder<Duration?>(
      stream: audioProvider.durationStream,
      initialData: Duration.zero,
      builder: (context, durationSnapshot) {
        return StreamBuilder<Duration>(
          stream: audioProvider.positionStream,
          initialData: Duration.zero,
          builder: (context, positionSnapshot) {
            return ProgressBar(
              position: positionSnapshot.data ?? Duration.zero,
              duration: durationSnapshot.data ?? Duration.zero,
              onChanged: audioProvider.seek,
            );
          },
        );
      },
    );
  }
}
