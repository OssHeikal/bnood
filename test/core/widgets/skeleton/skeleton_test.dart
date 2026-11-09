import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/widgets/skeleton/skeleton.dart';
import 'package:bnood/core/widgets/skeleton/skeleton_box.dart';
import 'package:bnood/core/widgets/skeleton/skeleton_text.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Skeleton exposes localized loading semantics', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: Skeleton(
            child: SkeletonBox(width: 80, height: 16),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.bySemanticsLabel('Loading'), findsOneWidget);
    expect(find.byType(SkeletonBox), findsOneWidget);
  });

  testWidgets('Skeleton respects reduced motion', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: const Scaffold(
            body: Skeleton(
              child: SkeletonBox(width: 80, height: 16),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(SkeletonBox), findsOneWidget);
    expect(find.byType(Opacity), findsNothing);
  });

  testWidgets('SkeletonText scales with textScaler', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.2)),
          child: const Scaffold(
            body: SkeletonText(role: SkeletonTextRole.body, width: 120),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
