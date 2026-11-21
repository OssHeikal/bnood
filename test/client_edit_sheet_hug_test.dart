import 'package:bnood/core/theme/app_theme.dart';
import 'package:bnood/core/widgets/app_modal_sheet.dart';
import 'package:bnood/features/clients/presentation/client_edit_sheet.dart';
import 'package:bnood/features/home/presentation/home_foundation_scope.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _height = 844.0;

void main() {
  testWidgets('client edit sheet height hugs two fields', (tester) async {
    tester.view.physicalSize = const Size(390, _height);
    tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 47, bottom: 34);
  tester.view.viewPadding = const FakeViewPadding(top: 47, bottom: 34);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomeFoundationScope(
            child: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: FilledButton(
                    onPressed: () => showClientEditSheet(
                      context: context,
                      clientId: 'c1',
                      clientName: 'عميل',
                      phone: '01012345678',
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

    final sheetHeight = tester.getSize(find.byKey(AppModalSheet.sheetBoundsKey)).height;
    expect(sheetHeight, lessThan(_height * 0.5));
    expect(tester.takeException(), isNull);
  });
}