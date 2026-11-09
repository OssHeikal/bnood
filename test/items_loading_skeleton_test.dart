import 'package:bnood/core/config/theme/app_size.dart';
import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/widgets/skeleton/skeleton.dart';
import 'package:bnood/core/widgets/skeleton/skeleton_box.dart';
import 'package:bnood/core/widgets/skeleton/skeleton_text.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/features/items/widgets/items_loading_skeleton.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('item catalog tile skeleton matches ItemCatalogTile structure', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => HomeFoundationScope(child: child!),
        home: const Scaffold(
          body: ItemsLoadingSkeleton(count: 1),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(Skeleton), findsOneWidget);
    expect(find.byType(ItemCatalogTileSkeleton), findsOneWidget);

    final iconBox = tester.widget<SkeletonBox>(
      find.descendant(
        of: find.byType(ItemCatalogTileSkeleton),
        matching: find.byWidgetPredicate(
          (w) => w is SkeletonBox && w.width == ItemsLoadingSkeleton.iconSize && w.height == ItemsLoadingSkeleton.iconSize,
        ),
      ),
    );
    expect(iconBox.width, ItemsLoadingSkeleton.iconSize);
    expect(iconBox.height, ItemsLoadingSkeleton.iconSize);
    expect(iconBox.radius, AppSize.radiusSM);

    final textBones = tester.widgetList<SkeletonText>(
      find.descendant(of: find.byType(ItemCatalogTileSkeleton), matching: find.byType(SkeletonText)),
    );
    expect(textBones.length, 3);
    expect(textBones.any((t) => t.width == ItemsLoadingSkeleton.defaultBadgeWidth), isTrue);
    expect(textBones.any((t) => t.width == ItemsLoadingSkeleton.titlePrimaryWidth), isTrue);
    expect(textBones.any((t) => t.width == ItemsLoadingSkeleton.titleSecondaryWidth), isTrue);
    expect(textBones.every((t) => t.width != null && t.width! <= 96), isTrue);
  });
}
