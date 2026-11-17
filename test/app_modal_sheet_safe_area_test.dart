import 'package:bnood/core/config/theme/app_size.dart';
import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/widgets/app_modal_sheet.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/core/widgets/buttons/app_button.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _topInset = 59.0;
const _bottomInset = 34.0;

void _applyDeviceInsets(WidgetTester tester) {
  tester.view.padding = const FakeViewPadding(top: _topInset, bottom: _bottomInset);
  tester.view.viewPadding = const FakeViewPadding(top: _topInset, bottom: _bottomInset);
  tester.view.physicalSize = const Size(430, 932);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('AppModalSheet keeps bottom actions above home indicator', (tester) async {
    _applyDeviceInsets(tester);
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
                  onPressed: () => AppModalSheet.show<void>(
                    context: context,
                    scrollable: false,
                    body: const SizedBox(height: 48),
                    footer: AppButton(text: 'حذف', onPressed: () {}),
                  ),
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

    final deleteButton = find.text('حذف');
    expect(deleteButton, findsOneWidget);
    final bottom = tester.getBottomLeft(deleteButton).dy;
    expect(bottom, lessThanOrEqualTo(932 - _bottomInset - AppSize.spaceMD + 2));
    expect(bottom, greaterThan(932 - _bottomInset - AppSize.spaceMD - 72));
    expect(tester.takeException(), isNull);
  });
}
