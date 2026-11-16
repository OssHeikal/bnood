import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/device_tokens_api.dart';
import '../api/notification_settings_api.dart';
import '../storage/session_store.dart';
import 'push_permission_store.dart';
import 'push_repository.dart';

final notificationSettingsApiProvider = Provider<NotificationSettingsApi>((ref) {
  final store = ref.watch(sessionStoreProvider);
  final api = NotificationSettingsApi(sessionStore: store);
  ref.onDispose(api.close);
  return api;
});

final deviceTokensApiProvider = Provider<DeviceTokensApi>((ref) {
  final store = ref.watch(sessionStoreProvider);
  final api = DeviceTokensApi(sessionStore: store);
  ref.onDispose(api.close);
  return api;
});

final pushRepositoryProvider = Provider<PushRepository>((ref) {
  return PushRepository(
    ref.watch(notificationSettingsApiProvider),
    ref.watch(deviceTokensApiProvider),
  );
});

final pushPermissionStoreProvider = Provider<PushPermissionStore>((ref) => PushPermissionStore());