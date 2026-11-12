import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/widgets/buttons/app_button.dart';
import 'package:bnood/core/widgets/text_field/app_input_direction.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('rtl paragraph only when the locale is RTL and the string has Arabic', () {
    expect(rtlParagraphIfArabic('اشترك في Premium', TextDirection.rtl), TextDirection.rtl);
    expect(rtlParagraphIfArabic('Premium اشترك', TextDirection.rtl), TextDirection.rtl);
    expect(rtlParagraphIfArabic('Subscribe to Premium', TextDirection.rtl), isNull);
    expect(rtlParagraphIfArabic('اشترك في Premium', TextDirection.ltr), isNull);
  });

  testWidgets('Arabic button label keeps the Latin word at the end of the sentence', (tester) async {
    const label = 'اشترك في Premium';
    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: AppButton.primary(text: label, onPressed: () {}),
          ),
        ),
      ),
    );

    final text = tester.widget<Text>(find.text(label));
    expect(text.textDirection, TextDirection.rtl);

    final paragraph = tester.renderObject<RenderParagraph>(find.text(label));
    final arabicRight = _rightEdge(paragraph, 0, 'اشترك'.length);
    final premiumStart = label.indexOf('Premium');
    final premiumRight = _rightEdge(paragraph, premiumStart, premiumStart + 'Premium'.length);
    expect(arabicRight, greaterThan(premiumRight));
  });

  testWidgets('English button label stays left to right inside an RTL screen', (tester) async {
    const label = 'Subscribe to Premium';
    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: AppButton.primary(text: label, onPressed: () {}),
          ),
        ),
      ),
    );

    final text = tester.widget<Text>(find.text(label));
    expect(text.textDirection, isNot(TextDirection.rtl));
  });
}

double _rightEdge(RenderParagraph paragraph, int start, int end) {
  final boxes = paragraph.getBoxesForSelection(
    TextSelection(baseOffset: start, extentOffset: end),
  );
  return boxes.map((box) => box.right).reduce((a, b) => a > b ? a : b);
}
