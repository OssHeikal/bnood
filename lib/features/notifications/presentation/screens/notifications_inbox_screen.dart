import 'package:bnood/features/home/presentation/widgets/home_foundation_scope.dart';
import 'package:bnood/features/notifications/data/inbox_notification_record.dart';
import 'package:bnood/features/notifications/data/notifications_repository.dart';
import 'package:bnood/features/notifications/presentation/providers/notifications_inbox_paging.dart';
import 'package:bnood/features/notifications/presentation/providers/notifications_unread_provider.dart';
import 'package:bnood/features/notifications/presentation/widgets/notification_inbox_card.dart';
import 'package:bnood/features/notifications/presentation/widgets/notifications_inbox_loading_skeleton.dart';
import 'package:bnood/features/subscription/presentation/actions/paywall_launcher.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router.dart';
import '../../../../app/widgets/shell_nav_icon.dart';
import '../../../../core/account/account_context_providers.dart';
import '../../../../core/network/push/push_payload_routing.dart';
import '../../../../core/services/config/theme/app_colors.dart';
import '../../../../core/services/config/theme/app_size.dart';
import '../../../../core/shared/pagination/pagination.dart';
import '../../../../core/ui/resources/gen/assets.gen.dart';
import '../../../../core/ui/widgets/app_fallback.dart';
import '../../../../core/ui/widgets/app_toaster.dart';
import '../../../../core/ui/widgets/custom_app_bar.dart';

class NotificationsInboxScreen extends ConsumerStatefulWidget {
  const NotificationsInboxScreen({super.key});

  static const path = '/notifications';

  @override
  ConsumerState<NotificationsInboxScreen> createState() => _NotificationsInboxScreenState();
}

class _NotificationsInboxScreenState extends ConsumerState<NotificationsInboxScreen> {
  late final AppPagingController<InboxNotificationRecord> _pagingController;

  @override
  void initState() {
    super.initState();
    _pagingController = AppPagingController<InboxNotificationRecord>(
      fetchPage: ref.read(notificationsInboxPageFetcherProvider),
      pageSize: notificationsInboxPageSize,
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _markAllRead() async {
    final l10n = AppLocalizations.of(context);
    try {
      await ref.read(notificationsRepositoryProvider).markAllRead();
      refreshNotificationsUnreadCount(ref);
      _pagingController.refresh();
      if (!mounted) return;
      AppToaster.show(l10n.notificationsMarkAllReadDone, kind: ToastKind.success, layoutContext: context);
    } catch (_) {
      if (!mounted) return;
      AppToaster.show(l10n.homeLoadErrorTitle, kind: ToastKind.failure, layoutContext: context);
    }
  }

  Future<void> _onTap(InboxNotificationRecord item) async {
    final payload = <String, String>{
      'type': item.type,
      for (final entry in item.data.entries) entry.key: entry.value?.toString() ?? '',
    };
    final location = resolvePushNavigationLocation(payload);
    if (!mounted) return;

    if (item.isUnread) {
      try {
        await ref.read(notificationsRepositoryProvider).markRead(item.id);
        refreshNotificationsUnreadCount(ref);
      } catch (_) {}
    }

    if (!mounted) return;
    if (isPushSubscriptionLocation(location)) {
      await PaywallLauncher.present(context, ref);
      return;
    }
    ref.read(goRouterProvider).go(location);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    ref.listen(accountContextProvider, (_, _) {
      _pagingController.refresh();
      refreshNotificationsUnreadCount(ref);
    });

    return HomeFoundationScope(
      child: Scaffold(
        appBar: CustomAppBar(
          title: l10n.notificationsScreenTitle,
          // actions: [
          //   AppButton.text(
          //     text: l10n.notificationsMarkAllRead,
          //     onPressed: _markAllRead,
          //     textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(color: colors.primary),
          //   ),
          // ],
        ),
        body: AppPagedView<InboxNotificationRecord>(
          controller: _pagingController,
          layout: AppPagedLayout.sliverListSeparated,
          pullToRefresh: true,
          scrollPhysics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, item, _) => NotificationInboxCard(item: item, onTap: () => _onTap(item)),
          builders: AppPagedBuilders<InboxNotificationRecord>(
            firstPageProgress: (_, _) => const NotificationsInboxLoadingSkeleton(),
            empty: (context) => SizedBox(
              height: 280,
              child: Padding(
                padding: const EdgeInsets.all(AppSize.screenPadding),
                child: AppFallback.section(
                  leading: ShellNavIcon(
                    asset: Assets.icons.emptyInboxOutline,
                    color: colors.onSurfaceMuted,
                    size: AppSize.iconExtraLarge,
                  ),
                  title: l10n.notificationsInboxTitle,
                  description: l10n.notificationsInboxDescription,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
