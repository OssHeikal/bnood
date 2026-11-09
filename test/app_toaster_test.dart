import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/widgets/app_toaster.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/features/statements/statement_screen_toast.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final botToastBuilder = BotToastInit();

  Widget toastTestApp(Widget home) {
    return MaterialApp(
      builder: botToastBuilder,
      navigatorObservers: [BotToastNavigatorObserver()],
      theme: ThemeData.light(),
      locale: const Locale('ar'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );
  }

  testWidgets('AppToaster shows themed toast without root AppColors extension', (tester) async {
    await tester.pumpWidget(
      toastTestApp(
        HomeFoundationScope(
          child: Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => AppToaster.failure('فشل بدون امتداد'),
                child: const Text('toast'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('toast'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    expect(find.text('فشل بدون امتداد'), findsOneWidget);
  });

  testWidgets('AppToaster success in EN dark theme', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: botToastBuilder,
        navigatorObservers: [BotToastNavigatorObserver()],
        theme: AppFoundationTheme.dark(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomeFoundationScope(
          child: Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => AppToaster.success('Saved'),
                child: const Text('ok'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('ok'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Saved'), findsOneWidget);
  });

  testWidgets('statement footer delegate keeps message above export bar', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: botToastBuilder,
        navigatorObservers: [BotToastNavigatorObserver()],
        theme: AppFoundationTheme.light(),
        home: HomeFoundationScope(
          child: Scaffold(
            bottomNavigationBar: const SizedBox(height: 56, child: ColoredBox(color: Colors.black12)),
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () => StatementScreenToast.failure(context, 'تعذّرت المشاركة'),
                  child: const Text('fail'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('fail'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    final toastScope = find.ancestor(
      of: find.text('تعذّرت المشاركة'),
      matching: find.byType(HomeFoundationScope),
    );
    final marginPadding = tester.widget<Padding>(
      find.ancestor(of: toastScope, matching: find.byType(Padding)).first,
    );
    expect(marginPadding.padding.resolve(TextDirection.ltr).bottom, 80);
    expect(find.text('تعذّرت المشاركة'), findsOneWidget);
  });

  testWidgets('toast action does not change route', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: botToastBuilder,
        navigatorObservers: [BotToastNavigatorObserver()],
        theme: AppFoundationTheme.light(),
        routes: {
          '/': (_) => HomeFoundationScope(
                child: Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () => AppToaster.warning(
                        'Retry',
                        action: ToastAction(label: 'Retry', onPressed: () {}),
                      ),
                      child: const Text('warn'),
                    ),
                  ),
                ),
              ),
          '/other': (_) => const Scaffold(body: Text('other')),
        },
      ),
    );
    await tester.pump();
    await tester.tap(find.text('warn'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('other'), findsNothing);
    expect(find.text('Retry'), findsWidgets);
  });
}
