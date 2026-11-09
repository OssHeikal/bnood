import 'package:flutter/foundation.dart';

/// Cold-start `/splash` route runs once per process; survives theme/locale/router rebuilds.
abstract final class AppSplashSession {
  static var completed = false;

  @visibleForTesting
  static void resetForTest() => completed = false;
}
