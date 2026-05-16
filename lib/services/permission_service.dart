import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> hasAudioPermission() async {
    final audioStatus = await Permission.audio.status;
    if (audioStatus.isGranted || audioStatus.isLimited) {
      return true;
    }

    final storageStatus = await Permission.storage.status;
    return storageStatus.isGranted || storageStatus.isLimited;
  }

  Future<bool> requestAudioPermission() async {
    final audioStatus = await Permission.audio.request();
    if (audioStatus.isGranted || audioStatus.isLimited) {
      return true;
    }

    final storageStatus = await Permission.storage.request();
    return storageStatus.isGranted || storageStatus.isLimited;
  }

  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted || status.isLimited;
  }

  Future<bool> isAudioPermissionPermanentlyDenied() async {
    final audioStatus = await Permission.audio.status;
    final storageStatus = await Permission.storage.status;
    return audioStatus.isPermanentlyDenied || storageStatus.isPermanentlyDenied;
  }

  Future<bool> openSystemSettings() {
    return openAppSettings();
  }
}
