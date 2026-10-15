import 'package:flame_audio/flame_audio.dart';

class AudioService {
  AudioService._();

  static bool _ready = false;
  static bool musicEnabled = true;
  static bool sfxEnabled = true;

  static Future<void> initialize() async {
    if (_ready) return;

    try {
      await FlameAudio.audioCache.loadAll([
        'flap.wav',
        'coin.wav',
        'score.wav',
        'hit.wav',
        'music.wav',
      ]);
      await FlameAudio.bgm.initialize();
      _ready = true;
    } catch (_) {
      // Audio is optional; the game remains playable if the platform audio
      // backend is unavailable.
    }
  }

  static Future<void> startMusic() async {
    if (!_ready || !musicEnabled) return;
    try {
      await FlameAudio.bgm.play('music.wav', volume: 0.16);
    } catch (_) {}
  }

  static Future<void> stopMusic() async {
    if (!_ready) return;
    try {
      await FlameAudio.bgm.stop();
    } catch (_) {}
  }

  static Future<void> pauseMusic() async {
    if (!_ready) return;
    try {
      await FlameAudio.bgm.pause();
    } catch (_) {}
  }

  static Future<void> resumeMusic() async {
    if (!_ready || !musicEnabled) return;
    try {
      await FlameAudio.bgm.resume();
    } catch (_) {}
  }

  static Future<void> playSfx(String file) async {
    if (!_ready || !sfxEnabled) return;
    try {
      await FlameAudio.play(file, volume: 0.8);
    } catch (_) {}
  }
}
