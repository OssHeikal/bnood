import 'package:bnood/core/account/account_context_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bnood/features/notifications/data/notifications_repository.dart';

final notificationsUnreadCountProvider = FutureProvider<int>((ref) async {
  ref.watch(accountContextProvider);
  return ref.read(notificationsRepositoryProvider).unreadCount();
});

void refreshNotificationsUnreadCount(WidgetRef ref) {
  ref.invalidate(notificationsUnreadCountProvider);
}