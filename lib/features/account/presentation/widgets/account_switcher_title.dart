import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/account/account_context_providers.dart';
import '../../../../core/account/account_office_providers.dart';
import '../../../../core/services/config/extensions/num_extensions.dart';
import '../../../../core/services/config/theme/app_size.dart';
import '../../../../core/services/config/theme/app_colors.dart';
import '../../../../core/ui/widgets/app_pressable.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/auth_paths.dart';
import 'package:bnood/features/auth/widgets/user_identity_avatar.dart';
import 'package:bnood/features/subscription/data/subscription_colors.dart';
import 'package:bnood/features/subscription/data/subscription_riverpod.dart';
import '../account_switcher_actions.dart';

class AccountSwitcherTitle extends ConsumerWidget {
  const AccountSwitcherTitle({
    super.key,
    required this.displayName,
    this.greeting,
    this.showAvatar = true,
  });

  final String displayName;
  final String? greeting;
  final bool showAvatar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = context.text;
    final colors = context.colors;
    final showSwitcher = ref.watch(accountSwitcherVisibleProvider);
    final ctx = ref.watch(accountContextProvider);
    final selectedOffice = ref.watch(selectedOfficeMembershipProvider);

    final title = accountDisplayTitle(
      isPersonal: ctx.isPersonal,
      personalName: displayName,
      selectedOffice: selectedOffice,
    );
    final resolvedTitle = title.isNotEmpty
        ? title
        : (ctx.isPersonal ? l10n.accountScopePersonal : l10n.homeAppName);

    final titleWidget = showSwitcher
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  resolvedTitle,
                  style: text.pageTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppSize.spaceXS.gap,
              Icon(Icons.expand_more, size: 18, color: colors.onSurfaceMuted),
            ],
          )
        : Text(
            resolvedTitle,
            style: text.pageTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );

    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (greeting != null)
          Text(
            greeting!,
            style: text.caption.copyWith(color: colors.onSurfaceMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        showSwitcher
            ? Semantics(
                button: true,
                label: l10n.accountSwitchTitle,
                child: AppPressable(
                  onPressed: () => showAccountSwitcherSheet(context, ref),
                  child: titleWidget,
                ),
              )
            : titleWidget,
      ],
    );

    if (!showAvatar || displayName.isEmpty) {
      return column;
    }

    final entitlements = ref.watch(subscriptionEntitlementsProvider);
    final surfaces = ref.watch(subscriptionSurfacesEnabledProvider);
    final premiumAvatar =
        surfaces && (entitlements?.showPremiumAvatar ?? false);
    final logoUrl = ref.watch(
      authControllerProvider.select((s) => s.user?.logoUrl),
    );

    return Row(
      children: [
        UserIdentityAvatar(
          displayName: displayName,
          imageUrl: logoUrl,
          size: AppSize.buttonHeight,
          semanticsLabel: l10n.userProfileTitle,
          onTap: () => context.push(AuthPaths.profile),
          backgroundColor: premiumAvatar
              ? entitlements!.premiumAvatarColor
              : null,
          foregroundColor: premiumAvatar ? SubscriptionColors.onViolet : null,
        ),
        AppSize.spaceMD.gap,
        Expanded(child: column),
      ],
    );
  }
}