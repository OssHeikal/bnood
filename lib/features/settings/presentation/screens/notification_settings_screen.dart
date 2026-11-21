import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/config/theme/app_size.dart';
import '../../../../core/ui/layout/bnood_list_canvas.dart';
import '../../../../core/ui/widgets/app_fallback.dart';
import '../../../../core/ui/widgets/custom_app_bar.dart';
import '../../../../core/ui/widgets/skeleton/async_value_body.dart';
import 'package:bnood/features/home/presentation/widgets/home_foundation_scope.dart';
import 'package:bnood/features/settings/presentation/widgets/notification_settings_body.dart';
import 'package:bnood/features/settings/data/notification_settings_provider.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(notificationSettingsProvider);

    return HomeFoundationScope(
      child: Scaffold(
        appBar: CustomAppBar(title: l10n.notificationSettingsTitle),
        body: BnoodListCanvas(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: AppSize.spaceMD),
            child: AsyncValueBody(
              value: settings,
              loadingPlaceholder: const SizedBox(height: 120),
              error: (e, _) => AppFallback.section(
                icon: Icons.notifications_none_outlined,
                title: l10n.homeLoadErrorTitle,
                description: e.toString(),
                actions: [
                  AppFallbackAction(
                    label: l10n.retry,
                    onPressed: () =>
                        ref.invalidate(notificationSettingsProvider),
                    role: AppFallbackActionRole.tertiary,
                  ),
                ],
              ),
              data: (record) => NotificationSettingsBody(settings: record),
            ),
          ),
        ),
      ),
    );
  }
}
