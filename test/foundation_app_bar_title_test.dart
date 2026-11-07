import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/widgets/foundation_app_bar_title.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AR app bar title: name and phone share logical start edge', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(64),
            child: AppBar(
              centerTitle: false,
              title: FoundationAppBarTitle(
                title: 'أحمد',
                subtitle: '+201014141895',
                subtitleLtr: true,
              ),
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

  testWidgets('EN app bar title: name and phone share logical start edge', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          appBar: AppBar(
            centerTitle: false,
            title: FoundationAppBarTitle(
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
}
