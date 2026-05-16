# Chương 5 - Ứng dụng nghe nhạc offline đơn giản

Đây là một ứng dụng nghe nhạc offline đơn giản được xây dựng bằng Flutter. Ứng dụng cho phép người dùng phát nhạc từ thiết bị, quản lý danh sách phát và điều khiển trình phát nhạc với giao diện trực quan.

## Các chức năng chính

- Quản lý phát âm thanh trong Flutter
- Truy cập hệ thống file và lưu trữ cục bộ
- Điều khiển media và quản lý trạng thái âm thanh
- Tạo giao diện trình phát nhạc tùy chỉnh
- Phát nhạc nền khi ứng dụng chạy ở background
- Quản lý playlist
- Trích xuất thông tin bài hát
- Xử lý vòng đời của âm thanh

## Video demo app nghe nhạc

Video demo: [Link](https://drive.google.com/file/d/1pPdCVlPf3TBM6yHAdD3G6gB76xtx8aN6/view?usp=sharing)

## Thông tin sinh viên

- Họ tên: Hieu Hoang
- MSSV: 2224802010807

## Công nghệ/package sử dụng

- Flutter + Dart null-safety
- Provider: state management
- just_audio: phát nhạc foreground
- audio_service: media notification, media session và điều khiển phát nhạc từ thanh thông báo/lock screen trên Android
- on_audio_query: đọc danh sách bài hát trên thiết bị Android
- permission_handler: xin quyền Android
- file_picker: chọn file audio thủ công
- shared_preferences: lưu playlist/cài đặt
- audio_session: cấu hình audio session
- rxdart, path_provider: package hỗ trợ theo yêu cầu lab

## Cách thêm nhạc để test

1. Chép file `.mp3`, `.m4a`, `.wav` hoặc định dạng audio Android hỗ trợ vào thiết bị/emulator.
2. Cấp quyền đọc nhạc khi app hỏi quyền.
3. Nếu danh sách vẫn rỗng, vào Settings hoặc Home chọn "Chọn file nhạc thủ công".

## Quyền Android cần cấp

- `READ_MEDIA_AUDIO`: Android 13 trở lên.
- `READ_EXTERNAL_STORAGE`: Android 12 trở xuống.
- `POST_NOTIFICATIONS`: Android 13 trở lên để hiển thị thông báo media.
- `FOREGROUND_SERVICE` và `FOREGROUND_SERVICE_MEDIA_PLAYBACK`: chạy media playback service trên Android.
- `WAKE_LOCK`: hỗ trợ phát nhạc ổn định hơn khi màn hình khóa/ngủ.

## Phát nhạc nền và thông báo media

App dùng `audio_service` kết nối với `just_audio` hiện tại để hiển thị media notification khi phát nhạc trên Android. Notification hiển thị tên bài hát, ca sĩ, artwork nếu `on_audio_query` lấy được ảnh album và các nút Previous, Play/Pause, Next, Stop.

Trên Android 13 trở lên cần cấp quyền thông báo (`POST_NOTIFICATIONS`). Nếu không thấy notification, hãy vào App Settings và bật quyền Notifications. Nếu không lấy được ảnh album, Android sẽ dùng icon mặc định của app trong notification.

## Cấu trúc thư mục

```text
lib/
├── main.dart
├── models/
│   ├── song_model.dart
│   ├── playlist_model.dart
│   └── playback_state_model.dart
├── services/
│   ├── audio_player_service.dart
│   ├── background_audio_handler.dart
│   ├── permission_service.dart
│   ├── storage_service.dart
│   └── song_service.dart
├── providers/
│   ├── audio_provider.dart
│   └── playlist_provider.dart
├── screens/
│   ├── home_screen.dart
│   ├── now_playing_screen.dart
│   ├── playlist_screen.dart
│   ├── search_screen.dart
│   └── settings_screen.dart
├── widgets/
│   ├── song_tile.dart
│   ├── album_art_widget.dart
│   ├── mini_player.dart
│   ├── player_controls.dart
│   ├── progress_bar.dart
│   └── rotating_vinyl_art.dart
└── utils/
    ├── constants.dart
    └── duration_formatter.dart
```


