import 'package:bnood/core/api/app_dio.dart';
import 'package:bnood/core/api/auth_api.dart';
import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/prefs/app_settings_store.dart';
import 'package:bnood/core/providers/settings_provider.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/auth_paths.dart';
import 'package:bnood/features/auth/auth_state.dart';
import 'package:bnood/features/auth/change_password_screen.dart';
import 'package:bnood/features/auth/models/user.dart';
import 'package:bnood/features/auth/user_profile_screen.dart';
import 'package:bnood/features/auth/widgets/user_identity_avatar.dart';
import 'package:bnood/features/settings/app_settings_screen.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_session_store.dart';
import 'support/scripted_dio_adapter.dart';

Future<void> pumpUserProfile(WidgetTester tester, User user) async {
  await tester.binding.setSurfaceSize(const Size(390, 1400));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [authControllerProvider.overrideWith(() => _AuthUserWith(user))],
      child: MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const UserProfileScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UserProfileScreen', () {
    testWidgets('shows hierarchy and uppercase initials', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authControllerProvider.overrideWith(_AuthUser.new)],
          child: MaterialApp(
            theme: AppFoundationTheme.light(),
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const UserProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(UserIdentityAvatar), findsOneWidget);
      expect(find.text('OH'), findsOneWidget);
      expect(find.text('Full name'), findsWidgets);
      expect(find.text('Change password'), findsOneWidget);
      expect(find.text('Delete account'), findsOneWidget);
      expect(find.text('Client name'), findsNothing);
      expect(find.text('Your details on statements'), findsOneWidget);
      expect(find.text('Shown to your client at the top of the statement'), findsOneWidget);
      expect(find.text('Contact phone'), findsOneWidget);
    });

    testWidgets('statement branding — no logo, no contact phone', (tester) async {
      await pumpUserProfile(tester, const User(id: 'u1', phone: '+201012345678', name: 'Osama heikal'));
      expect(find.text('No logo added yet'), findsOneWidget);
      expect(find.text('No number will appear on statements'), findsOneWidget);
      expect(find.text('Add'), findsNWidgets(2));
      expect(find.text('Change'), findsNothing);
    });

    testWidgets('statement branding — logo set, no contact phone', (tester) async {
      await pumpUserProfile(
        tester,
        const User(id: 'u1', phone: '+201012345678', name: 'Osama heikal', logoUrl: 'https://cdn.example/logo.png'),
      );
      expect(find.text('Logo added'), findsOneWidget);
      expect(find.text('Change'), findsOneWidget);
      expect(find.text('No number will appear on statements'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
    });

    testWidgets('statement branding — no logo, contact phone set', (tester) async {
      await pumpUserProfile(
        tester,
        const User(id: 'u1', phone: '+201012345678', name: 'Osama heikal', contactPhone: '+201234567890'),
      );
      expect(find.text('No logo added yet'), findsOneWidget);
      expect(find.textContaining('201234567890'), findsOneWidget);
      expect(find.text('Edit'), findsWidgets);
      expect(find.text('Add'), findsOneWidget);
    });

    testWidgets('statement branding — logo and contact phone set', (tester) async {
      await pumpUserProfile(
        tester,
        const User(
          id: 'u1',
          phone: '+201012345678',
          name: 'Osama heikal',
          logoUrl: 'https://cdn.example/logo.png',
          contactPhone: '+201234567890',
        ),
      );
      expect(find.text('Logo added'), findsOneWidget);
      expect(find.textContaining('201234567890'), findsOneWidget);
      expect(find.text('Change'), findsOneWidget);
      expect(find.text('Edit'), findsNWidgets(2));
      expect(find.text('Add'), findsNothing);
    });

    testWidgets('change password navigates to existing screen', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final router = GoRouter(
        routes: [
          GoRoute(path: AuthPaths.profile, builder: (_, _) => const UserProfileScreen()),
          GoRoute(path: AuthPaths.changePassword, builder: (_, _) => const ChangePasswordScreen()),
        ],
        initialLocation: AuthPaths.profile,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [authControllerProvider.overrideWith(_AuthUser.new)],
          child: MaterialApp.router(
            theme: AppFoundationTheme.light(),
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Change password'));
      await tester.pumpAndSettle();
      expect(find.byType(ChangePasswordScreen), findsOneWidget);
    });
  });

  group('Settings logout', () {
    testWidgets('sign out shows confirm dialog', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final bootstrap = AppSettingsSnapshot(
        themeMode: ThemeMode.system,
        locale: const Locale('en'),
        prefs: prefs,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(_AuthUser.new),
            appSettingsBootstrapProvider.overrideWithValue(bootstrap),
          ],
          child: MaterialApp(
            theme: AppFoundationTheme.light(),
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AppSettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sign out'), findsOneWidget);
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();
      expect(find.text('Sign out?'), findsOneWidget);
    });
  });

  group('AuthApi deleteAccount', () {
    test('POST delete-account sends current_password', () async {
      final store = FakeSessionStore(token: 'tok');
      final dio = createAppDio(store);
      dio.httpClientAdapter = ScriptedDioAdapter((options) async {
        expect(options.method, 'POST');
        expect(options.path.endsWith('/delete-account'), isTrue);
        expect((options.data as Map)['current_password'], 'Secret1!');
        return jsonResponse('{"success":true,"message":"ok","data":null}');
      });
      final liveApi = AuthApi(dio: dio);
      await liveApi.deleteAccount(currentPassword: 'Secret1!');
      liveApi.close();
    });
  });
}

class _AuthUser extends AuthController {
  @override
  AuthState build() => AuthState(
        bootstrapStatus: AuthBootstrapStatus.authenticated,
        user: const User(id: 'u1', phone: '+201012345678', name: 'Osama heikal'),
        bootstrapStarted: true,
      );
}

class _AuthUserWith extends AuthController {
  _AuthUserWith(this.user);

  final User user;

  @override
  AuthState build() => AuthState(
        bootstrapStatus: AuthBootstrapStatus.authenticated,
        user: user,
        bootstrapStarted: true,
      );
}
