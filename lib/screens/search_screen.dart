import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/audio_provider.dart';
import '../widgets/song_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _controller,
            onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Tìm theo tên bài hát hoặc ca sĩ',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear',
                      onPressed: () {
                        _controller.clear();
                        setState(() => _query = '');
                      },
                      icon: const Icon(Icons.close),
                    ),
            ),
          ),
        ),
        Expanded(
          child: Consumer<AudioProvider>(
            builder: (context, audioProvider, child) {
              final songs = audioProvider.songs.where((song) {
                if (_query.isEmpty) {
                  return true;
                }

                return song.title.toLowerCase().contains(_query) || song.artist.toLowerCase().contains(_query);
              }).toList(growable: false);

              if (songs.isEmpty) {
                return const Center(child: Text('No songs found'));
              }

              return ListView.builder(
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  final song = songs[index];
                  return SongTile(
                    song: song,
                    onTap: () => context.read<AudioProvider>().playSong(song, queue: songs),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
