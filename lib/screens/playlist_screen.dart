import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/playlist_model.dart';
import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../providers/playlist_provider.dart';
import '../utils/constants.dart';
import '../widgets/create_playlist_dialog.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(
      builder: (context, playlistProvider, child) {
        if (playlistProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FilledButton.icon(
              onPressed: () => _showCreatePlaylistDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Tạo playlist'),
            ),
            const SizedBox(height: 12),
            if (playlistProvider.playlists.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 48),
                child: Center(child: Text('Chưa có playlist')),
              )
            else
              ...playlistProvider.playlists.map((playlist) => _PlaylistCard(playlist: playlist)),
          ],
        );
      },
    );
  }

  Future<void> _showCreatePlaylistDialog(BuildContext context) async {
    final playlistProvider = context.read<PlaylistProvider>();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return const CreatePlaylistDialog();
      },
    );

    if (name == null || name.trim().isEmpty) {
      return;
    }

    await playlistProvider.createPlaylist(name);
  }

  static Future<void> showRenamePlaylistDialog(
    BuildContext context, {
    required PlaylistModel playlist,
  }) async {
    final playlistProvider = context.read<PlaylistProvider>();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return CreatePlaylistDialog(
          initialName: playlist.name,
          title: 'Đổi tên playlist',
          actionLabel: 'Lưu',
        );
      },
    );

    if (name == null || name.trim().isEmpty) {
      return;
    }

    await playlistProvider.renamePlaylist(playlist.id, name);
  }
}

class _PlaylistCard extends StatelessWidget {
  const _PlaylistCard({required this.playlist});

  final PlaylistModel playlist;

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioProvider>();
    final songs = audioProvider.songs.where((song) => playlist.songIds.contains(song.id)).toList(growable: false);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        leading: const Icon(Icons.queue_music),
        title: Text(playlist.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text('${songs.length} bài hát'),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: AppConstants.spotifyGreen,
                  ),
                  onPressed: () => _playPlaylist(context, songs),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Phát playlist'),
                ),
                TextButton.icon(
                  onPressed: () => _showAddSongSheet(context),
                  icon: const Icon(Icons.playlist_add),
                  label: const Text('Thêm bài hát'),
                ),
                IconButton(
                  tooltip: 'Đổi tên',
                  onPressed: () => PlaylistScreen.showRenamePlaylistDialog(context, playlist: playlist),
                  icon: const Icon(Icons.edit),
                ),
                IconButton(
                  tooltip: 'Xóa',
                  onPressed: () => context.read<PlaylistProvider>().deletePlaylist(playlist.id),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ),
          if (songs.isEmpty)
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Playlist rỗng'),
              ),
            )
          else
            ...songs.map(
              (song) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: () => context.read<AudioProvider>().playSong(song, queue: songs),
                trailing: IconButton(
                  tooltip: 'Xóa khỏi playlist',
                  onPressed: () => context.read<PlaylistProvider>().removeSongFromPlaylist(playlist.id, song.id),
                  icon: const Icon(Icons.remove_circle_outline),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _playPlaylist(BuildContext context, List<SongModel> songs) {
    if (songs.isEmpty) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(content: Text('Playlist chưa có bài hát')),
        );
      return;
    }

    context.read<AudioProvider>().playSong(songs.first, queue: songs);
  }

  Future<void> _showAddSongSheet(BuildContext context) {
    final songs = context.read<AudioProvider>().songs;
    final playlistProvider = context.read<PlaylistProvider>();
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        if (songs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('No songs found')),
          );
        }

        return ListView.builder(
          itemCount: songs.length,
          itemBuilder: (context, index) {
            final song = songs[index];
            final added = playlist.songIds.contains(song.id);
            return ListTile(
              title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: Icon(added ? Icons.check_circle : Icons.add_circle_outline),
              onTap: added
                  ? null
                  : () {
                      Navigator.of(sheetContext).pop();
                      playlistProvider.addSongToPlaylist(playlist.id, song);
                    },
            );
          },
        );
      },
    );
  }
}
