import 'package:bnood/core/api/app_dio.dart';
import 'package:bnood/core/api/auth_api.dart';
import 'package:bnood/core/api/auth_api_providers.dart';
import 'package:bnood/core/storage/session_store.dart';
import 'package:bnood/core/theme/app_theme.dart';
import 'package:bnood/features/auth/auth_paths.dart';
import 'package:bnood/features/auth/register_screen.dart';
import 'package:bnood/features/auth/register_verify_screen.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:bnood/core/widgets/buttons/app_button.dart';

import 'support/fake_session_store.dart';
import 'support/scripted_dio_adapter.dart';

AuthApi _registerOnlyApi(FakeSessionStore store) {
  final dio = createAppDio(store);
  dio.httpClientAdapter = ScriptedDioAdapter((options) async {
    if (options.path.endsWith('/register') && !options.path.contains('verify')) {
      return jsonResponse(
        '{"success":true,"data":{"registration_id":"reg_1","expires_in":600,"resend_after":0}}',
        statusCode: 202,
      );
    }
    return jsonResponse('{"success":false,"message":"unexpected"}', statusCode: 400);
  });
  return AuthApi(dio: dio);
}

void main() {
  testWidgets('register clears loading after push so back shows idle button', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final store = FakeSessionStore();
    final router = GoRouter(
      initialLocation: AuthPaths.register,
      routes: [
        GoRoute(
          path: AuthPaths.register,
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: AuthPaths.registerVerify,
          builder: (context, state) => const RegisterVerifyScreen(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionStoreProvider.overrideWithValue(store),
          authApiProvider.overrideWithValue(_registerOnlyApi(store)),
        ],
        child: HomeFoundationScope(
          child: MaterialApp.router(
            theme: AppTheme.light(),
            locale: const Locale('en'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      ),
    );
    await tester.pump();

    final fields = find.byType(EditableText);
    await tester.enterText(fields.at(0), '01012345678');
    await tester.enterText(fields.at(1), 'password123');
    await tester.enterText(fields.at(2), 'password123');

    await tester.tap(find.widgetWithText(AppButton, 'Create account'));
    var onVerify = false;
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (find.text('Verification code').evaluate().isNotEmpty) {
        onVerify = true;
        break;
      }
    }
    expect(onVerify, isTrue, reason: 'expected navigation to register verify');

    await tester.pageBack();
    await tester.pump();

    final button = tester.widget<AppButton>(find.widgetWithText(AppButton, 'Create account'));
    expect(button.isLoading, isFalse);
    expect(button.onPressed, isNotNull);
  });
}
