import 'package:flutter/services.dart';

class HapticService {
  static void medium() {
    try { HapticFeedback.mediumImpact(); } catch (_) {}
  }

  static void heavy() {
    try { HapticFeedback.heavyImpact(); } catch (_) {}
  }

  static void success() {
    try { HapticFeedback.mediumImpact(); } catch (_) {}
  }

  static void error() {
    try { HapticFeedback.vibrate(); } catch (_) {}
  }
}
