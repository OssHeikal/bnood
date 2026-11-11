import 'package:bnood/core/config/theme/app_size.dart';
import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/database/connection.dart';
import 'package:bnood/core/providers/app_providers.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:bnood/core/widgets/buttons/app_button.dart';
import 'package:bnood/core/widgets/bounded_sheet_navigator.dart';
import 'package:bnood/core/widgets/entity_picker_page.dart';
import 'package:bnood/core/widgets/overlay_form_presentation.dart';
import 'package:bnood/core/widgets/sheet_drag_handle.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/features/vouchers/inline_create_routes.dart';
import 'package:bnood/features/vouchers/voucher_launcher.dart';
import 'package:bnood/features/vouchers/voucher_screen.dart';
import 'package:bnood/features/vouchers/voucher_sheet.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Notch + home indicator, typical iPhone overlay surface.
const _topInset = 59.0;
const _bottomInset = 34.0;

void _applyDeviceInsets(WidgetTester tester) {
  tester.view.padding = const FakeViewPadding(top: _topInset, bottom: _bottomInset);
  tester.view.viewPadding = const FakeViewPadding(top: _topInset, bottom: _bottomInset);
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Future<void> _pumpHomeWithVoucherTrigger(WidgetTester tester, {required BnoodRepository repo}) async {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, _) => HomeFoundationScope(
          child: Scaffold(
            body: Center(
              child: FilledButton(onPressed: () => VoucherLauncher.openFresh(context), child: const Text('trigger')),
            ),
          ),
        ),
      ),
      GoRoute(path: VoucherScreen.path, builder: (_, __) => const VoucherScreen()),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [repositoryProvider.overrideWithValue(repo)],
      child: MaterialApp.router(
        theme: AppFoundationTheme.light(),
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  late BnoodRepository repo;

  setUp(() {
    final db = openTestDatabase();
    repo = BnoodRepository(db);
    addTearDown(db.close);
  });

  testWidgets('production openFresh full screen keeps title below status bar', (tester) async {
    _applyDeviceInsets(tester);
    await _pumpHomeWithVoucherTrigger(tester, repo: repo);

    await tester.tap(find.text('trigger'));
    await tester.pumpAndSettle();

    expect(find.byType(VoucherSheet), findsOneWidget);
    expect(find.byType(SheetDragHandle), findsNothing);
    final titleTop = tester.getTopLeft(find.text('سند صرف')).dy;
    expect(titleTop, greaterThanOrEqualTo(_topInset));
    expect(tester.takeException(), isNull);
  });

  testWidgets('production modal with useSafeArea false would overlap (regression)', (tester) async {
    _applyDeviceInsets(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [repositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () {
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: false,
                      showDragHandle: false,
                      builder: (_) => const SafeArea(bottom: false, child: VoucherSheet()),
                    );
                  },
                  child: const Text('bad'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('bad'));
    await tester.pumpAndSettle();

    final handleTop = tester.getTopLeft(find.byType(SheetDragHandle)).dy;
    expect(handleTop, lessThan(_topInset));
  });

  testWidgets('nested picker route below safe top (production modal flags)', (tester) async {
    _applyDeviceInsets(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [repositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () {
                    showModalBottomSheet<void>(
                      context: context,
                      useRootNavigator: true,
                      isScrollControlled: true,
                      showDragHandle: false,
                      useSafeArea: true,
                      builder: (_) => HomeFoundationScope(
                        child: BoundedSheetNavigator(
                          builder: (_) => EntityPickerPage(
                            title: 'العملاء',
                            entries: const [('1', 'Osama')],
                            onCreateRoute: () => const SizedBox(),
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('picker'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('picker'));
    await tester.pumpAndSettle();

    final handleTop = tester.getTopLeft(find.byType(SheetDragHandle)).dy;
    expect(handleTop, greaterThanOrEqualTo(_topInset));
    expect(tester.takeException(), isNull);
  });

  testWidgets('inline create route below safe top (production modal flags)', (tester) async {
    _applyDeviceInsets(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [repositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () {
                    showModalBottomSheet<void>(
                      context: context,
                      useRootNavigator: true,
                      isScrollControlled: true,
                      showDragHandle: false,
                      useSafeArea: true,
                      builder: (_) => HomeFoundationScope(
                        child: BoundedSheetNavigator(builder: (_) => const InlineCreateSupplierPage()),
                      ),
                    );
                  },
                  child: const Text('create'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('create'));
    await tester.pumpAndSettle();

    final handleTop = tester.getTopLeft(find.byType(SheetDragHandle)).dy;
    expect(handleTop, greaterThanOrEqualTo(_topInset));
    expect(tester.takeException(), isNull);
  });

  testWidgets('save footer above home indicator on full-screen voucher', (tester) async {
    _applyDeviceInsets(tester);
    await _pumpHomeWithVoucherTrigger(tester, repo: repo);
    await tester.tap(find.text('trigger'));
    await tester.pumpAndSettle();

    final footer = tester.getRect(find.byType(AppButton).last);
    expect(footer.bottom, lessThanOrEqualTo(844 - _bottomInset + 1));
  });

  testWidgets('full-screen nested client picker respects system insets', (tester) async {
    _applyDeviceInsets(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [repositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: EntityPickerPage(
            title: 'العملاء',
            presentation: OverlayFormPresentation.fullScreen,
            entries: const [('1', 'Osama')],
            onCreateRoute: () => const SizedBox(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SheetDragHandle), findsNothing);
    final titleTop = tester.getTopLeft(find.text('العملاء')).dy;
    expect(titleTop, greaterThanOrEqualTo(_topInset));
    final createAction = find.text('إنشاء جديد');
    if (createAction.evaluate().isNotEmpty) {
      final createBottom = tester.getBottomLeft(createAction).dy;
      expect(createBottom, lessThanOrEqualTo(844 - _bottomInset + 1));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('full-screen inline supplier create respects system insets', (tester) async {
    _applyDeviceInsets(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [repositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const InlineCreateSupplierPage(presentation: OverlayFormPresentation.fullScreen),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SheetDragHandle), findsNothing);
    expect(find.text('إضافة مورد'), findsOneWidget);
    final titleTop = tester.getTopLeft(find.text('إضافة مورد')).dy;
    expect(titleTop, greaterThanOrEqualTo(_topInset));
    final save = tester.getRect(find.byType(AppButton));
    expect(save.bottom, lessThanOrEqualTo(844 - _bottomInset + 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('keyboard lifts footer on full-screen voucher', (tester) async {
    _applyDeviceInsets(tester);
    const keyboard = 336.0;
    tester.view.viewInsets = const FakeViewPadding(bottom: keyboard);

    await _pumpHomeWithVoucherTrigger(tester, repo: repo);
    await tester.tap(find.text('trigger'));
    await tester.pumpAndSettle();

    final footer = tester.getRect(find.byType(AppButton).last);
    final liftedCap = 844 - keyboard - AppSize.spaceMD;
    expect(footer.bottom, lessThanOrEqualTo(liftedCap + 1));
  });
}
