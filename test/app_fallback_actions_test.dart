import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/widgets/app_fallback.dart';
import 'package:bnood/core/widgets/buttons/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AppFallback renders three action roles', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        home: const Scaffold(
          body: AppFallback(
            title: 'Empty',
            actions: [
              AppFallbackAction(label: 'Primary', onPressed: _noop),
              AppFallbackAction(label: 'Secondary', onPressed: _noop, role: AppFallbackActionRole.secondary),
              AppFallbackAction(label: 'Tertiary', onPressed: _noop, role: AppFallbackActionRole.tertiary),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Primary'), findsOneWidget);
    expect(find.text('Secondary'), findsOneWidget);
    expect(find.text('Tertiary'), findsOneWidget);
    expect(find.byType(AppButton), findsNWidgets(3));
  });

  testWidgets('legacy single action still works', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        home: Scaffold(
          body: AppFallback(title: 'Empty', actionLabel: 'Add', onAction: () {}),
        ),
      ),
    );
    expect(find.text('Add'), findsOneWidget);
  });
}

void _noop() {}
