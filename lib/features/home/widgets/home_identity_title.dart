import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/formatting/cairo_local_time.dart';
import '../../../core/subscription/subscription_colors.dart';
import '../../../core/subscription/subscription_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/auth_controller.dart';
import '../../auth/auth_paths.dart';
import '../../auth/widgets/user_identity_avatar.dart';

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
    final greeting = cairoIsMorning(cairoNow) ? l10n.homeGreetingMorning : l10n.homeGreetingEvening;
    final entitlements = ref.watch(subscriptionEntitlementsProvider);
    final surfaces = ref.watch(subscriptionSurfacesEnabledProvider);
    final premiumAvatar = surfaces && (entitlements?.showPremiumAvatar ?? false);
    final logoUrl = ref.watch(authControllerProvider.select((s) => s.user?.logoUrl));

    return Row(
      children: [
        UserIdentityAvatar(
          displayName: displayName,
          imageUrl: logoUrl,
          size: AppSize.buttonHeight,
          semanticsLabel: l10n.userProfileTitle,
          onTap: () => context.push(AuthPaths.profile),
          backgroundColor: premiumAvatar ? entitlements!.premiumAvatarColor : null,
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
