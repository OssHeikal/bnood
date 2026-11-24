import 'package:flutter/foundation.dart';

/// Requests a full app-scope restart (new [ProviderContainer]) after account switch.
abstract final class AppRootRestart {
  static VoidCallback? _handler;

  @visibleForTesting
  static int debugRequestCount = 0;

  static void bind(VoidCallback handler) {
    _handler = handler;
  }

  static void unbind() {
    _handler = null;
  }

  static bool get isBound => _handler != null;

  static void request() {
    debugRequestCount++;
    final handler = _handler;
    if (handler != null) {
      handler();
      return;
    }
  }

  @visibleForTesting
  static void resetForTest() {
    debugRequestCount = 0;
    _handler = null;
  }
}