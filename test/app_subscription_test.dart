import 'package:bnood/core/subscription/app_subscription.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppSubscriptionSnapshot', () {
    test('showSurfaces requires paywall flag and entitlements flag', () {
      final snap = AppSubscriptionSnapshot.fromDataJson({
        'paywall_enabled': true,
        'entitlements': {
          'show_paywall_surfaces': false,
          'is_premium': false,
        },
      });
      expect(snap.showSurfaces, isFalse);

      final on = AppSubscriptionSnapshot.fromDataJson({
        'paywall_enabled': true,
        'entitlements': {'show_paywall_surfaces': true},
      });
      expect(on.showSurfaces, isTrue);
    });

    test('yearly plan derives monthly equivalent from total', () {
      final plan = AppPaywallPlan.fromJson({
        'id': 'yearly',
        'label': 'Yearly',
        'total_minor': 299000,
      });
      expect(plan.monthlyEquivalentMinor, 299000 ~/ 12);
    });
  });

  group('AppSubscriptionEntitlements', () {
    test('showPremiumAvatar only when premium and not expired', () {
      final active = AppSubscriptionEntitlements.fromJson({
        'is_premium': true,
        'is_expired_premium': false,
      });
      expect(active.showPremiumAvatar, isTrue);

      final expired = AppSubscriptionEntitlements.fromJson({
        'is_premium': true,
        'is_expired_premium': true,
      });
      expect(expired.showPremiumAvatar, isFalse);
    });
  });
}
