import 'package:bnood/app/widgets/shell_nav_icon.dart';
import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/widgets/app_decision.dart';
import 'package:bnood/core/widgets/buttons/app_button.dart';
import 'package:bnood/core/widgets/toast/app_tone.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child, {Locale locale = const Locale('ar'), double textScale = 1}) {
  return MaterialApp(
    locale: locale,
    theme: AppFoundationTheme.light(),
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('ar'), Locale('en')],
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => AppDecision.show(
                context,
                title: 'تأكيد',
                description: 'بيانات تجريبية',
                confirmLabel: 'نعم',
                cancelLabel: 'لا',
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('AppDecision opens and cancels in AR at 1.2x text scale', (tester) async {
    await tester.pumpWidget(_wrap(const SizedBox(), textScale: 1.2));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('لا'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets('AppDecision confirms in EN', (tester) async {
    await tester.pumpWidget(_wrap(const SizedBox(), locale: const Locale('en')));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('نعم'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('AppDecision async failure shows retry without assertion', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ar')],
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => AppDecision.show(
                  context,
                  title: 'حذف',
                  confirmLabel: 'حذف',
                  cancelLabel: 'إلغاء',
                  tone: AppTone.danger,
                  onConfirm: () async {
                    throw Exception('network');
                  },
                ),
                child: const Text('danger'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('danger'));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byType(Dialog), matching: find.widgetWithText(AppButton, 'حذف')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
    expect(find.textContaining('network'), findsOneWidget);
    expect(find.text('إعادة المحاولة'), findsOneWidget);
  });

  testWidgets('danger dialog without override still shows logout icon', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => AppDecision.show(
                  context,
                  title: 'Delete',
                  confirmLabel: 'Delete',
                  cancelLabel: 'Cancel',
                  tone: AppTone.danger,
                ),
                child: const Text('danger-default'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('danger-default'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.logout), findsOneWidget);
  });

  testWidgets('archive danger iconWidget replaces logout glyph', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => AppDecision.show(
                  context,
                  title: 'Archive client?',
                  confirmLabel: 'Archive',
                  cancelLabel: 'Cancel',
                  tone: AppTone.danger,
                  iconWidget: AppDecision.archiveDangerIcon(context),
                ),
                child: const Text('archive'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('archive'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.logout), findsNothing);
    expect(find.byType(ShellNavIcon), findsOneWidget);
    expect(find.bySemanticsLabel('Archive'), findsWidgets);
  });

  testWidgets('IconData icon override still wins over danger default', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => AppDecision.show(
                  context,
                  title: 'Confirm',
                  confirmLabel: 'Delete',
                  cancelLabel: 'Cancel',
                  tone: AppTone.danger,
                  icon: Icons.warning_amber_rounded,
                ),
                child: const Text('icon-data'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('icon-data'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    expect(find.byIcon(Icons.logout), findsNothing);
  });
}
