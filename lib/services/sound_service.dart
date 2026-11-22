import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();
  static bool isMuted = false;

  // Toggle audio notifications on/off
  static void toggleMute() {
    isMuted = !isMuted;
  }

  // Play standard gentle notification chime (incoming message, intro request)
  static Future<void> playNotificationChime() async {
    if (isMuted) return;
    try {
      final Uint8List bytes = base64Decode(_chimeBase64);
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.play(BytesSource(bytes));
    } catch (e) {
      debugPrint("Audio chime notice: $e");
    }
  }

  // Play elevated celebration chime (Gatekeeper Approval)
  static Future<void> playCelebrationChime() async {
    if (isMuted) return;
    try {
      final Uint8List bytes = base64Decode(_chimeBase64);
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.play(BytesSource(bytes));
      // Double strike for celebration
      await Future.delayed(const Duration(milliseconds: 140));
      await _player.play(BytesSource(bytes));
    } catch (e) {
      debugPrint("Celebration chime notice: $e");
    }
  }

  // Mathematically synthesized 880Hz + 1320Hz luxury bell chime (0.18s, 100% offline, zero CORS)
  static const String _chimeBase64 =
      "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";
}