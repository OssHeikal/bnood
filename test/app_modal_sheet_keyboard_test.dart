import 'package:bnood/core/services/config/theme/app_theme.dart';
import 'package:bnood/core/ui/widgets/custom_text_field.dart';
import 'package:bnood/features/home/presentation/widgets/home_foundation_scope.dart';
import 'package:bnood/features/providers/presentation/sheets/provider_create_sheet.dart'
    show showProviderCreateSheet;
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _keyboard = 336.0;
const _phone = Size(440, 956);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('modal sheet does not overflow when keyboard is open', (
    tester,
  ) async {
    tester.view.physicalSize = _phone;
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: _keyboard);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomeFoundationScope(
            child: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: FilledButton(
                    onPressed: () => showProviderCreateSheet(context),
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('حفظ'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsNothing);
  });

  testWidgets('back with keyboard open unfocuses without closing sheet', (
    tester,
  ) async {
    tester.view.physicalSize = _phone;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomeFoundationScope(
            child: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: FilledButton(
                    onPressed: () => showProviderCreateSheet(context),
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    tester.view.viewInsets = const FakeViewPadding(bottom: _keyboard);
    await tester.pump();

    await tester.tap(find.widgetWithText(CustomTextField, 'الاسم'));
    await tester.pump();

    await tester.binding.handlePopRoute();
    await tester.pump();

    expect(find.text('حفظ'), findsOneWidget);
    tester.view.viewInsets = FakeViewPadding.zero;
    await tester.pump();
  });
}
