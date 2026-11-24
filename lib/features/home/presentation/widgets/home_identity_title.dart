import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/account/account_context_providers.dart';
import '../../../../core/account/account_office_providers.dart';
import '../../../../core/services/config/extensions/num_extensions.dart';
import '../../../../core/services/config/theme/app_colors.dart';
import '../../../../core/services/config/theme/app_size.dart';
import '../../../../core/domain/formatting/cairo_local_time.dart';
import 'package:bnood/features/subscription/data/subscription_colors.dart';
import 'package:bnood/features/subscription/data/subscription_riverpod.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/auth_paths.dart';
import 'package:bnood/features/auth/widgets/user_identity_avatar.dart';

class HomeIdentityTitle extends ConsumerWidget {
  const HomeIdentityTitle({
    super.key,
    required this.displayName,
    this.cairoNowOverride,
  });

  final String displayName;
  final DateTime? cairoNowOverride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = context.text;
    final colors = context.colors;
    final cairoNow = cairoNowOverride ?? cairoLocalNow();
    final greeting = cairoIsMorning(cairoNow)
        ? l10n.homeGreetingMorning
        : l10n.homeGreetingEvening;
    final entitlements = ref.watch(subscriptionEntitlementsProvider);
    final surfaces = ref.watch(subscriptionSurfacesEnabledProvider);
    final ctx = ref.watch(accountContextProvider);
    final office = ref.watch(selectedOfficeMembershipProvider);
    final personalLogo = ref.watch(
      authControllerProvider.select((s) => s.user?.logoUrl),
    );
    final avatar = accountHeaderAvatar(
      isPersonal: ctx.isPersonal,
      personalName: displayName,
      personalLogoUrl: personalLogo,
      office: office,
    );
    final premiumAvatar =
        ctx.isPersonal &&
        surfaces &&
        (entitlements?.showPremiumAvatar ?? false);

    return Row(
      children: [
        UserIdentityAvatar(
          displayName: avatar.displayName,
          imageUrl: avatar.imageUrl,
          size: AppSize.buttonHeight,
          semanticsLabel: l10n.userProfileTitle,
          onTap: avatar.opensProfile
              ? () => context.push(AuthPaths.profile)
              : null,
          fit: ctx.isPersonal ? BoxFit.contain : BoxFit.cover,
          backgroundColor: premiumAvatar
              ? entitlements!.premiumAvatarColor
              : null,
          foregroundColor: premiumAvatar ? SubscriptionColors.onViolet : null,
        ),
        AppSize.spaceMD.gap,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                greeting,
                style: text.caption.copyWith(color: colors.onSurfaceMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                displayName,
                style: text.pageTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
