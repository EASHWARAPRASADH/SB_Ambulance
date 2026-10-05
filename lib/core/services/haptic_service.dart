import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class HapticService {
  bool _canVibrateChecked = false;
  bool _hasCustomVibrationSupport = false;

  Future<void> _initCheck() async {
    if (_canVibrateChecked || kIsWeb) return;
    try {
      final hasVibrator = await Vibration.hasVibrator();
      final hasCustom = await Vibration.hasCustomVibrationsSupport();
      _hasCustomVibrationSupport = hasVibrator && hasCustom;
    } catch (_) {
      _hasCustomVibrationSupport = false;
    } finally {
      _canVibrateChecked = true;
    }
  }

  /// Subtle click during touch down
  Future<void> touchDown() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }

  /// Periodic tick during hold-to-activate (accelerating sensation)
  Future<void> tickProgress() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Strong tactile impact when the hold threshold is reached
  Future<void> triggerConfirmed() async {
    await _initCheck();
    try {
      if (_hasCustomVibrationSupport) {
        await Vibration.vibrate(duration: 400, amplitude: 255);
      } else {
        await HapticFeedback.heavyImpact();
      }
    } catch (_) {
      try {
        await HapticFeedback.heavyImpact();
      } catch (_) {}
    }
  }

  /// Distinct success rhythm
  Future<void> successPattern() async {
    await _initCheck();
    try {
      if (_hasCustomVibrationSupport) {
        await Vibration.vibrate(
          pattern: [0, 100, 80, 150],
          intensities: [0, 180, 0, 255],
        );
      } else {
        await HapticFeedback.mediumImpact();
      }
    } catch (_) {
      try {
        await HapticFeedback.mediumImpact();
      } catch (_) {}
    }
  }

  /// Distinct failure buzz
  Future<void> failurePattern() async {
    await _initCheck();
    try {
      if (_hasCustomVibrationSupport) {
        await Vibration.vibrate(
          pattern: [0, 200, 100, 300],
          intensities: [0, 255, 0, 255],
        );
      } else {
        await HapticFeedback.heavyImpact();
      }
    } catch (_) {
      try {
        await HapticFeedback.heavyImpact();
      } catch (_) {}
    }
  }
}
