import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/playback_state_model.dart';
import '../providers/audio_provider.dart';
import '../utils/constants.dart';

class PlaybackModeStatus extends StatelessWidget {
  const PlaybackModeStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<AudioProvider, _PlaybackModeState>(
      selector: (context, provider) => _PlaybackModeState(
        shuffleEnabled: provider.playbackState.shuffleEnabled,
        repeatMode: provider.playbackState.repeatMode,
      ),
      builder: (context, modeState, child) {
        final text = _modeStatusText(modeState.shuffleEnabled, modeState.repeatMode);
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: Text(
            text,
            key: ValueKey(text),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppConstants.mutedText,
                  fontWeight: FontWeight.w600,
                ),
          ),
        );
      },
    );
  }
}

class _PlaybackModeState {
  const _PlaybackModeState({
    required this.shuffleEnabled,
    required this.repeatMode,
  });

  final bool shuffleEnabled;
  final PlayerRepeatMode repeatMode;

  @override
  bool operator ==(Object other) {
    return other is _PlaybackModeState && other.shuffleEnabled == shuffleEnabled && other.repeatMode == repeatMode;
  }

  @override
  int get hashCode => Object.hash(shuffleEnabled, repeatMode);
}

String _modeStatusText(bool shuffleEnabled, PlayerRepeatMode repeatMode) {
  if (!shuffleEnabled && repeatMode == PlayerRepeatMode.off) {
    return 'Phát theo thứ tự';
  }

  final parts = <String>[];
  if (shuffleEnabled) {
    parts.add('Đang phát ngẫu nhiên');
  }

  final repeatText = switch (repeatMode) {
    PlayerRepeatMode.off => null,
    PlayerRepeatMode.all => 'Lặp lại danh sách',
    PlayerRepeatMode.one => 'Lặp lại bài hiện tại',
  };
  if (repeatText != null) {
    parts.add(repeatText);
  }

  return parts.join(' • ');
}
