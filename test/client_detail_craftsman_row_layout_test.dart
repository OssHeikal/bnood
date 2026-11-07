import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/features/clients/client_detail_snapshot.dart';
import 'package:bnood/features/clients/widgets/client_detail_craftsman_row.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpRow(
    WidgetTester tester, {
    required Locale locale,
    required ClientCraftsmanPreviewRow preview,
    required Size surface,
  }) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(surface);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ClientDetailCraftsmanRow(
            preview: preview,
            localeCode: locale.languageCode,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('paid-only metric stacks at logical start AR narrow', (tester) async {
    const preview = ClientCraftsmanPreviewRow(
      craftsmanId: 'cr1',
      name: 'Craftsman',
      trade: 'Trade',
      paidPiastres: 200_000,
      agreedPiastres: null,
      remainingPiastres: null,
      accentKey: 'teal',
    );
    await pumpRow(
      tester,
      locale: const Locale('ar'),
      preview: preview,
      surface: const Size(320, 400),
    );

    final paidKey = find.byKey(const Key('client_craftsman_metric_paid'));
    expect(paidKey, findsOneWidget);
    expect(find.text('مدفوع'), findsOneWidget);
    expect(find.textContaining('2,000 EGP'), findsOneWidget);

    final labelBox = tester.getRect(find.text('مدفوع'));
    final amountBox = tester.getRect(find.textContaining('2,000 EGP'));
    expect(amountBox.top, greaterThan(labelBox.bottom));
    expect(amountBox.right, closeTo(labelBox.right, 8));
    expect(paidKey, findsOneWidget);
    final metricWidth = tester.getSize(paidKey).width;
    expect(metricWidth, lessThan(200));
  });

  testWidgets('three metrics equal columns EN narrow', (tester) async {
    const preview = ClientCraftsmanPreviewRow(
      craftsmanId: 'cr2',
      name: 'Craftsman',
      paidPiastres: 7_000_00,
      agreedPiastres: 10_000_00,
      remainingPiastres: 3_000_00,
      accentKey: 'teal',
    );
    await pumpRow(
      tester,
      locale: const Locale('en'),
      preview: preview,
      surface: const Size(320, 400),
    );

    final agreed = tester.getSize(find.byKey(const Key('client_craftsman_metric_agreed')));
    final paid = tester.getSize(find.byKey(const Key('client_craftsman_metric_paid')));
    final remaining = tester.getSize(find.byKey(const Key('client_craftsman_metric_remaining')));

    expect(agreed.width, closeTo(paid.width, 1));
    expect(paid.width, closeTo(remaining.width, 1));

    final agreedLabel = tester.getRect(find.text('Agreed'));
    final agreedAmount = tester.getRect(find.textContaining('10,000 EGP'));
    expect(agreedAmount.left, closeTo(agreedLabel.left, 6));
  });

  testWidgets('three metrics equal columns AR narrow', (tester) async {
    const preview = ClientCraftsmanPreviewRow(
      craftsmanId: 'cr2',
      name: 'صنايعي',
      paidPiastres: 7_000_00,
      agreedPiastres: 10_000_00,
      remainingPiastres: 3_000_00,
      accentKey: 'teal',
    );
    await pumpRow(
      tester,
      locale: const Locale('ar'),
      preview: preview,
      surface: const Size(320, 400),
    );

    expect(find.text('المتفق عليه'), findsOneWidget);
    expect(find.text('مدفوع'), findsOneWidget);
    expect(find.text('المتبقي'), findsOneWidget);

    final agreed = tester.getSize(find.byKey(const Key('client_craftsman_metric_agreed')));
    final paid = tester.getSize(find.byKey(const Key('client_craftsman_metric_paid')));
    final remaining = tester.getSize(find.byKey(const Key('client_craftsman_metric_remaining')));
    expect(agreed.width, closeTo(paid.width, 1));
    expect(paid.width, closeTo(remaining.width, 1));
  });
}
