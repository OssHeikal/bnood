import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/widgets/app_modal_sheet.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/features/providers/provider_create_sheet.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _keyboard = 336.0;
const _phone = Size(440, 956);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('modal sheet does not overflow when keyboard is open', (tester) async {
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
                    onPressed: () => AppModalSheet.show<void>(
                      context: context,
                      body: const ProviderCreateSheet(),
                    ),
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
    expect(find.byType(SingleChildScrollView), findsWidgets);
  });
}