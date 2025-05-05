import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SoundService extends ChangeNotifier {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;

  static final AudioPlayer _player = AudioPlayer();
  double _volume = 1.0;
  DateTime? _lastPlayTime;

  SoundService._internal();

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _volume = prefs.getDouble('soundVolume') ?? 1.0;

      await _player.setVolume(_volume);

      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.macOS ||
              defaultTargetPlatform == TargetPlatform.windows ||
              defaultTargetPlatform == TargetPlatform.linux)) {
        await _player.setPlayerMode(PlayerMode.lowLatency);
      }
    } catch (e) {
      _log("SoundService initialize error: $e");
    }
  }

  Future<double> getVolume() async {
    final prefs = await SharedPreferences.getInstance();
    _volume = prefs.getDouble('soundVolume') ?? 1.0;
    return _volume;
  }

  Future<void> setVolume(double volume) async {
    try {
      _volume = volume.clamp(0.0, 1.0);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('soundVolume', _volume);
      await _player.setVolume(_volume);
      notifyListeners();
    } catch (e) {
      _log("Error setting volume: $e");
    }
  }

  Future<void> toggleMute() async {
    final newVolume = _volume == 0.0 ? 1.0 : 0.0;
    await setVolume(newVolume);
  }

  Future<void> playSound(String assetPath) async {
    try {
      if (!_canPlayAgain()) return;

      await _player.stop();

      if (kIsWeb) {
        // For web, ensure the asset is directly accessible without 'assets/' prefix
        await _player.setSourceUrl(assetPath);
      } else {
        await _player.setSourceAsset(assetPath);
      }

      await _player.setVolume(_volume);
      await _player.resume();
    } catch (e) {
      _log("Error playing sound ($assetPath): $e");
    }
  }

  Future<void> stopSound() async {
    try {
      await _player.stop();
    } catch (e) {
      _log("Error stopping sound: $e");
    }
  }

  Future<void> pauseSound() async {
    try {
      await _player.pause();
    } catch (e) {
      _log("Error pausing sound: $e");
    }
  }

  Future<void> resumeSound() async {
    try {
      await _player.resume();
    } catch (e) {
      _log("Error resuming sound: $e");
    }
  }

  // Sound Shortcuts
  Future<void> playUserMessageSound() async =>
      playSound('assets/sounds/chatbot/user_message.mp3');
  Future<void> playChatbotTypingSound() async =>
      playSound('assets/sounds/chatbot/chatbot_typing.mp3');
  Future<void> playChatbotResponseSound() async =>
      playSound('assets/sounds/chatbot/chatbot_response.mp3');

  Future<void> playNotificationSound() async =>
      playSound('assets/sounds/notifications/new_message.mp3');
  Future<void> playErrorSound() async =>
      playSound('assets/sounds/notifications/error.mp3');
  Future<void> playSuccessSound() async =>
      playSound('assets/sounds/notifications/success.mp3');
  Future<void> playWarningSound() async =>
      playSound('assets/sounds/notifications/warning.mp3');

  Future<void> playBackPressSound() async =>
      playSound('assets/sounds/ui_sounds/back_press.mp3');
  Future<void> playButtonClickSound() async =>
      playSound('assets/sounds/ui_sounds/button_click.mp3');
  Future<void> playClickSound() async =>
      playSound('assets/sounds/ui_sounds/click.mp3');
  Future<void> playPopSound() async =>
      playSound('assets/sounds/ui_sounds/pop.mp3');
  Future<void> playConfirmSound() async =>
      playSound('assets/sounds/ui_sounds/confirm.mp3');
  Future<void> playNavigationTapSound() async =>
      playSound('assets/sounds/ui_sounds/navigation_tap.mp3');
  Future<void> playSwipeSound() async =>
      playSound('assets/sounds/ui_sounds/swipe.mp3');
  Future<void> playHoverSound() async =>
      playSound('assets/sounds/ui_sounds/hover.mp3');

  // Generic feedback sounds
  Future<void> playFeedback(String soundFile) async {
    if (soundFile == 'success.wav') {
      await playSuccessSound();
    } else if (soundFile == 'error.wav') {
      await playErrorSound();
    } else {
      _log("Invalid sound file: $soundFile");
    }
  }

  // Internal timing logic
  bool _canPlayAgain([Duration cooldown = const Duration(milliseconds: 100)]) {
    final now = DateTime.now();
    if (_lastPlayTime == null || now.difference(_lastPlayTime!) > cooldown) {
      _lastPlayTime = now;
      return true;
    }
    return false;
  }

  void _log(String message) {
    if (kDebugMode) debugPrint(message);
  }
}
