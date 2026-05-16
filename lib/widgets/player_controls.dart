import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/playback_state_model.dart';
import '../providers/audio_provider.dart';
import '../utils/constants.dart';

class PlayerControls extends StatelessWidget {
  const PlayerControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, child) {
        final playbackState = audioProvider.playbackState;
        final repeatIcon = switch (playbackState.repeatMode) {
          PlayerRepeatMode.off => Icons.repeat,
          PlayerRepeatMode.all => Icons.repeat_on,
          PlayerRepeatMode.one => Icons.repeat_one_on,
        };

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              tooltip: 'Phát ngẫu nhiên',
              iconSize: 26,
              color: playbackState.shuffleEnabled ? AppConstants.spotifyGreen : AppConstants.mutedText,
              onPressed: () async {
                await audioProvider.toggleShuffle();
                if (!context.mounted) {
                  return;
                }

                final enabled = audioProvider.playbackState.shuffleEnabled;
                _showModeSnackBar(
                  context,
                  enabled ? 'Đang phát ngẫu nhiên' : 'Đã tắt phát ngẫu nhiên',
                );
              },
              icon: const Icon(Icons.shuffle),
            ),
            IconButton(
              tooltip: 'Previous',
              iconSize: 32,
              onPressed: audioProvider.previous,
              icon: const Icon(Icons.skip_previous),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(15),
              ),
              onPressed: audioProvider.togglePlayPause,
              child: Icon(
                playbackState.isPlaying ? Icons.pause : Icons.play_arrow,
                size: 30,
              ),
            ),
            IconButton(
              tooltip: 'Next',
              iconSize: 32,
              onPressed: audioProvider.next,
              icon: const Icon(Icons.skip_next),
            ),
            IconButton(
              tooltip: 'Lặp lại',
              iconSize: 26,
              color: playbackState.repeatMode == PlayerRepeatMode.off ? AppConstants.mutedText : AppConstants.spotifyGreen,
              onPressed: () async {
                await audioProvider.cycleRepeatMode();
                if (!context.mounted) {
                  return;
                }

                _showModeSnackBar(
                  context,
                  _repeatSnackBarText(audioProvider.playbackState.repeatMode),
                );
              },
              icon: Icon(repeatIcon),
            ),
          ],
        );
      },
    );
  }
}

String _repeatSnackBarText(PlayerRepeatMode repeatMode) {
  return switch (repeatMode) {
    PlayerRepeatMode.off => 'Đã tắt lặp lại',
    PlayerRepeatMode.all => 'Đang lặp lại danh sách',
    PlayerRepeatMode.one => 'Đang lặp lại bài hiện tại',
  };
}

void _showModeSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppConstants.card,
      ),
    );
}
