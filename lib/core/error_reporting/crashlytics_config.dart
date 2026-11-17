import '../push/push_platform.dart';

abstract final class CrashlyticsConfig {
  /// Firebase is initialized on the same platforms as FCM.
  static bool get isSupported => pushMessagingSupported;
}