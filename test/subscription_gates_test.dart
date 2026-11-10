import 'package:bnood/core/api/auth_api_exception.dart';
import 'package:bnood/core/subscription/app_subscription.dart';
import 'package:flutter_test/flutter_test.dart';

AppSubscriptionSnapshot _cappedSnapshot() {
  return AppSubscriptionSnapshot.fromDataJson({
    'paywall_enabled': true,
    'entitlements': {
      'show_paywall_surfaces': true,
      'can_create_active_project': false,
      'can_mutate_financial_transactions': false,
    },
    'paywall': {
      'title': 'Paywall',
      'subtitle': '',
      'benefits': const [],
      'plans': const [
        {'id': 'yearly', 'label': 'Yearly', 'monthly_equivalent_minor': 249000},
      ],
    },
  });
}

void main() {
  test('showSurfaces false when admin kill switch off', () {
    final snap = AppSubscriptionSnapshot.fromDataJson({
      'paywall_enabled': false,
      'entitlements': {'show_paywall_surfaces': true},
    });
    expect(snap.showSurfaces, isFalse);
    expect(snap.shouldShowProfileSubscriptionCard, isFalse);
  });

  test('capped free user has paywall payload for gating', () {
    final snap = _cappedSnapshot();
    expect(snap.showSurfaces, isTrue);
    expect(snap.entitlements.canCreateActiveProject, isFalse);
    expect(snap.paywall, isNotNull);
  });

  test('403 codes map to subscription handlers', () {
    final cap = AuthApiException(statusCode: 403, message: 'cap', code: 'active_project_cap_reached');
  final fin = AuthApiException(statusCode: 403, message: 'ro', code: 'subscription_financial_read_only');
    expect(cap.isActiveProjectCapReached, isTrue);
    expect(fin.isSubscriptionFinancialReadOnly, isTrue);
  });

  test('mayCreateActiveProject respects cap count and server flag', () {
    final atCap = AppSubscriptionEntitlements.fromJson({
      'can_create_active_project': true,
      'active_projects_count': 1,
      'active_project_cap': 1,
    });
    expect(atCap.mayCreateActiveProject, isFalse);

    final underCap = AppSubscriptionEntitlements.fromJson({
      'can_create_active_project': true,
      'active_projects_count': 0,
      'active_project_cap': 1,
    });
    expect(underCap.mayCreateActiveProject, isTrue);

    final noCap = AppSubscriptionEntitlements.fromJson({
      'can_create_active_project': true,
      'active_projects_count': 99,
      'active_project_cap': null,
    });
    expect(noCap.mayCreateActiveProject, isTrue);

    final serverDenied = AppSubscriptionEntitlements.fromJson({
      'can_create_active_project': false,
      'active_projects_count': 0,
      'active_project_cap': 1,
    });
    expect(serverDenied.mayCreateActiveProject, isFalse);
  });
}
