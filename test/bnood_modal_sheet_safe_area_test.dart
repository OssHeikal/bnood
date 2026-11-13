import 'package:bnood/core/config/theme/app_size.dart';
import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/widgets/bounded_sheet_navigator.dart';
import 'package:bnood/core/widgets/bnood_modal_sheet.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/features/providers/provider_edit_sheet.dart';
import 'package:bnood/core/providers_api/app_provider_record.dart';
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
  test('modalBottomPadding uses max home and keyboard plus spacing', () {
    const homeOnly = MediaQueryData(viewPadding: EdgeInsets.only(bottom: _bottomInset));
    expect(
      SheetChromeInsets.modalBottomPadding(homeOnly),
      _bottomInset + AppSize.spaceMD,
    );

    const keyboard = MediaQueryData(viewInsets: EdgeInsets.only(bottom: 320));
    expect(
      SheetChromeInsets.modalBottomPadding(keyboard),
      320 + AppSize.spaceMD,
    );

    const both = MediaQueryData(
      viewPadding: const EdgeInsets.only(bottom: _bottomInset),
      viewInsets: const EdgeInsets.only(bottom: 320),
    );
    expect(
      SheetChromeInsets.modalBottomPadding(both),
      320 + AppSize.spaceMD,
    );
  });

  testWidgets('BnoodModalSheet keeps bottom actions above home indicator', (tester) async {
    _applyDeviceInsets(tester);
    final supplier = AppProvider(
      id: 'p1',
      name: 'مورد',
      phone: null,
      type: AppProviderType.supplier,
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );

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
                  onPressed: () => BnoodModalSheet.show<void>(
                    context: context,
                    builder: (_) => ProviderEditSheet(provider: supplier),
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
    expect(bottom, lessThanOrEqualTo(932 - _bottomInset + 1));
    expect(tester.takeException(), isNull);
  });
}
