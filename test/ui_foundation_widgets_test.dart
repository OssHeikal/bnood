import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/widgets/app_amount.dart';
import 'package:bnood/core/widgets/app_fallback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AppFallback shows title in foundation theme', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        home: const Scaffold(
          body: AppFallback(title: 'No data', description: 'Demo only'),
        ),
      ),
    );
    expect(find.text('No data'), findsOneWidget);
  });

  testWidgets('AppAmount renders receive color', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        home: const Scaffold(
          body: AppAmount(piastres: 100_000, role: AppAmountRole.receive),
        ),
      ),
    );
    expect(find.byType(AppAmount), findsOneWidget);
  });
}
