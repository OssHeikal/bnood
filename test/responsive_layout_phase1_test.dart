import 'package:bnood/core/database/connection.dart';
import 'package:bnood/core/layout/bnood_breakpoints.dart';
import 'package:bnood/core/layout/bnood_layout.dart';
import 'package:bnood/core/providers/app_providers.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:bnood/core/widgets/bnood_modal_sheet.dart';
import 'package:bnood/core/widgets/custom_text_field.dart';
import 'package:bnood/features/auth/login_screen.dart';
import 'package:bnood/features/auth/widgets/auth_flow_scaffold.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/features/vouchers/voucher_launcher.dart';
import 'package:bnood/features/vouchers/voucher_screen.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';

void _setSurface(WidgetTester tester, double width, {double textScale = 1.0}) {
  tester.binding.window.physicalSizeTestValue = Size(width, 900);
  tester.binding.window.devicePixelRatioTestValue = 1.0;
  addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
  addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(() => tester.platformDispatcher.textScaleFactorTestValue = 1.0);
}

Widget _wrap({
  required Widget child,
  Locale locale = const Locale('ar'),
  double textScale = 1.0,
}) {
  return ProviderScope(
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, appChild) {
        final media = MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale));
        return MediaQuery(
          data: media,
          child: ResponsiveBreakpoints.builder(
            breakpoints: BnoodBreakpoints.all,
            child: appChild!,
          ),
        );
      },
      home: child,
    ),
  );
}

Future<void> _openVoucher(WidgetTester tester, BnoodRepository repo) async {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, _) => HomeFoundationScope(
          child: Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => VoucherLauncher.openFresh(context),
                child: const Text('trigger'),
              ),
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
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) {
          return ResponsiveBreakpoints.builder(
            breakpoints: BnoodBreakpoints.all,
            child: child!,
          );
        },
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('trigger'));
  await tester.pumpAndSettle();
}

void main() {
  late BnoodRepository repo;

  setUp(() {
    final db = openTestDatabase();
    repo = BnoodRepository(db);
    addTearDown(db.close);
  });

  testWidgets('helpers assume mobile without ResponsiveBreakpoints', (tester) async {
    _setSurface(tester, 1024);
    late bool mobile;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            mobile = context.isBnoodMobile;
            return const SizedBox();
          },
        ),
      ),
    );
    expect(mobile, isTrue);
  });

  for (final width in [390.0, 768.0, 1024.0]) {
    testWidgets('modal sheet width at $width', (tester) async {
      _setSurface(tester, width);
      await tester.pumpWidget(
        _wrap(
          child: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () {
                    BnoodModalSheet.show(
                      context: context,
                      builder: (_) => const SizedBox(height: 120, child: Text('sheet-body')),
                    );
                  },
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      if (width <= BnoodBreakpoints.mobileMax) {
        expect(find.byType(ConstrainedBox), findsWidgets);
      } else {
        final boxes = tester.widgetList<ConstrainedBox>(find.byType(ConstrainedBox));
        expect(
          boxes.any((b) => b.constraints.maxWidth == BnoodLayout.formMaxWidth),
          isTrue,
        );
        final panel = find.byWidgetPredicate(
          (w) => w is ConstrainedBox && w.constraints.maxWidth == BnoodLayout.formMaxWidth,
        );
        final size = tester.getSize(panel.first);
        expect(size.width, lessThanOrEqualTo(BnoodLayout.formMaxWidth));
      }
    });
  }

  testWidgets('voucher body capped at 1024', (tester) async {
    _setSurface(tester, 1024);
    await _openVoucher(tester, repo);
    final panel = find.byWidgetPredicate((w) => w is SizedBox && w.width == BnoodLayout.formMaxWidth);
    expect(panel, findsOneWidget);
    expect(tester.getSize(panel).width, lessThanOrEqualTo(BnoodLayout.formMaxWidth));
  });

  testWidgets('voucher calendar day cell under 80px at 1024', (tester) async {
    _setSurface(tester, 1024);
    await _openVoucher(tester, repo);
    await tester.tap(find.text('التاريخ'));
    await tester.pumpAndSettle(const Duration(milliseconds: 400));
    final day = find.byWidgetPredicate(
      (w) => w.key is ValueKey && (w.key! as ValueKey).value.toString().startsWith('voucher-day-'),
    );
    expect(day, findsWidgets);
    expect(tester.getSize(day.first).width, lessThan(80));
  });

  testWidgets('Arabic RTL auth shell', (tester) async {
    _setSurface(tester, 1024);
    await tester.pumpWidget(
      _wrap(
        child: const LoginScreen(),
      ),
    );
    await tester.pumpAndSettle();
    final direction = tester.widget<Directionality>(find.byType(Directionality).first);
    expect(direction.textDirection, TextDirection.rtl);
  });

  testWidgets('text scale 1.3 with responsive wrapper', (tester) async {
    _setSurface(tester, 1024, textScale: 1.3);
    await tester.pumpWidget(
      _wrap(
        textScale: 1.3,
        child: AuthFlowScaffold(
          title: 'title',
          child: const Text('body'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.widget<MediaQuery>(find.byType(MediaQuery).first).data.textScaler.scale(14), closeTo(18.2, 0.5));
  });

  testWidgets('keyboard inset scrolls auth shell', (tester) async {
    _setSurface(tester, 390);
    await tester.pumpWidget(
      _wrap(
        child: AuthFlowScaffold(
          child: CustomTextField(
            label: 'email',
            placeholder: 'email',
          ),
        ),
      ),
    );
    await tester.tap(find.byType(CustomTextField));
    await tester.showKeyboard(find.byType(EditableText));
    await tester.pumpAndSettle();
    final scroll = tester.widget<SingleChildScrollView>(find.byType(SingleChildScrollView));
    final pad = scroll.padding as EdgeInsets;
    expect(pad.bottom, greaterThan(0));
  });
}
