import 'package:audioplayers/audioplayers.dart';
import '../constants/app_assets.dart';

/// Singleton service for playing sound effects
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _enabled = true;

  bool get isEnabled => _enabled;

  void setEnabled(bool enabled) {
    _enabled = enabled;
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

  Future<void> _play(String assetPath) async {
    if (!_enabled) return;
    try {
      await _player.stop();
      await _player.play(AssetSource(assetPath));
    } catch (_) {
      // Silently handle missing sound files
    }
  }

  void dispose() {
    _player.dispose();
  }
}
