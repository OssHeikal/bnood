import 'package:bnood/core/subscription/app_subscription.dart';
import 'package:bnood/core/subscription/paywall_v3_models.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_subscription_live_payload_test.dart';

void main() {
  test('v3 payload parses packages, comparison, and trigger', () {
    final raw = {
      'trigger': 'limit_reached',
      'header': {'title': 'Unlock more', 'subtitle': 'Upgrade plan'},
      'benefit_items': [
        {'icon': 'projects_grid', 'text': '4 active projects'},
      ],
      'billing': {
        'monthly_label': 'Monthly',
        'yearly_label': 'Yearly',
        'yearly_savings_percent': 16,
      },
      'packages': [
        {
          'slug': 'pro',
          'name': 'Pro',
          'slug_short': 'PRO',
          'monthly_enabled': true,
          'yearly_enabled': true,
          'purchase_mode': 'checkout',
          'is_recommended': true,
          'badge_type': 'recommended',
          'badge_label': 'Popular',
          'pricing': {
            'monthly': {
              'original_minor': 29900,
              'discounted_minor': 29900,
              'per_month_equivalent_minor': 29900,
            },
            'yearly': {
              'original_minor': 300000,
              'discounted_minor': 300000,
              'per_month_equivalent_minor': 25000,
              'billed_total_minor': 300000,
            },
          },
          'cta_labels': {'yearly': 'Start Pro at 250 EGP/mo'},
          'highlight_benefits': [
            {'icon': 'spark', 'text': 'Team included'},
          ],
        },
        {
          'slug': 'enterprise',
          'name': 'Enterprise',
          'purchase_mode': 'contact',
          'contact_cta_text': 'Contact us',
          'monthly_enabled': false,
          'yearly_enabled': false,
          'pricing': {},
        },
      ],
      'comparison_table': {
        'columns': [
          {'slug': 'pro', 'name': 'Pro'},
          {'slug': 'enterprise', 'name': 'Enterprise'},
        ],
        'rows': [
          {'key': 'active_projects', 'label': 'Active projects'},
        ],
        'cells': {
          'pro': {'active_projects': '4'},
          'enterprise': {'active_projects': 'Unlimited'},
        },
      },
      'footer': {
        'reassurance': 'Cancel anytime',
        'restore_purchase_visible': true,
      },
      'primary_cta': 'Start Pro',
    };

    final content = AppPaywallContent.fromJson(raw, localeCode: 'en');
    expect(content, isNotNull);
    expect(content!.usesV3Layout, isTrue);
    expect(content.v3!.trigger, 'limit_reached');
    expect(content.v3!.packages, hasLength(2));
    expect(content.v3!.comparisonTable?.columns.length, 2);
    expect(content.v3!.benefitsForPackage(content.v3!.packages.first).first.text, 'Team included');
    expect(content.v3!.packages.last.isContact, isTrue);
    expect(content.v3!.packages.last.resolveCta('yearly'), 'Contact us');
  });

  test('legacy premium object synthesizes v3 packages', () {
    final snap = AppSubscriptionSnapshot.fromDataJson(liveShapePayload(), localeCode: 'ar');
    expect(snap.paywall?.usesV3Layout, isTrue);
    expect(snap.paywall?.v3?.packages.single.slug, 'premium');
    expect(snap.paywall?.v3?.packages.single.yearlyEnabled, isTrue);
    expect(snap.paywall?.v3?.packages.single.monthlyEnabled, isTrue);
    expect(snap.paywall?.planById('yearly'), isNotNull);
  });

  test('offer banner falls back to legacy offer subtitle', () {
    final raw = liveShapePayload();
    final paywall = Map<String, dynamic>.from(raw['paywall'] as Map);
    paywall['offer'] = {
      'title': 'Offer',
      'banner_text': '30% off ends soon',
      'ends_at': '2030-01-01T00:00:00.000Z',
      'show_countdown': true,
    };
    final content = AppPaywallContent.fromJson(paywall, localeCode: 'en');
    expect(content?.v3?.offerBanner?.endsAt, isNotNull);
    expect(content?.v3?.offerBanner?.text, '30% off ends soon');
    expect(content?.v3?.offerBanner?.showCountdown, isTrue);
  });
}