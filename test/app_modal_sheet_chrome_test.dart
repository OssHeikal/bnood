import 'package:bnood/core/config/theme/app_size.dart';
import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/widgets/buttons/app_button.dart';
import 'package:bnood/core/widgets/app_modal_sheet.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _width = 390.0;
const _height = 844.0;
const _topPad = 47.0;
const _bottomPad = 34.0;
const _keyboard = 336.0;

void _setPhoneSurface(WidgetTester tester, {double keyboard = 0}) {
  tester.view.physicalSize = const Size(_width, _height);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: _topPad, bottom: _bottomPad);
  tester.view.viewPadding = const FakeViewPadding(top: _topPad, bottom: _bottomPad);
  tester.view.viewInsets = FakeViewPadding(bottom: keyboard);
  addTearDown(tester.view.reset);
}

Future<void> _openChromeSheet(
  WidgetTester tester, {
  required bool scrollable,
  bool autofocusLast = false,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppFoundationTheme.light(),
      locale: const Locale('ar'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: HomeFoundationScope(
        child: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () {
                  AppModalSheet.show<void>(
                    context: context,
                    scrollable: scrollable,
                    header: const Padding(
                      padding: EdgeInsets.all(AppSize.spaceMD),
                      child: Text('عنوان'),
                    ),
                    body: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (scrollable)
                          for (var i = 0; i < 12; i++)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSize.screenPadding),
                              child: Text('سطر $i'),
                            ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSize.screenPadding),
                          child: TextField(
                            key: const Key('lower_field'),
                            autofocus: autofocusLast,
                            decoration: const InputDecoration(labelText: 'حقل'),
                          ),
                        ),
                      ],
                    ),
                    footer: AppButton(
                      text: 'حفظ',
                      onPressed: () {},
                    ),
                  );
                },
                child: const Text('open'),
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
}

void main() {
  for (final scrollable in [false, true]) {
    for (final keyboard in [0.0, _keyboard]) {
      testWidgets(
        'chrome scrollable=$scrollable keyboard=$keyboard',
        (tester) async {
          _setPhoneSurface(tester, keyboard: keyboard);
          await _openChromeSheet(tester, scrollable: scrollable, autofocusLast: keyboard > 0);

          expect(tester.takeException(), isNull);

          final sheetBounds = tester.getTopLeft(find.byKey(AppModalSheet.sheetBoundsKey));
          expect(sheetBounds.dy, greaterThanOrEqualTo(_topPad - 1));

          final saveBottom = tester.getBottomLeft(find.text('حفظ')).dy;
          if (keyboard > 0) {
            expect(saveBottom, lessThanOrEqualTo(_height - keyboard - AppSize.spaceMD + 2));
            expect(saveBottom, greaterThan(_height - keyboard - AppSize.spaceMD - 80));
          } else {
            expect(saveBottom, lessThanOrEqualTo(_height - _bottomPad - AppSize.spaceMD + 2));
          }

          if (keyboard > 0 && scrollable) {
            final fieldBottom = tester.getBottomLeft(find.byKey(const Key('lower_field'))).dy;
            expect(fieldBottom, lessThan(saveBottom - 4));
          }
        },
      );
    }
  }
}