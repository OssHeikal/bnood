import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/database/database.dart';
import 'package:bnood/features/clients/client_detail_snapshot.dart';
import 'package:bnood/features/clients/widgets/client_movement_card.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

ClientDetailMovementLine _line({
  required Transaction transaction,
  String? itemName,
  String? payeeName,
}) {
  return ClientDetailMovementLine(
    transaction: transaction,
    itemName: itemName,
    payeeName: payeeName,
  );
}

Transaction _tx({
  required int amount,
  required DateTime date,
  String kind = 'spend',
  String? expenseType = 'materials',
  String? description,
}) {
  return Transaction(
    id: 't1',
    workspaceId: 'w',
    projectId: 'p',
    kind: kind,
    amountPiastres: amount,
    date: date,
    method: 'cash',
    description: description,
    receiptImagePath: null,
    itemId: 'item1',
    expenseType: expenseType,
    supplierId: 's1',
    craftsmanId: null,
    createdAt: date,
    updatedAt: date,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('movement card EN: trailing amount, badges, date, no receive/spend label', (tester) async {
    final date = DateTime(2026, 11, 7);
    final line = _line(
      transaction: _tx(amount: 1000000, date: date, description: 'Tiles for lobby'),
      itemName: 'Flooring',
      payeeName: 'Cairo Supplies',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ClientMovementCard(line: line, localeCode: 'en'),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Flooring'), findsOneWidget);
    expect(find.text('Cairo Supplies'), findsOneWidget);
    expect(find.text('Tiles for lobby'), findsOneWidget);
    expect(find.text('Materials'), findsOneWidget);
    expect(find.text('Cash'), findsOneWidget);
    expect(find.text('Spend'), findsNothing);
    expect(find.text('Receive'), findsNothing);
    expect(find.textContaining('10,000 EGP'), findsOneWidget);
    expect(find.textContaining('2026'), findsOneWidget);

    final amountDx = tester.getTopLeft(find.textContaining('10,000 EGP')).dx;
    final titleDx = tester.getTopLeft(find.text('Flooring')).dx;
    expect(amountDx, greaterThan(titleDx));
  });

  testWidgets('movement card omits empty description and subtitle', (tester) async {
    final line = _line(
      transaction: _tx(amount: 50000, date: DateTime(2026, 1, 1), description: null),
      itemName: 'Paint',
      payeeName: null,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ClientMovementCard(line: line, localeCode: 'en'),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Paint'), findsOneWidget);
    expect(find.text('No description'), findsNothing);
    expect(find.textContaining('Supplier'), findsNothing);
  });

  testWidgets('movement card AR at narrow width does not overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final line = _line(
      transaction: _tx(
        amount: 123456789,
        date: DateTime(2026, 11, 7),
        description: 'وصف طويل للتجربة',
      ),
      itemName: 'أرضيات',
      payeeName: 'مورد طويل الاسم للاختبار',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ClientMovementCard(line: line, localeCode: 'ar'),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.textContaining('EGP'), findsOneWidget);
  });

  test('formatMovementDate uses Western digits', () {
    final label = ClientMovementCard.formatMovementDate(DateTime(2026, 11, 7), 'en');
    expect(label, contains('07'));
    expect(label, contains('2026'));
    expect(label, isNot(contains('٠')));
  });
}
