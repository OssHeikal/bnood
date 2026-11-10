import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/content/content_page_record.dart';
import '../../core/resources/gen/assets.gen.dart';
import '../../core/subscription/subscription_colors.dart';
import '../../core/widgets/grouped_list_divider.dart';
import '../auth/auth_controller.dart';
import '../auth/auth_paths.dart';
import '../auth/auth_session_actions.dart';
import '../subscription/paywall_launcher.dart';
import 'settings_list_widgets.dart';

class AppMenuBody extends ConsumerWidget {
  const AppMenuBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final isAuthenticated = ref.watch(authControllerProvider).isAuthenticated;
    final brandChip = colors.primary.withValues(alpha: 0.12);
    final subscriptionChip = SubscriptionColors.violet.withValues(alpha: 0.14);

    final topRows = <Widget>[
      SettingsNavRow(
        label: l10n.authAccountSection,
        icon: Assets.icons.profileCircleOutline,
        chipBackground: brandChip,
        iconColor: colors.primary,
        onTap: () {
          if (isAuthenticated) {
            context.push(AuthPaths.profile);
          } else {
            context.push(AuthPaths.login);
          }
        },
      ),
      if (isAuthenticated)
        SettingsNavRow(
          label: l10n.profileSubscriptionSection,
          icon: Assets.icons.crownOutline,
          chipBackground: subscriptionChip,
          iconColor: SubscriptionColors.violet,
          onTap: () => PaywallLauncher.present(context, ref),
        ),
      SettingsNavRow(
        label: l10n.settingsTitle,
        icon: Assets.icons.settingsOutline,
        chipBackground: brandChip,
        iconColor: colors.primary,
        onTap: () => context.push(AuthPaths.preferences),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsListSection(
          title: null,
          dividerKind: GroupedListDividerKind.insetStart,
          children: topRows,
        ),
        AppSize.spaceXL.gap,
        SettingsListSection(
          title: l10n.settingsContentSection,
          dividerKind: GroupedListDividerKind.insetStart,
          children: [
            SettingsNavRow(
              label: l10n.settingsContentAbout,
              icon: Assets.icons.infoCircleOutline,
              chipBackground: brandChip,
              iconColor: colors.primary,
              onTap: () => context.push(ContentPaths.about),
            ),
            SettingsNavRow(
              label: l10n.settingsContentTerms,
              icon: Assets.icons.googleDocOutline,
              chipBackground: brandChip,
              iconColor: colors.primary,
              onTap: () => context.push(ContentPaths.terms),
            ),
            SettingsNavRow(
              label: l10n.settingsContentPrivacy,
              icon: Assets.icons.shield02Outline,
              chipBackground: brandChip,
              iconColor: colors.primary,
              onTap: () => context.push(ContentPaths.privacy),
            ),
            SettingsNavRow(
              label: l10n.settingsContentCancellation,
              icon: Assets.icons.fileRemoveOutline,
              chipBackground: brandChip,
              iconColor: colors.primary,
              onTap: () => context.push(ContentPaths.cancellation),
            ),
          ],
        ),
        if (isAuthenticated) ...[
          AppSize.spaceXL.gap,
          SettingsListSection(
            title: null,
            dividerKind: GroupedListDividerKind.insetStart,
            children: [
              SettingsDestructiveRow(
                label: l10n.authSignOut,
                icon: Assets.icons.logout02Outline,
                onTap: () => confirmLogout(context, ref),
              ),
            ],
          ),
          AppSize.spaceMD.gap,
        ],
      ],
    );
  }
}
