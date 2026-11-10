import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/formatting/display_digits.dart';
import '../../../core/resources/gen/assets.gen.dart';
import '../../../core/subscription/app_subscription.dart';
import '../../../core/subscription/subscription_colors.dart';
import '../../../core/subscription/subscription_riverpod.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../subscription/paywall_launcher.dart';

class ProfileSubscriptionCard extends ConsumerWidget {
  const ProfileSubscriptionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(subscriptionProvider);
    final snap = async.valueOrNull;
    if (snap == null || !snap.shouldShowProfileSubscriptionCard) {
      return const SizedBox.shrink();
    }

    final ent = snap.entitlements;
    final isActivePremium = ent.isPremium && !ent.isExpiredPremium;
    final text = context.text;
    final muted = context.colors.onSurfaceMuted;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSize.radiusSM),
        border: Border.all(color: SubscriptionColors.violet.withValues(alpha: 0.22)),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [SubscriptionColors.paywallGradientTop, SubscriptionColors.violetSoft],
          stops: [0, 1],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSize.spaceMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              spacing: AppSize.spaceSM,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: ShapeDecoration(
                    color: SubscriptionColors.violet,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSize.radiusSM)),
                  ),
                  child: Assets.icons.crownOutline.svg(width: 24, height: 24),
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.profileSubscriptionSection, style: text.body, textAlign: TextAlign.start),
                      if (isActivePremium)
                        Text(ent.packageName, style: text.bodyEmphasis.copyWith(color: SubscriptionColors.violetDark))
                      else
                        Text(l10n.profileSubscriptionFreeBlurb, style: text.body.copyWith(color: muted)),
                    ],
                  ),
                ),
                if (isActivePremium)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: _premiumBody(context, l10n, ent, text, muted),
                  ),
              ],
            ),
            AppSize.spaceSM.gap,
            if (!isActivePremium) ..._freeBody(context, l10n, snap, text, muted),
          ],
        ),
      ),
    );
  }

  List<Widget> _premiumBody(
    BuildContext context,
    AppLocalizations l10n,
    AppSubscriptionEntitlements ent,
    AppText text,
    Color muted,
  ) {
    final expiry = ent.expiresAt;
    final days = ent.daysRemaining;
    return [
      if (expiry != null)
        Text(l10n.profileSubscriptionRenewsOn(_formatDate(expiry)), style: text.caption.copyWith(color: muted)),
      if (days != null) Text(l10n.profileSubscriptionDaysRemaining(days), style: text.caption.copyWith(color: muted)),
    ];
  }

  List<Widget> _freeBody(
    BuildContext context,
    AppLocalizations l10n,
    AppSubscriptionSnapshot snap,
    AppText text,
    Color muted,
  ) {
    final benefits = snap.paywall?.benefits ?? const <String>[];
    return [
      if (benefits.isNotEmpty) ...[
        AppSize.spaceSM.gap,
        for (final b in benefits.take(3))
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text('• $b', style: text.caption, textAlign: TextAlign.start),
          ),
      ],
      AppSize.spaceMD.gap,
      AppButton.primary(
        text: l10n.profileSubscriptionSubscribeCta,
        backgroundColor: SubscriptionColors.violet,
        onPressed: () => PaywallLauncher.present(context),
      ),
    ];
  }

  String _formatDate(DateTime date) {
    final y = date.year;
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return DisplayDigits.toWesternDigits('$y-$m-$d');
  }
}
