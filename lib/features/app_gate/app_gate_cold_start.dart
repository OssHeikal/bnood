import 'package:flutter/foundation.dart';

/// Cold-start-only optional update (not shown again on resume in same process).
abstract final class AppGateColdStart {
  static var splashHandoffDone = false;
  static var optionalDismissed = false;

  @visibleForTesting
  static void resetForTest() {
    splashHandoffDone = false;
    optionalDismissed = false;
  }
}
