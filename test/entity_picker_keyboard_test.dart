import 'package:bnood/core/config/theme/app_size.dart';
import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/widgets/entity_picker_page.dart';
import 'package:bnood/core/widgets/overlay_form_presentation.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _screenH = 844.0;
const _keyboard = 336.0;
const _bottomInset = 34.0;

void _seedPhoneViewport(WidgetTester tester) {
  tester.view.padding = const FakeViewPadding(bottom: _bottomInset);
  tester.view.viewPadding = const FakeViewPadding(bottom: _bottomInset);
  tester.view.physicalSize = const Size(390, _screenH);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

List<(String, String)> _manyEntries() {
  return List.generate(12, (i) => ('id$i', 'Entry $i'));
}

void main() {
  testWidgets('full-screen picker list fills space above keyboard and pinned create row', (tester) async {
    _seedPhoneViewport(tester);
    tester.view.viewInsets = const FakeViewPadding(bottom: _keyboard);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: EntityPickerPage(
          title: 'العملاء',
          presentation: OverlayFormPresentation.fullScreen,
          entries: _manyEntries(),
          onCreateRoute: () => const Scaffold(body: SizedBox()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final create = find.text('إنشاء جديد');
    expect(create, findsOneWidget);

    final listView = find.byType(ListView);
    expect(listView, findsOneWidget);
    final listHeight = tester.getSize(listView).height;
    expect(listHeight, greaterThan(280));

    final createBottom = tester.getBottomLeft(create).dy;
    expect(createBottom, closeTo(_screenH - _keyboard - AppSize.spaceMD, 4));
    expect(tester.takeException(), isNull);
  });
}