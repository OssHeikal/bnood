import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/widgets/skeleton/skeleton.dart';
import 'package:bnood/core/widgets/skeleton/skeleton_box.dart';
import 'package:bnood/core/widgets/skeleton/skeleton_text.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/features/suppliers/widgets/directory_list_loading_skeleton.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('directory row skeleton mirrors list row layout in RTL', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => HomeFoundationScope(child: child!),
        home: const Scaffold(
          body: DirectoryListLoadingSkeleton(count: 1),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(Skeleton), findsOneWidget);
    expect(find.byType(DirectoryListRowSkeleton), findsOneWidget);
    expect(find.byType(SkeletonText), findsNWidgets(3));
    expect(
      find.descendant(of: find.byType(DirectoryListRowSkeleton), matching: find.byType(ColoredBox)),
      findsOneWidget,
    );

    final boxes = tester.widgetList<SkeletonBox>(find.byType(SkeletonBox));
    expect(boxes.where((b) => b.circle).length, 1);
  });
}
