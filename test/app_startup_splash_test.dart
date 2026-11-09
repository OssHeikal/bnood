import 'dart:async';
import 'package:bnood/app/bnood_app.dart';
import 'package:bnood/core/brand/app_brand_lockup.dart';
import 'package:bnood/app/app_splash_session.dart';
import 'package:bnood/app/app_startup_splash.dart';
import 'package:bnood/core/api/app_dio.dart';
import 'package:bnood/core/api/auth_api.dart';
import 'package:bnood/core/api/auth_api_providers.dart';
import 'package:bnood/core/prefs/app_settings_store.dart';
import 'package:bnood/core/providers/settings_provider.dart';
import 'package:bnood/core/storage/session_store.dart';
import 'package:bnood/features/auth/complete_profile_screen.dart';
import 'package:bnood/features/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_session_store.dart';
import 'support/scripted_dio_adapter.dart';

AppSettingsSnapshot _testBootstrap({
  ThemeMode theme = ThemeMode.dark,
  Locale locale = const Locale('ar'),
}) => AppSettingsSnapshot(themeMode: theme, locale: locale, prefs: null);

AuthApi _authApiWithDelayedMe(
  FakeSessionStore store, {
  required Completer<void> gate,
}) {
  final dio = createAppDio(store);
  dio.httpClientAdapter = ScriptedDioAdapter((options) async {
    if (options.path.endsWith('/me')) {
      await gate.future;
      return jsonResponse(
        '{"success":true,"data":{"id":"usr","phone":"+201012345678"}}',
      );
    }
    return jsonResponse('{"success":false}', statusCode: 404);
  });
  return AuthApi(dio: dio);
}

AuthApi _hangingMeApi(FakeSessionStore store) {
  final dio = createAppDio(store);
  dio.httpClientAdapter = ScriptedDioAdapter((options) async {
    if (options.path.endsWith('/me')) {
      final never = Completer<ResponseBody>();
      return never.future;
    }
    return jsonResponse('{"success":false}', statusCode: 404);
  });
  return AuthApi(dio: dio);
}

Future<void> _pumpRoot(
  WidgetTester tester, {
  List<Override> overrides = const [],
}) async {
  AppSplashSession.resetForTest();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appSettingsBootstrapProvider.overrideWithValue(_testBootstrap()),
        sessionStoreProvider.overrideWithValue(FakeSessionStore()),
        ...overrides,
      ],
      child: const BnoodApp(),
    ),
  );
}

Future<void> _pumpUntil(
  WidgetTester tester,
  bool Function() done, {
  int maxTicks = 400,
}) async {
  for (var i = 0; i < maxTicks; i++) {
    if (done()) return;
    await tester.pump(const Duration(milliseconds: 50));
  }
  expect(done(), isTrue, reason: 'condition not met before timeout');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(AppSplashSession.resetForTest);

  testWidgets('unauthenticated session lands on login after splash', (tester) async {
    await _pumpRoot(tester);
    expect(find.byType(AppStartupSplashPage), findsOneWidget);
    await _pumpUntil(tester, () => find.byType(LoginScreen).evaluate().isNotEmpty);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(AppStartupSplashPage), findsNothing);
    expect(AppSplashSession.completed, isTrue);
  });

  testWidgets('splash holds until bootstrap resolves when token is present', (tester) async {
    final store = FakeSessionStore(token: 'secret-token');
    final gate = Completer<void>();
    addTearDown(() {
      if (!gate.isCompleted) gate.complete();
    });
    await _pumpRoot(
      tester,
      overrides: [
        sessionStoreProvider.overrideWithValue(store),
        authApiProvider.overrideWithValue(_authApiWithDelayedMe(store, gate: gate)),
      ],
    );
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.byType(AppStartupSplashPage), findsOneWidget);
    expect(find.byType(CompleteProfileScreen), findsNothing);
    gate.complete();
    await tester.pump();
    await _pumpUntil(
      tester,
      () => find.byType(CompleteProfileScreen).evaluate().isNotEmpty,
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(AppStartupSplashPage), findsNothing);
  });

  testWidgets('bootstrap timeout routes to login', (tester) async {
    final store = FakeSessionStore(token: 'stale-token');
    await _pumpRoot(
      tester,
      overrides: [
        sessionStoreProvider.overrideWithValue(store),
        authApiProvider.overrideWithValue(_hangingMeApi(store)),
      ],
    );
    await tester.pump(AppStartupSplash.splashBootstrapTimeout);
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(AppStartupSplashPage), findsNothing);
  });

  testWidgets('reduced motion still waits for session then login', (tester) async {
    AppSplashSession.resetForTest();
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: ProviderScope(
          overrides: [
            appSettingsBootstrapProvider.overrideWithValue(_testBootstrap()),
            sessionStoreProvider.overrideWithValue(FakeSessionStore()),
          ],
          child: const BnoodApp(),
        ),
      ),
    );
    expect(find.byType(AppStartupSplashPage), findsOneWidget);
    await _pumpUntil(tester, () => find.byType(LoginScreen).evaluate().isNotEmpty);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(AppStartupSplashPage), findsNothing);
  });

  testWidgets('splash canvas stays fully opaque while visible', (tester) async {
    await _pumpRoot(tester);
    final canvas = tester.widget<ColoredBox>(
      find.descendant(
        of: find.byType(AppStartupSplash),
        matching: find.byType(ColoredBox),
      ),
    );
    expect(canvas.color.a, 1.0);
    await _pumpUntil(tester, () => find.byType(LoginScreen).evaluate().isNotEmpty);
  });

  testWidgets('splash does not replay after session completed', (tester) async {
    await _pumpRoot(tester);
    await _pumpUntil(tester, () => find.byType(LoginScreen).evaluate().isNotEmpty);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsBootstrapProvider.overrideWithValue(
            _testBootstrap(theme: ThemeMode.light, locale: const Locale('en')),
          ),
          sessionStoreProvider.overrideWithValue(FakeSessionStore()),
        ],
        child: const BnoodApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(AppStartupSplashPage), findsNothing);
  });

  testWidgets('startup splash renders branded hero lockup', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const AppStartupSplash(
        brightness: Brightness.dark,
        locale: Locale('ar'),
        logoOpacity: 1,
      ),
    );
    await tester.pump();
    expect(find.byType(AppStartupSplash), findsOneWidget);
    expect(find.byType(AppBrandLockup), findsOneWidget);
    expect(find.byType(RepaintBoundary), findsOneWidget);
  });
}
