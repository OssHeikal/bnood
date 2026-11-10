import 'package:bnood/core/clients/client_statement_record.dart';
import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/items/item_api_record.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/features/statements/statement_api_client_document.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

CatalogItem _catalogBathtub({required String id}) {
  return CatalogItem(
    id: id,
    name: 'Bath item',
    iconKey: 'bathtub',
    colorKey: 'blue',
    isDefault: false,
    sortOrder: 0,
    createdAt: DateTime.utc(2020),
    updatedAt: DateTime.utc(2020),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('remote client statement shows opening period totals and closing in grid', (tester) async {
    final statement = AppClientStatement.fromDataJson({
      'from': '2026-01-01',
      'to': '2026-01-31',
      'opening_balance': 500_000,
      'received': 100_000,
      'spent': 80_000,
      'closing_balance': 520_000,
      'remaining': 520_000,
      'items': [],
    });
    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomeFoundationScope(
          child: Scaffold(
            body: SingleChildScrollView(
              child: StatementApiClientDocument(
                clientName: 'Client',
                statement: statement,
                localeCode: 'ar',
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('رصيد أول المدة'), findsOneWidget);
    expect(find.text('المستلم في الفترة'), findsOneWidget);
    expect(find.text('المصروف في الفترة'), findsOneWidget);
    expect(find.text('المتبقي'), findsOneWidget);
    expect(find.byKey(const Key('statement_stat_closing')), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(
      tester.widgetList(find.byType(SingleChildScrollView)).where((w) {
        return (w as SingleChildScrollView).scrollDirection == Axis.horizontal;
      }),
      isEmpty,
    );
    expect(find.text('مفيش مصروفات في الفترة دي'), findsOneWidget);
  });

  testWidgets('item row uses icon_key from statement response', (tester) async {
    final statement = AppClientStatement.fromDataJson({
      'from': '2026-01-01',
      'to': '2026-01-31',
      'opening_balance': 0,
      'received': 0,
      'spent': 62_000,
      'closing_balance': 0,
      'items': [
        {
          'id': '1',
          'name': 'سيراميك وحمامات',
          'spent': 62_000,
          'icon_key': 'bathtub',
          'color_key': 'blue',
        },
      ],
    });
    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomeFoundationScope(
          child: Scaffold(
            body: StatementApiClientDocument(
              clientName: 'Client',
              statement: statement,
              localeCode: 'ar',
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('سيراميك وحمامات'), findsOneWidget);
    expect(find.byKey(const Key('statement_item_icon_bathtub')), findsOneWidget);
  });

  testWidgets('item row resolves icon from catalog when response omits keys', (tester) async {
    const itemId = '01JVITEM';
    final statement = AppClientStatement.fromDataJson({
      'from': '2026-01-01',
      'to': '2026-01-31',
      'opening_balance': 0,
      'received': 0,
      'spent': 62_000,
      'closing_balance': 0,
      'items': [
        {'id': itemId, 'name': 'سيراميك وحمامات', 'spent': 62_000},
      ],
    });
    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomeFoundationScope(
          child: Scaffold(
            body: StatementApiClientDocument(
              clientName: 'Client',
              statement: statement,
              localeCode: 'ar',
              catalogById: {itemId: _catalogBathtub(id: itemId)},
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byKey(const Key('statement_item_icon_bathtub')), findsOneWidget);
    expect(find.byKey(const Key('statement_item_icon_layers')), findsNothing);
  });
}
