import 'dart:io';
import 'dart:ui' as ui;

import 'package:bnood/app/bnood_app_root.dart';
import 'package:bnood/app/bnood_splash_session.dart';
import 'package:bnood/app/bnood_startup_splash.dart';
import 'package:bnood/core/prefs/app_settings_store.dart';
import 'package:bnood/core/providers/settings_provider.dart';
import 'package:bnood/features/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

AppSettingsSnapshot _testBootstrap({ThemeMode theme = ThemeMode.dark, Locale locale = const Locale('ar')}) =>
    AppSettingsSnapshot(themeMode: theme, locale: locale, prefs: null);

Future<void> _pumpRoot(WidgetTester tester) async {
  BnoodSplashSession.resetForTest();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appSettingsBootstrapProvider.overrideWithValue(_testBootstrap()),
      ],
      child: const BnoodAppRoot(),
    ),
  );
}

Future<void> _writePreviewPng(WidgetTester tester, String path) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byType(RepaintBoundary),
  );
  final image = await boundary.toImage(pixelRatio: 2);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  await File(path).writeAsBytes(data!.buffer.asUint8List());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(BnoodSplashSession.resetForTest);

  testWidgets('splash fades in then out when app is ready', (tester) async {
    await _pumpRoot(tester);
    expect(find.byType(BnoodStartupSplash), findsOneWidget);
    await tester.pump();
    await tester.pump(BnoodStartupSplash.splashFadeInDuration);
    await tester.pump();
    await tester.pump(BnoodStartupSplash.splashFadeOutDuration);
    await tester.pump();
    expect(find.byType(BnoodStartupSplash), findsNothing);
    expect(BnoodSplashSession.completed, isTrue);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('reduced motion skips animation and dismisses on ready', (tester) async {
    BnoodSplashSession.resetForTest();
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: ProviderScope(
          overrides: [
            appSettingsBootstrapProvider.overrideWithValue(_testBootstrap()),
          ],
          child: const BnoodAppRoot(),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(BnoodStartupSplash), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('splash does not replay after session completed', (tester) async {
    await _pumpRoot(tester);
    await tester.pump();
    await tester.pump(BnoodStartupSplash.splashFadeInDuration);
    await tester.pump(BnoodStartupSplash.splashFadeOutDuration);
    await tester.pump();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsBootstrapProvider.overrideWithValue(
            _testBootstrap(theme: ThemeMode.light, locale: const Locale('en')),
          ),
        ],
        child: const BnoodAppRoot(),
      ),
    );
    await tester.pump();
    expect(find.byType(BnoodStartupSplash), findsNothing);
  });

  testWidgets('startup splash still preview artifact', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const BnoodStartupSplash(
        brightness: Brightness.dark,
        locale: Locale('ar'),
        opacity: 1,
      ),
    );
    await tester.pump();
    const out = '/opt/cursor/artifacts/bnood-startup-splash-preview.png';
    await _writePreviewPng(tester, out);
    expect(File(out).existsSync(), isTrue);
    expect(File(out).lengthSync(), greaterThan(1024));
  });
}
