import 'package:bnood/core/subscription/app_subscription.dart';
import 'package:bnood/core/subscription/subscription_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Live API shape at MINOR_PER_MAJOR = 100 (29900 = EGP 299, 299900 = EGP 2990).
Map<String, dynamic> liveShapePayload() => {
      'paywall_enabled': true,
      'entitlements': {
        'package_slug': 'free',
        'package_name': 'Free',
        'is_premium': false,
        'premium_avatar': false,
        'subscription_status': null,
        'show_paywall_surfaces': true,
        'can_create_active_project': true,
        'active_projects_count': 1,
        'active_project_cap': 1,
      },
      'paywall': {
        'title': 'كمّل شغلك من غير حدود',
        'subtitle': 'مشاريع نشطة بلا حد مع Premium',
        'benefits': ['مشاريع نشطة بلا حد'],
        'cta_subscribe_label': 'اشترك في Premium',
        'cta_continue_free_label': 'الاستمرار مجاناً',
        'legal': 'بالاشتراك، أنت توافق على الشروط.',
        'plans': {
          'slug': 'premium',
          'name': 'Premium',
          'price_monthly_minor': 29900,
          'price_yearly_minor': 299000,
          'price_monthly_discounted_minor': null,
          'price_yearly_discounted_minor': null,
          'yearly_monthly_equivalent_minor': 24917,
          'yearly_billed_total_minor': 299000,
          'badge_text': 'وفر شهرين',
        },
      },
    };

void main() {
  test('live payload parses without throw (boolean premium_avatar, null status)', () {
    expect(() => AppSubscriptionSnapshot.fromDataJson(liveShapePayload()), returnsNormally);
    final snap = AppSubscriptionSnapshot.fromDataJson(liveShapePayload());
    expect(snap.showSurfaces, isTrue);
    expect(snap.entitlements.subscriptionStatus, 'free');
    expect(snap.entitlements.premiumAvatarFlag, isFalse);
    expect(snap.entitlements.showPremiumAvatar, isFalse);
    expect(snap.paywall?.subscribeCta, 'اشترك في Premium');
    expect(snap.paywall?.continueFreeCta, 'الاستمرار مجاناً');
  });

  test('single plans object becomes yearly + monthly tiles with minors', () {
    final snap = AppSubscriptionSnapshot.fromDataJson(liveShapePayload());
    final yearly = snap.paywall!.planById('yearly')!;
    final monthly = snap.paywall!.planById('monthly')!;
    expect(yearly.monthlyEquivalentMinor, 24917);
    expect(yearly.totalBilledMinor, 299000);
    expect(yearly.originalMonthlyEquivalentMinor, isNull);
    expect(yearly.savingsBadge, 'وفر شهرين');
    expect(monthly.monthlyEquivalentMinor, 29900);
    expect(yearly.id, isNot('premium'));
    expect(snap.paywall!.plans.first.id, 'yearly');
    expect(snap.paywall!.plans[1].id, 'monthly');
  });

  test('plans list with one premium package expands to yearly then monthly', () {
    final raw = liveShapePayload();
    final paywall = raw['paywall'] as Map<String, dynamic>;
  final package = paywall.remove('plans') as Map<String, dynamic>;
    paywall['plans'] = [package];
    final snap = AppSubscriptionSnapshot.fromDataJson(raw);
    expect(snap.paywall!.plans, hasLength(2));
    expect(snap.paywall!.planById('premium'), isNull);
    expect(snap.paywall!.plans.first.id, 'yearly');
    expect(snap.paywall!.plans.last.id, 'monthly');
    expect(snap.paywall!.planById('yearly')!.monthlyEquivalentMinor, 24917);
    expect(snap.paywall!.planById('yearly')!.originalMonthlyEquivalentMinor, isNull);
    expect(snap.paywall!.planById('monthly')!.monthlyEquivalentMinor, 29900);
    expect(snap.paywall!.planById('monthly')!.originalMonthlyEquivalentMinor, isNull);
  });

  test('yearly tile shows strike only when promo discounted minors exist', () {
    final raw = liveShapePayload();
    final pkg = (raw['paywall'] as Map)['plans'] as Map<String, dynamic>;
    pkg['price_yearly_discounted_minor'] = 209300;
    final snap = AppSubscriptionSnapshot.fromDataJson(raw);
    final yearly = snap.paywall!.planById('yearly')!;
    expect(yearly.monthlyEquivalentMinor, (209300 / 12).round());
    expect(yearly.originalMonthlyEquivalentMinor, isNotNull);
    expect(yearly.originalMonthlyEquivalentMinor, isNot(equals(yearly.monthlyEquivalentMinor)));
  });

  test('plans list with existing yearly/monthly tiles is preserved', () {
    final raw = liveShapePayload();
    final paywall = raw['paywall'] as Map<String, dynamic>;
    paywall['plans'] = [
      {
        'id': 'monthly',
        'label': 'شهري',
        'monthly_equivalent_minor': 100,
      },
      {
        'id': 'yearly',
        'label': 'سنوي',
        'monthly_equivalent_minor': 80,
        'total_minor': 960,
      },
    ];
    final snap = AppSubscriptionSnapshot.fromDataJson(raw);
    expect(snap.paywall!.plans.first.id, 'yearly');
    expect(snap.paywall!.plans.last.id, 'monthly');
    expect(snap.paywall!.planById('yearly')!.monthlyEquivalentMinor, 80);
  });

  test('premium_avatar true or hex does not throw; hex overrides color', () {
    final withBool = AppSubscriptionEntitlements.fromJson({
      'is_premium': true,
      'is_expired_premium': false,
      'premium_avatar': true,
    });
    expect(withBool.showPremiumAvatar, isTrue);
    expect(withBool.premiumAvatarColor, SubscriptionColors.violet);

    final withHex = AppSubscriptionEntitlements.fromJson({
      'is_premium': false,
      'premium_avatar': '#112233',
    });
    expect(withHex.premiumAvatarFlag, isTrue);
    expect(withHex.premiumAvatarColor, const Color(0xFF112233));
  });

  test('offer minors apply to split plans', () {
    final raw = liveShapePayload();
    (raw['paywall'] as Map)['offer'] = {
      'title': 'عرض',
      'badge_text': 'وفر ٣٠٪',
      'monthly_original_minor': 29900,
      'monthly_discounted_minor': 20930,
      'yearly_original_minor': 299900,
      'yearly_discounted_minor': 209930,
    };
    final snap = AppSubscriptionSnapshot.fromDataJson(raw);
    final monthly = snap.paywall!.planById('monthly')!;
    final yearly = snap.paywall!.planById('yearly')!;
    expect(monthly.monthlyEquivalentMinor, 20930);
    expect(monthly.originalMonthlyEquivalentMinor, 29900);
    expect(yearly.monthlyEquivalentMinor, (209930 / 12).round());
    expect(yearly.originalMonthlyEquivalentMinor, (299900 / 12).round());
    expect(snap.paywall!.offer?.yearlySavingsBadge, 'وفر ٣٠٪');
  });
}
