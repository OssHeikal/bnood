import 'package:bnood/core/config/theme/app_colors.dart';
import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/resources/gen/assets.gen.dart';
import 'package:bnood/app/widgets/shell_nav_icon.dart';
import 'package:bnood/core/widgets/app_overflow_menu.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Arabic menu shows labels, destructive tint, edit callback only', (tester) async {
    var editTaps = 0;
    var deleteTaps = 0;
    final l10n = lookupAppLocalizations(const Locale('ar'));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomeFoundationScope(
          child: Scaffold(
            body: Center(
              child: AppOverflowMenu(
                actions: [
                  AppOverflowMenuAction(
                    label: l10n.edit,
                    icon: Assets.icons.documentEditOutline,
                    onSelected: () => editTaps++,
                  ),
                  AppOverflowMenuAction(
                    label: l10n.delete,
                    icon: Assets.icons.deleteSquareOutline,
                    onSelected: () => deleteTaps++,
                    destructive: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text(l10n.edit), findsOneWidget);
    expect(find.text(l10n.delete), findsOneWidget);

    final colors = AppFoundationTheme.light().extension<AppColors>()!;
    final deleteLabel = tester.widget<Text>(find.text(l10n.delete));
    expect(deleteLabel.style?.color, colors.spend);

    expect(find.byType(ShellNavIcon), findsNWidgets(2));

    await tester.tap(find.text(l10n.edit));
    await tester.pumpAndSettle();

    expect(editTaps, 1);
    expect(deleteTaps, 0);
  });
}
