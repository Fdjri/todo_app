import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/app_assets.dart';
import '../../injection_container.dart';

/// Singleton service for playing sound effects
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _enabled = true;

  bool get isEnabled => _enabled;

  static const String _soundPrefKey = 'notification_sound';

  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  String getSelectedSound() {
    try {
      final prefs = sl<SharedPreferences>();
      return prefs.getString(_soundPrefKey) ?? 'Soft Chime';
    } catch (_) {
      return 'Soft Chime';
    }
  }

  Future<void> setSelectedSound(String soundName) async {
    try {
      final prefs = sl<SharedPreferences>();
      await prefs.setString(_soundPrefKey, soundName);
    } catch (_) {}
  }

  String getSoundAssetPath(String soundName) {
    switch (soundName) {
      case 'Soft Chime':
        return AppAssets.soundSoftChime;
      case 'Gentle Bell':
        return AppAssets.soundGentleBell;
      case 'Sparkle':
        return AppAssets.soundSparkle;
      default:
        return '';
    }
  }

  Future<String> getCustomSoundPath() async {
    final appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}/custom_ringtone.wav';
  }

  Future<bool> hasCustomSound() async {
    try {
      final path = await getCustomSoundPath();
      return await File(path).exists();
    } catch (_) {
      return false;
    }
  }

  Future<void> playTaskComplete() async {
    await _play(AppAssets.soundTaskComplete);
  }

  Future<void> playLevelUp() async {
    await _play(AppAssets.soundLevelUp);
  }

  Future<void> playButtonTap() async {
    await _play(AppAssets.soundButtonTap);
  }

  Future<void> playDelete() async {
    await _play(AppAssets.soundDelete);
  }

  Future<void> playPreview(String soundName) async {
    if (!_enabled) return;
    try {
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.release);
      if (soundName == 'Custom Recording') {
        final path = await getCustomSoundPath();
        if (await File(path).exists()) {
          await _player.play(DeviceFileSource(path));
        }
      } else {
        final assetPath = getSoundAssetPath(soundName);
        if (assetPath.isNotEmpty) {
          await _player.play(AssetSource(assetPath));
        }
      }
    } catch (_) {}
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
  }

  Future<void> _play(String assetPath) async {
    if (!_enabled) return;
    try {
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.release);
      await _player.play(AssetSource(assetPath));
    } catch (_) {
      // Silently handle missing sound files
    }
  }

  void dispose() {
    _player.dispose();
  }
}
