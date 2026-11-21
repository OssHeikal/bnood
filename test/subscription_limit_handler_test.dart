import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/subscription/app_subscription.dart';
import 'package:bnood/core/subscription/paywall_v3_models.dart';
import 'package:bnood/core/subscription/subscription_riverpod.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/features/subscription/paywall_launcher.dart';
import 'package:bnood/features/subscription/subscription_gates.dart';
import 'package:bnood/features/subscription/subscription_limit_handler.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

AppSubscriptionSnapshot _cappedSnapshot({required bool paywallEnabled}) {
  return AppSubscriptionSnapshot.fromDataJson({
    'paywall_enabled': paywallEnabled,
    'entitlements': {
      'show_paywall_surfaces': true,
      'can_create_active_project': false,
      'active_projects_count': 1,
      'active_project_cap': 1,
    },
    'paywall': {
      'title': 'Paywall',
      'subtitle': '',
      'benefits': const <String>[],
      'plans': const [
        {'id': 'yearly', 'label': 'Yearly', 'monthly_equivalent_minor': 249000},
      ],
    },
  });
}

AppSubscriptionSnapshot? _harnessSnapshot;

class _HarnessSubscription extends SubscriptionNotifier {
  @override
  Future<AppSubscriptionSnapshot?> build() async => _harnessSnapshot;
}

Future<bool>? _guardFuture;

class _GuardTrigger extends ConsumerWidget {
  const _GuardTrigger();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton(
      onPressed: () {
        _guardFuture = guardCreateActiveProject(
          context,
          ref,
          limitKind: SubscriptionLimitKind.clients,
        );
      },
      child: const Text('trigger'),
    );
  }
}

class _GuardTriggerProjects extends ConsumerWidget {
  const _GuardTriggerProjects();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton(
      onPressed: () {
        _guardFuture = guardCreateActiveProject(context, ref);
      },
      child: const Text('trigger'),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('harness subscription override exposes capped entitlements', () async {
    _harnessSnapshot = _cappedSnapshot(paywallEnabled: false);
    final container = ProviderContainer(
      overrides: [subscriptionProvider.overrideWith(_HarnessSubscription.new)],
    );
    addTearDown(container.dispose);
    final snap = await container.read(subscriptionProvider.future);
    expect(snap, isNotNull);
    expect(snap!.showSurfaces, isFalse);
    expect(snap.entitlements.mayCreateActiveProject, isFalse);
  });

  Future<void> pumpHarness(
    WidgetTester tester, {
    required AppSubscriptionSnapshot snapshot,
    required Widget trigger,
    List<int>? paywallCallCounter,
    Locale locale = const Locale('ar'),
  }) async {
    _harnessSnapshot = snapshot;
    _guardFuture = null;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          subscriptionProvider.overrideWith(_HarnessSubscription.new),
          if (paywallCallCounter != null)
            paywallPresentProvider.overrideWith(
              (ref) =>
                  (context, {WidgetRef? ref, PaywallFetchTrigger trigger = PaywallFetchTrigger.defaultTrigger}) async {
                paywallCallCounter.add(paywallCallCounter.length + 1);
              },
            ),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomeFoundationScope(
            child: Scaffold(body: Center(child: trigger)),
          ),
        ),
      ),
    );
    await tester.pump();
    final element = tester.element(find.byType(Scaffold));
    await ProviderScope.containerOf(element).read(subscriptionProvider.future);
  }

  Future<bool?> runGuard(WidgetTester tester, {String dismissLabel = 'تمام'}) async {
    await tester.tap(find.text('trigger'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    if (find.text(dismissLabel).evaluate().isNotEmpty) {
      await tester.tap(find.text(dismissLabel));
      await tester.pumpAndSettle();
    }
    return _guardFuture;
  }

  testWidgets('paywall disabled at cap shows info dialog not paywall', (tester) async {
    final paywallCalls = <int>[];
    await pumpHarness(
      tester,
      snapshot: _cappedSnapshot(paywallEnabled: false),
      paywallCallCounter: paywallCalls,
      trigger: const _GuardTrigger(),
    );
    final element = tester.element(find.byType(_GuardTrigger));
    expect(ProviderScope.containerOf(element).read(subscriptionProvider).valueOrNull, isNotNull);

    await tester.tap(find.text('trigger'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(paywallCalls, isEmpty);
    expect(find.text('وصلت للحد الأقصى للعملاء'), findsOneWidget);
    expect(find.text('الحد المسموح: 1'), findsOneWidget);
    expect(find.text('تمام'), findsOneWidget);
    expect(find.text('Premium'), findsNothing);

    await tester.tap(find.text('تمام'));
    await tester.pumpAndSettle();
    expect(await _guardFuture, isFalse);
  });

  testWidgets('paywall enabled at cap opens paywall not limit dialog', (tester) async {
    final paywallCalls = <int>[];
    await pumpHarness(
      tester,
      snapshot: _cappedSnapshot(paywallEnabled: true),
      paywallCallCounter: paywallCalls,
      trigger: const _GuardTriggerProjects(),
    );
    expect(await runGuard(tester), isFalse);
    expect(paywallCalls, [1]);
    expect(find.text('وصلت للحد الأقصى للمشاريع'), findsNothing);
  });

  testWidgets('test user bypasses limit gate without dialog or paywall', (tester) async {
    final paywallCalls = <int>[];
    final snapshot = AppSubscriptionSnapshot.fromDataJson({
      'paywall_enabled': true,
      'is_test_user': true,
      'subscription_ui_enabled': false,
      'entitlements': {
        'show_paywall_surfaces': false,
        'can_create_active_project': false,
        'active_projects_count': 5,
        'active_project_cap': 1,
      },
    });
    await pumpHarness(
      tester,
      snapshot: snapshot,
      paywallCallCounter: paywallCalls,
      trigger: const _GuardTriggerProjects(),
    );
    expect(await runGuard(tester), isTrue);
    expect(paywallCalls, isEmpty);
    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets('projects limit title in English', (tester) async {
    final paywallCalls = <int>[];
    await pumpHarness(
      tester,
      snapshot: _cappedSnapshot(paywallEnabled: false),
      paywallCallCounter: paywallCalls,
      locale: const Locale('en'),
      trigger: const _GuardTriggerProjects(),
    );
    await tester.tap(find.text('trigger'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text("You've reached the project limit"), findsOneWidget);
    expect(find.text('Maximum allowed: 1'), findsOneWidget);
    expect(find.text('Got it'), findsOneWidget);
    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();
    expect(await _guardFuture, isFalse);
  });
}