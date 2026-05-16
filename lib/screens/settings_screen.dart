import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/audio_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const ListTile(
          leading: Icon(Icons.info_outline),
          title: Text(AppConstants.appName),
          subtitle: Text('Simple Offline Music Player'),
        ),
        const Divider(),
        const ListTile(
          leading: Icon(Icons.library_music),
          title: Text('Hướng dẫn cấp quyền'),
          subtitle: Text(
            'Android 13+ cần quyền READ_MEDIA_AUDIO. Android thấp hơn cần READ_EXTERNAL_STORAGE. '
            'Nếu đã từ chối vĩnh viễn, hãy mở cài đặt app và bật quyền Music/Audio.',
          ),
        ),
        ListTile(
          leading: const Icon(Icons.settings_applications),
          title: const Text('Mở app settings'),
          onTap: context.read<AudioProvider>().openAppSettings,
        ),
        ListTile(
          leading: const Icon(Icons.audio_file),
          title: const Text('Chọn file nhạc thủ công'),
          subtitle: const Text('Dùng khi thiết bị không quét thấy bài hát.'),
          onTap: context.read<AudioProvider>().pickAudioFiles,
        ),
        const Divider(),
        Consumer<AudioProvider>(
          builder: (context, audioProvider, child) {
            return ListTile(
              leading: const Icon(Icons.volume_up),
              title: const Text('Volume'),
              subtitle: Slider(
                value: audioProvider.volume,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: audioProvider.setVolume,
              ),
            );
          },
        ),
      ],
    );
  }
}
