import '../../features/auth/auth_paths.dart';

/// Backend FCM data payload `type` values (see bnood-admin `PushNotificationType`).
abstract final class PushPayloadType {
  static const lowBalance = 'low_balance';
  static const subscriptionExpiry = 'subscription_expiry';
  static const broadcast = 'broadcast';
  static const adminBroadcast = 'admin_broadcast';
}

/// Admin broadcast `target` values (future broadcasts).
abstract final class PushBroadcastTarget {
  static const app = 'app';
  static const subscription = 'subscription';
}

/// Maps FCM data to a go_router location. Unknown shapes fall back to home.
String resolvePushNavigationLocation(Map<String, String> data) {
  final type = data['type']?.trim();
  if (type == PushPayloadType.lowBalance) {
    final clientId = data['client_id']?.trim();
    if (clientId != null && clientId.isNotEmpty) {
      return '/clients/$clientId';
    }
    return authenticatedHomeForPath();
  }
  if (type == PushPayloadType.subscriptionExpiry) {
    return AuthPaths.profile;
  }
  if (type == PushPayloadType.broadcast || type == PushPayloadType.adminBroadcast) {
    return _targetLocation(data['target']?.trim());
  }
  final target = data['target']?.trim();
  if (target != null && target.isNotEmpty) {
    return _targetLocation(target);
  }
  return authenticatedHomeForPath();
}

String _targetLocation(String? target) {
  if (target == PushBroadcastTarget.subscription) return AuthPaths.profile;
  return authenticatedHomeForPath();
}

String authenticatedHomeForPath() => '/home';