import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../widgets/song_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<AudioProvider, _HomeViewState>(
      selector: (context, provider) => _HomeViewState(
        isLoading: provider.isLoading,
        hasPermission: provider.hasPermission,
        songs: provider.songs,
      ),
      builder: (context, viewState, child) {
        if (viewState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!viewState.hasPermission) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.library_music, size: 72),
                  const SizedBox(height: 16),
                  const Text(
                    'Ứng dụng cần quyền đọc nhạc để hiển thị bài hát trong thiết bị.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: context.read<AudioProvider>().requestPermissionAndLoad,
                    icon: const Icon(Icons.lock_open),
                    label: const Text('Xin quyền đọc nhạc'),
                  ),
                  TextButton.icon(
                    onPressed: context.read<AudioProvider>().openAppSettings,
                    icon: const Icon(Icons.settings),
                    label: const Text('Mở cài đặt app'),
                  ),
                  TextButton.icon(
                    onPressed: context.read<AudioProvider>().pickAudioFiles,
                    icon: const Icon(Icons.audio_file),
                    label: const Text('Chọn file nhạc thủ công'),
                  ),
                ],
              ),
            ),
          );
        }

        if (viewState.songs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.music_off, size: 72),
                  const SizedBox(height: 16),
                  const Text('No songs found'),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: context.read<AudioProvider>().pickAudioFiles,
                    icon: const Icon(Icons.audio_file),
                    label: const Text('Chọn file nhạc'),
                  ),
                  TextButton.icon(
                    onPressed: context.read<AudioProvider>().loadSongs,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tải lại danh sách'),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: context.read<AudioProvider>().loadSongs,
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 12),
            itemCount: viewState.songs.length,
            itemBuilder: (context, index) {
              final song = viewState.songs[index];
              return SongTile(
                key: ValueKey(song.id),
                song: song,
                onTap: () => context.read<AudioProvider>().playSong(song),
              );
            },
          ),
        );
      },
    );
  }
}

class _HomeViewState {
  const _HomeViewState({
    required this.isLoading,
    required this.hasPermission,
    required this.songs,
  });

  final bool isLoading;
  final bool hasPermission;
  final List<SongModel> songs;

  @override
  bool operator ==(Object other) {
    return other is _HomeViewState &&
        other.isLoading == isLoading &&
        other.hasPermission == hasPermission &&
        identical(other.songs, songs);
  }

  @override
  int get hashCode => Object.hash(isLoading, hasPermission, identityHashCode(songs));
}
