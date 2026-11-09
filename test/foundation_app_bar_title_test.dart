import 'package:bnood/core/config/theme/app_colors.dart';
import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/widgets/custom_app_bar.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AR CustomAppBar: name and phone share logical start edge', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomeFoundationScope(
          child: Scaffold(
            appBar: const CustomAppBar(
              title: 'أحمد',
              subtitle: '+201014141895',
              subtitleLtr: true,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final nameFinder = find.text('أحمد');
    final phoneFinder = find.textContaining('201014141895');
    expect(phoneFinder, findsOneWidget);
    expect(
      tester.getTopRight(phoneFinder).dx,
      closeTo(tester.getTopRight(nameFinder).dx, 2),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('EN CustomAppBar: name and phone share logical start edge', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomeFoundationScope(
          child: Scaffold(
            appBar: const CustomAppBar(
              title: 'Ahmed',
              subtitle: '+201014141895',
              subtitleLtr: true,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final nameDx = tester.getTopLeft(find.text('Ahmed')).dx;
    final phoneDx = tester.getTopLeft(find.textContaining('201014141895')).dx;
    expect(phoneDx, closeTo(nameDx, 2));
  });

  testWidgets('CustomAppBar title uses pageTitle and subtitle bar is 64', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomeFoundationScope(
          child: Builder(
            builder: (context) {
              final text = context.text;
              return Scaffold(
                appBar: const CustomAppBar(
                  title: 'Title',
                  subtitle: '01000000000',
                  subtitleLtr: true,
                ),
                body: Text('body', style: text.pageTitle),
              );
            },
          ),
        ),
      ),
    );
    await tester.pump();

    final bar = tester.widget<CustomAppBar>(find.byType(CustomAppBar));
    expect(bar.preferredSize.height, 64);

    final titleText = tester.widget<Text>(find.text('Title'));
    final bodyStyle = tester.widget<Text>(find.text('body')).style;
    expect(titleText.style?.fontSize, bodyStyle?.fontSize);
    expect(titleText.style?.fontWeight, bodyStyle?.fontWeight);

    final appBar = tester.widget<AppBar>(
      find.descendant(of: find.byType(CustomAppBar), matching: find.byType(AppBar)),
    );
    expect(appBar.centerTitle, isFalse);
    expect(appBar.toolbarHeight, 64);
  });

  testWidgets('CustomAppBarAction tint and surface backgrounds', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        home: HomeFoundationScope(
          child: Builder(
            builder: (context) {
              final colors = context.colors;
              return Scaffold(
                appBar: CustomAppBar(
                  title: 'Actions',
                  actions: [
                    CustomAppBarAction(
                      tooltip: 'add',
                      tone: CustomAppBarActionTone.tint,
                      onPressed: () {},
                      child: const Icon(Icons.add, size: 20),
                    ),
                    CustomAppBarAction(
                      tooltip: 'edit',
                      onPressed: () {},
                      child: const Icon(Icons.edit, size: 20),
                    ),
                  ],
                ),
                body: Text('colors', style: TextStyle(color: colors.accentTeal.tint)),
              );
            },
          ),
        ),
      ),
    );
    await tester.pump();

    final tintMaterial = tester.widget<Material>(
      find.descendant(
        of: find.byTooltip('add'),
        matching: find.byType(Material),
      ).first,
    );
    final surfaceMaterial = tester.widget<Material>(
      find.descendant(
        of: find.byTooltip('edit'),
        matching: find.byType(Material),
      ).first,
    );
    expect(tintMaterial.color, AppColors.light.accentTeal.tint);
    expect(surfaceMaterial.color, AppColors.light.surface);
  });
}
