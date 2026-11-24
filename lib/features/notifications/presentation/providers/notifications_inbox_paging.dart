import 'package:bnood/core/account/account_context_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bnood/core/shared/pagination/pagination.dart';
import 'package:bnood/features/notifications/data/inbox_notification_record.dart';
import 'package:bnood/features/notifications/data/notifications_repository.dart';

const notificationsInboxPageSize = 20;

final notificationsInboxPageFetcherProvider =
    Provider<PagedFetchCallback<InboxNotificationRecord>>((ref) {
      ref.watch(accountContextProvider);
      return ({required int page, required int pageSize}) async {
        final repo = ref.read(notificationsRepositoryProvider);
        final result = await repo.list(page: page, perPage: pageSize);
        return PagedFetchPage(
          items: result.items,
          hasMore: result.hasMore,
        );
      };
    });