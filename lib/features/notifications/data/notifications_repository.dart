import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bnood/core/data/storage/session_store.dart';
import 'package:bnood/features/notifications/data/inbox_notification_record.dart';
import 'package:bnood/features/notifications/data/notifications_api.dart';

final notificationsApiProvider = Provider<NotificationsApi>((ref) {
  final store = ref.watch(sessionStoreProvider);
  final api = NotificationsApi(sessionStore: store);
  ref.onDispose(api.close);
  return api;
});

final notificationsRepositoryProvider = Provider<NotificationsRepository>((
  ref,
) {
  return NotificationsRepository(ref.watch(notificationsApiProvider));
});

class NotificationsRepository {
  const NotificationsRepository(this._api);

  final NotificationsApi _api;

  Future<InboxNotificationsPage> list({
    required int page,
    required int perPage,
  }) => _api.list(page: page, perPage: perPage);

  Future<int> unreadCount() => _api.unreadCount();

  Future<InboxNotificationRecord> markRead(String id) => _api.markRead(id);

  Future<int> markAllRead() => _api.markAllRead();
}