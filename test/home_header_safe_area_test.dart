import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:bnood/features/home/home_screen.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/home_notifier_stubs.dart';

// Uses the same home data stubs as other home widget tests to avoid async spinners.

void main() {
  testWidgets('home title sits below simulated status bar inset', (tester) async {
    const statusBar = 47.0;
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeTotalsOverride(const HomeTotals(receivedPiastres: 0, spentPiastres: 0)),
          homeClientBalancesOverride(const []),
          emptyHomeSupplierSpendsOverride(),
          emptyHomeCraftsmenOverride(),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: const MediaQueryData(padding: EdgeInsets.only(top: statusBar)),
            child: const HomeScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('بنود'), findsOneWidget);
  });
}
