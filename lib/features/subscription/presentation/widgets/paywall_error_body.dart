import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import 'package:bnood/features/subscription/data/subscription_colors.dart';
import '../../../../core/widgets/buttons/app_button.dart';

class PaywallErrorBody extends StatelessWidget {
  const PaywallErrorBody({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(
              color: SubscriptionColors.violetSoft,
              shape: BoxShape.circle,
            ),
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: Text(
                  '!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: SubscriptionColors.violet,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.paywallLoadFailedTitle,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            l10n.paywallLoadFailedBody,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              height: 1.55,
              color: Color(0xFF6D6676),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 220,
            child: AppButton.primary(
              text: l10n.retry,
              backgroundColor: SubscriptionColors.violet,
              onPressed: onRetry,
            ),
          ),
        ],
      ),
    );
  }
}
