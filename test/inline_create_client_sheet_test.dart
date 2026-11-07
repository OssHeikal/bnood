import 'package:bnood/core/database/connection.dart';
import 'package:bnood/core/providers/app_providers.dart';
import 'package:bnood/core/widgets/custom_bottom_sheet.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/features/vouchers/inline_create_routes.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bnood/core/config/theme/app_size.dart';
import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/widgets/custom_text_field.dart';
import 'package:bnood/core/widgets/entity_picker_page.dart';
import 'package:bnood/core/widgets/text_field/app_input_frame.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpSheet(
    WidgetTester tester, {
    required Locale locale,
    Size surface = const Size(390, 640),
  }) async {
    final db = openTestDatabase();
    addTearDown(db.close);

    await tester.binding.setSurfaceSize(surface);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (hostContext) {
              return HomeFoundationScope(
                child: Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        CustomBottomSheet.show<String?>(
                          context: hostContext,
                          title: AppLocalizations.of(hostContext).addClient,
                          builder: (_) => const InlineCreateClientPage(),
                          nestedNavigator: false,
                        );
                      },
                      child: const Text('Open'),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows one localized title and foundation fields', (tester) async {
    await pumpSheet(tester, locale: const Locale('ar'));

    expect(find.text('إضافة عميل'), findsOneWidget);
    expect(find.byType(AppBar), findsNothing);
    expect(find.byType(CustomTextField), findsNWidgets(2));
    final frames = tester.widgetList<AppInputFrame>(find.byType(AppInputFrame));
    expect(frames.length, greaterThanOrEqualTo(2));
    expect(frames.first.label, 'اسم العميل');
    expect(frames.every((f) => f.height == AppSize.fieldHeightComfortable), isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('EN hints and comfortable field height', (tester) async {
    await pumpSheet(tester, locale: const Locale('en'));

    final frames = tester.widgetList<AppInputFrame>(find.byType(AppInputFrame)).toList();
    expect(frames.length, greaterThanOrEqualTo(2));
    expect(frames[0].label, 'Client name');
    expect(frames[0].floated, isTrue);
    expect(find.text('e.g. Tower North'), findsOneWidget);
    expect(frames[1].label, 'Phone (optional)');
    expect(frames[1].floated, isFalse);
    expect(frames.every((f) => f.height == AppSize.fieldHeightComfortable), isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('large text scale on narrow width', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(openTestDatabase())],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.2), size: Size(320, 560)),
            child: const HomeFoundationScope(
              child: Scaffold(
                body: InlineCreateClientPage(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('اسم العميل'), findsOneWidget);
    expect(find.text('التليفون (اختياري)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty name shows field validation not toast', (tester) async {
    await pumpSheet(tester, locale: const Locale('en'));

    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(find.text('Enter client name'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('narrow layout keeps fields and save without overflow', (tester) async {
    await pumpSheet(tester, locale: const Locale('en'), surface: const Size(320, 560));
    expect(find.text('Save'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('save creates client and pops sheet with id', (tester) async {
    await pumpSheet(tester, locale: const Locale('en'));

    await tester.enterText(find.byType(CustomTextField).first, 'Tower B');
    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.text('Open'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('save dismisses at 440 width with keyboard inset', (tester) async {
    final db = openTestDatabase();
    addTearDown(db.close);
    await tester.binding.setSurfaceSize(const Size(440, 812));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: const MediaQueryData(viewInsets: EdgeInsets.only(bottom: 280), size: Size(440, 812)),
            child: HomeFoundationScope(
              child: Builder(
                builder: (context) {
                  return Scaffold(
                    body: Center(
                      child: ElevatedButton(
                        onPressed: () => CustomBottomSheet.show<String?>(
                          context: context,
                          title: AppLocalizations.of(context).addClient,
                          builder: (_) => const InlineCreateClientPage(),
                          nestedNavigator: false,
                        ),
                        child: const Text('Open'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(CustomTextField).first, 'Inset Client');
    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('Open'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('bounded nested navigator save without overlay exception', (tester) async {
    final db = openTestDatabase();
    addTearDown(db.close);
    await tester.binding.setSurfaceSize(const Size(440, 812));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomeFoundationScope(
            child: Scaffold(
              body: Center(
                child: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () => CustomBottomSheet.show<String?>(
                      context: context,
                      title: AppLocalizations.of(context).addClient,
                      builder: (_) => const InlineCreateClientPage(),
                      nestedNavigator: true,
                    ),
                    child: const Text('Open nested'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open nested'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(CustomTextField).first, 'Nested Save');
    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('Open nested'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('entity picker push create client save pops id', (tester) async {
    final db = openTestDatabase();
    addTearDown(db.close);
    await tester.binding.setSurfaceSize(const Size(440, 812));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomeFoundationScope(
            child: Scaffold(
              body: SizedBox(
                height: 812 * 0.88,
                width: 440,
                child: Navigator(
                  onGenerateRoute: (_) => MaterialPageRoute<String?>(
                    builder: (_) => EntityPickerPage(
                      title: 'Clients',
                      entries: const [],
                      onCreateRoute: () => const InlineCreateClientPage(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create new'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(CustomTextField).first, 'Picker Client');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(tester.takeException(), isNull);
  });
}
