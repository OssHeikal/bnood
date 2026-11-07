import 'package:bnood/core/config/theme/app_colors.dart';
import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/widgets/app_amount.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<Text> pumpAmount(WidgetTester tester, {required int piastres, required String localeCode}) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        home: Scaffold(
          body: AppAmount(
            piastres: piastres,
            role: AppAmountRole.remaining,
            localeCode: localeCode,
            size: AppAmountSize.small,
          ),
        ),
      ),
    );
    await tester.pump();
    return tester.widget<Text>(find.byType(Text));
  }

  testWidgets('remaining negative shows minus and spend color EN', (tester) async {
    final text = await pumpAmount(tester, piastres: -12500, localeCode: 'en');
    final colors = AppColors.light;
    expect(text.data, contains('−'));
    expect(text.data, contains('EGP'));
    expect(text.style?.color, colors.spend);
  });

  testWidgets('remaining positive keeps teal EN', (tester) async {
    final text = await pumpAmount(tester, piastres: 50000, localeCode: 'en');
    expect(text.data, isNot(contains('−')));
    expect(text.style?.color, AppColors.light.remaining);
  });

  testWidgets('remaining zero is neutral AR', (tester) async {
    final text = await pumpAmount(tester, piastres: 0, localeCode: 'ar');
    expect(text.style?.color, AppColors.light.onSurface);
    expect(text.data, contains('EGP'));
  });

  testWidgets('receive role still uses magnitude without forced minus', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        home: const Scaffold(
          body: AppAmount(piastres: -100, role: AppAmountRole.receive, localeCode: 'en'),
        ),
      ),
    );
    await tester.pump();
    final text = tester.widget<Text>(find.byType(Text));
    expect(text.data, isNot(contains('−')));
    expect(text.style?.color, AppColors.light.receive);
  });
}
