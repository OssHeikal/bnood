import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/account/account_office_providers.dart';
import '../../../../core/utils/safe_external_url.dart';
import 'package:bnood/features/account/presentation/account_switcher_actions.dart';
import '../../../../core/services/config/theme/app_colors.dart';
import '../../../../core/services/config/theme/app_size.dart';
import 'package:bnood/features/content/data/content_page_record.dart';
import '../../../../core/ui/resources/gen/assets.gen.dart';
import 'package:bnood/features/subscription/data/subscription_colors.dart';
import 'package:bnood/features/subscription/data/subscription_riverpod.dart';
import '../../../../core/ui/widgets/grouped_list_divider.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/auth_paths.dart';
import 'package:bnood/features/auth/auth_session_actions.dart';
import 'package:bnood/features/subscription/presentation/actions/paywall_launcher.dart';
import 'package:bnood/features/settings/presentation/widgets/settings_list_widgets.dart';

class AppMenuBody extends ConsumerWidget {
  const AppMenuBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final isAuthenticated = ref.watch(authControllerProvider).isAuthenticated;
    final showSubscription =
        isAuthenticated && ref.watch(subscriptionSurfacesEnabledProvider);
    final showAccountSwitcher =
        isAuthenticated && ref.watch(accountSwitcherVisibleProvider);
    final dashboardLaunch = ref.watch(officeDashboardLaunchProvider);
    final brandChip = colors.primary.withValues(alpha: 0.12);
    final subscriptionChip = SubscriptionColors.violet.withValues(alpha: 0.14);

    final moduleRows = <Widget>[
      SettingsNavRow(
        label: l10n.navClients,
        icon: Assets.icons.clientsOutline,
        chipBackground: brandChip,
        iconColor: colors.primary,
        onTap: () => context.push('/clients'),
      ),
      SettingsNavRow(
        label: l10n.navItems,
        icon: Assets.icons.itemsLayersOutline,
        chipBackground: brandChip,
        iconColor: colors.primary,
        onTap: () => context.push('/items'),
      ),
    ];

    final topRows = <Widget>[
      SettingsNavRow(
        label: l10n.userProfileTitle,
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
      if (showSubscription)
        SettingsNavRow(
          label: l10n.profileSubscriptionSection,
          icon: Assets.icons.crownOutline,
          chipBackground: subscriptionChip,
          iconColor: SubscriptionColors.violet,
          onTap: () => PaywallLauncher.presentForContext(context, ref),
        ),
      SettingsNavRow(
        label: l10n.settingsTitle,
        icon: Assets.icons.settingsOutline,
        chipBackground: brandChip,
        iconColor: colors.primary,
        onTap: () => context.push(AuthPaths.preferences),
      ),
      if (dashboardLaunch.show && dashboardLaunch.url != null)
        SettingsNavRow(
          label: l10n.officeOpenDashboard,
          icon: Assets.icons.dashboardOutline,
          chipBackground: brandChip,
          iconColor: colors.primary,
          onTap: () => launchAllowedUrl(dashboardLaunch.url!),
        ),
      if (isAuthenticated)
        SettingsNavRow(
          label: l10n.notificationSettingsTitle,
          icon: Assets.icons.notification,
          chipBackground: brandChip,
          iconColor: colors.primary,
          onTap: () => context.push(AuthPaths.notifications),
        ),
    ];

    const sectionGap = SizedBox(height: AppSize.spaceXL);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsListSection(
          title: l10n.navModulesSection,
          dividerKind: GroupedListDividerKind.insetStart,
          children: moduleRows,
        ),
        sectionGap,
        SettingsListSection(
          title: l10n.authAccountSection,
          dividerKind: GroupedListDividerKind.insetStart,
          children: topRows,
        ),
        sectionGap,
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
          sectionGap,
          SettingsListSection(
            title: null,
            dividerKind: GroupedListDividerKind.insetStart,
            children: [
              if (showAccountSwitcher)
                SettingsNavRow(
                  label: l10n.accountSwitchMenu,
                  icon: Assets.icons.profileCircleOutline,
                  chipBackground: brandChip,
                  iconColor: colors.primary,
                  onTap: () => showAccountSwitcherSheet(context, ref),
                ),
              SettingsDestructiveRow(
                label: l10n.authSignOut,
                icon: Assets.icons.logout02Outline,
                onTap: () => confirmLogout(context, ref),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
