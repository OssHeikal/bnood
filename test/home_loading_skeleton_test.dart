import 'dart:async';

import 'package:bnood/features/home/data/home_row_models.dart';

import 'support/home_notifier_stubs.dart';
import 'package:bnood/features/home/presentation/screens/home_screen.dart';
import 'package:bnood/core/widgets/skeleton/skeleton.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bnood/features/home/presentation/providers/home_dashboard_providers.dart';

void main() {
  testWidgets('Home shows skeleton zones while totals load', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final gate = Completer<HomeTotals>();
    addTearDown(() {
      if (!gate.isCompleted) {
        gate.complete(const HomeTotals(receivedPiastres: 0, spentPiastres: 0));
      }
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeTotalsProvider.overrideWith(
            () => PendingHomeTotalsNotifier(gate.future),
          ),
          homeClientBalancesOverride(const []),
          emptyHomeSupplierSpendsOverride(),
          emptyHomeCraftsmenOverride(),
          emptyHomeSuppliersOverride(),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(Skeleton), findsWidgets);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Bnood'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
