import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/features/suppliers/craftsman_detail_snapshot.dart';
import 'package:bnood/features/suppliers/widgets/craftsman_detail_job_card.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const job = CraftsmanDetailJobRow(
    projectId: 'p1',
    clientId: 'c1',
    clientName: 'Client',
    paidPiastres: 200_000,
    agreedPiastres: 1_000_000,
    remainingPiastres: 800_000,
  );

  Future<void> pumpCard(
    WidgetTester tester, {
    required Locale locale,
    required Size surface,
  }) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(surface);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: CraftsmanDetailJobCard(
              job: job,
              craftsmanId: 'cr1',
              craftsmanName: 'Craftsman',
              localeCode: locale.languageCode,
              onAgreementSaved: () async {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('agreement metrics use equal-width columns EN narrow', (tester) async {
    await pumpCard(tester, locale: const Locale('en'), surface: const Size(320, 720));

    final agreed = tester.getSize(find.byKey(const Key('craftsman_job_metric_agreed')));
    final paid = tester.getSize(find.byKey(const Key('craftsman_job_metric_paid')));
    final remaining = tester.getSize(find.byKey(const Key('craftsman_job_metric_remaining')));

    expect(agreed.width, closeTo(paid.width, 1));
    expect(paid.width, closeTo(remaining.width, 1));
    expect(find.textContaining('10,000 EGP'), findsOneWidget);
    expect(find.textContaining('2,000 EGP'), findsOneWidget);
    expect(find.textContaining('8,000 EGP'), findsOneWidget);
  });

  testWidgets('agreement metrics use equal-width columns AR narrow', (tester) async {
    await pumpCard(tester, locale: const Locale('ar'), surface: const Size(320, 720));

    final agreed = tester.getSize(find.byKey(const Key('craftsman_job_metric_agreed')));
    final paid = tester.getSize(find.byKey(const Key('craftsman_job_metric_paid')));
    final remaining = tester.getSize(find.byKey(const Key('craftsman_job_metric_remaining')));

    expect(agreed.width, closeTo(paid.width, 1));
    expect(paid.width, closeTo(remaining.width, 1));
    expect(find.text('المتفق عليه'), findsOneWidget);
    expect(find.text('مدفوع'), findsOneWidget);
    expect(find.text('المتبقي'), findsOneWidget);
    expect(find.textContaining('10,000 EGP'), findsOneWidget);
  });
}
