import 'package:bnood/core/config/theme/app_size.dart';
import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/database/connection.dart';
import 'package:bnood/core/providers/app_providers.dart';
import 'package:bnood/core/widgets/custom_bottom_sheet.dart';
import 'package:bnood/core/widgets/custom_text_field.dart';
import 'package:bnood/core/widgets/text_field/app_input_frame.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/features/vouchers/inline_create_routes.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> openSupplierSheet(WidgetTester tester, Locale locale) async {
    final db = openTestDatabase();
    addTearDown(db.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomeFoundationScope(
            child: Builder(
              builder: (hostContext) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      CustomBottomSheet.show<String?>(
                        context: hostContext,
                        builder: (_) => const InlineCreateSupplierPage(padForSystemChrome: false),
                        nestedNavigator: false,
                        showDragHandle: false,
                      );
                    },
                    child: const Text('Open'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  testWidgets('supplier create uses optional phone label', (tester) async {
    await openSupplierSheet(tester, const Locale('en'));
    final frames = tester.widgetList<AppInputFrame>(find.byType(AppInputFrame)).toList();
    expect(frames.length, greaterThanOrEqualTo(2));
    expect(frames[1].label, 'Phone (optional)');
    expect(frames.every((f) => f.height == AppSize.fieldHeightComfortable), isTrue);
  });

  testWidgets('craftsman create uses optional phone label', (tester) async {
    final db = openTestDatabase();
    addTearDown(db.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomeFoundationScope(
            child: Builder(
              builder: (hostContext) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      CustomBottomSheet.show<String?>(
                        context: hostContext,
                        builder: (_) => const InlineCreateCraftsmanPage(padForSystemChrome: false),
                        nestedNavigator: false,
                        showDragHandle: false,
                      );
                    },
                    child: const Text('Open'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final frames = tester.widgetList<AppInputFrame>(find.byType(AppInputFrame)).toList();
    expect(frames[1].label, 'Phone (optional)');

    await tester.enterText(find.byType(CustomTextField).first, 'No Phone Craftsman');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Open'), findsOneWidget);
  });

  testWidgets('supplier create returns id', (tester) async {
    await openSupplierSheet(tester, const Locale('en'));
    await tester.enterText(find.byType(CustomTextField).first, 'New Vendor');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Open'), findsOneWidget);
  });
}
