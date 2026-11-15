import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/widgets/app_keyboard_scope.dart';
import 'package:bnood/core/widgets/app_modal_sheet.dart';
import 'package:bnood/core/config/theme/app_size.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/features/providers/provider_create_sheet.dart' show showProviderCreateSheet;
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _keyboard = 336.0;
const _phoneH = 956.0;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('autofocus stays after modal open animation under AppKeyboardScope', (tester) async {
    tester.view.physicalSize = const Size(440, _phoneH);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AppKeyboardScope(
            child: HomeFoundationScope(
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
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 1200));

    expect(FocusManager.instance.primaryFocus?.hasFocus, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('save footer sits above simulated keyboard', (tester) async {
    tester.view.physicalSize = const Size(440, _phoneH);
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

    final saveBottom = tester.getBottomLeft(find.text('حفظ')).dy;
    expect(saveBottom, lessThanOrEqualTo(_phoneH - _keyboard - AppSize.spaceMD + 2));
    expect(tester.takeException(), isNull);
  });
}