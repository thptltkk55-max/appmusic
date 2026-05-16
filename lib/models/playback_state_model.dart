enum PlayerRepeatMode {
  off,
  all,
  one,
}

class PlaybackStateModel {
  const PlaybackStateModel({
    this.isPlaying = false,
    this.shuffleEnabled = false,
    this.repeatMode = PlayerRepeatMode.off,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.currentSongId,
  });

  final bool isPlaying;
  final bool shuffleEnabled;
  final PlayerRepeatMode repeatMode;
  final Duration position;
  final Duration duration;
  final String? currentSongId;

  PlaybackStateModel copyWith({
    bool? isPlaying,
    bool? shuffleEnabled,
    PlayerRepeatMode? repeatMode,
    Duration? position,
    Duration? duration,
    String? currentSongId,
  }) {
    return PlaybackStateModel(
      isPlaying: isPlaying ?? this.isPlaying,
      shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
      repeatMode: repeatMode ?? this.repeatMode,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      currentSongId: currentSongId ?? this.currentSongId,
    );
  }
}
