import 'package:flutter/foundation.dart';

/// Cross-route gate handoff state (memory only, per process).
abstract final class AppGateSession {
  static String? postSplashDestination;

  @visibleForTesting
  static void resetForTest() {
    postSplashDestination = null;
  }
}
