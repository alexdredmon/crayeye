// FILENAME: audio_manager.dart
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioManager {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<String> _audioFiles = ['loading1.wav', 'loading2.wav', 'loading3.wav', 'loading4.wav'];
  final ValueNotifier<bool> _isAudioEnabledNotifier = ValueNotifier<bool>(true);

  AudioManager() {
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.setVolume(20.0);
  }

  Future<void> playRandomAudio() async {
    if (_isAudioEnabledNotifier.value) {
      final randomIndex = Random().nextInt(_audioFiles.length);
      final audioFile = _audioFiles[randomIndex];
      await _audioPlayer.play(AssetSource(audioFile));
    }
  }

  Future<void> stopAudio() async {
    await _audioPlayer.stop();
  }

  void enableAudio() {
    _isAudioEnabledNotifier.value = true;
  }

  void disableAudio() {
    _isAudioEnabledNotifier.value = false;
  }

  ValueNotifier<bool> get isAudioEnabledNotifier => _isAudioEnabledNotifier;

  void dispose() {
    _audioPlayer.dispose();
  }
}
// eof
