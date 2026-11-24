import 'package:bnood/core/account/account_context_providers.dart';
import 'package:bnood/core/account/account_office_providers.dart';
import 'package:bnood/core/services/config/theme/app_theme.dart';
import 'package:bnood/features/account/presentation/widgets/account_switcher_title.dart';
import 'package:bnood/features/home/presentation/providers/home_dashboard_providers.dart';
import 'package:bnood/features/home/data/home_row_models.dart';
import 'package:bnood/features/home/presentation/screens/home_screen.dart';
import 'package:bnood/features/auth/widgets/user_identity_avatar.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/auth_state.dart';
import 'package:bnood/features/auth/models/user.dart';
import 'package:bnood/features/home/presentation/widgets/home_foundation_scope.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bnood/core/app_state/settings_provider.dart';
import 'package:bnood/core/data/prefs/app_settings_store.dart';

import 'support/home_notifier_stubs.dart';

const _officeId = '01J9Z8XQ8K9M2N3P4R5S6T7V8W';

class _AuthMember extends AuthController {
  @override
  AuthState build() {
    return AuthState(
      bootstrapStatus: AuthBootstrapStatus.authenticated,
      user: const User(id: 'u1', phone: '01000000001', name: 'م/ ياسر مهندس'),
      officeContext: const AuthOfficePayload(
        offices: [
          OfficeMembership(
            id: _officeId,
            name: 'مكتب النور',
            readOnly: false,
            isOwner: false,
          ),
        ],
      ),
    );
  }
}

class _AuthOwner extends AuthController {
  @override
  AuthState build() {
    return AuthState(
      bootstrapStatus: AuthBootstrapStatus.authenticated,
      user: const User(id: 'u2', phone: '01000000002', name: 'المالك'),
      officeContext: const AuthOfficePayload(
        offices: [
          OfficeMembership(
            id: _officeId,
            name: 'مكتب المالك',
            readOnly: true,
            isOwner: true,
          ),
        ],
      ),
    );
  }
}

ProviderContainer _scopeContainer({
  required AuthController Function() authFactory,
  Map<String, Object> prefs = const {},
}) {
  SharedPreferences.setMockInitialValues(prefs);
  return ProviderContainer(
    overrides: [
      authControllerProvider.overrideWith(authFactory),
      appSettingsBootstrapProvider.overrideWithValue(
        AppSettingsSnapshot(
          prefs: null,
          themeMode: ThemeMode.system,
          locale: const Locale('ar'),
        ),
      ),
    ],
  );
}

Future<void> _pumpSwitcherTitle(
  WidgetTester tester, {
  required ProviderContainer container,
}) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HomeFoundationScope(
          child: Scaffold(
            body: AccountSwitcherTitle(displayName: 'تجربة'),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  container.read(accountContextLifecycleProvider);
  await tester.pumpAndSettle();
}

Future<void> _pumpHomeHeader(
  WidgetTester tester, {
  required AuthController Function() authFactory,
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authControllerProvider.overrideWith(authFactory),
        appSettingsBootstrapProvider.overrideWithValue(
          AppSettingsSnapshot(
            prefs: null,
            themeMode: ThemeMode.system,
            locale: const Locale('ar'),
          ),
        ),
        homeTotalsOverride(const HomeTotals(receivedPiastres: 0, spentPiastres: 0)),
        homeActiveProjectsOverride(const []),
        emptyHomeSupplierSpendsOverride(),
        emptyHomeCraftsmenOverride(),
        emptyHomeSuppliersOverride(),
      ],
      child: MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HomeScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    ApiOfficeHeader.syncOfficeId(null);
  });

  testWidgets('member sees account switcher affordance', (tester) async {
    final container = _scopeContainer(
      authFactory: _AuthMember.new,
      prefs: {'bnood.account.selection': _officeId},
    );
    addTearDown(container.dispose);

    await _pumpSwitcherTitle(tester, container: container);

    expect(container.read(accountSwitcherVisibleProvider), isTrue);
    expect(find.byIcon(Icons.expand_more), findsOneWidget);
    expect(find.text('مكتب النور'), findsOneWidget);
  });

  testWidgets('switcher title shows identity avatar beside chevron', (
    tester,
  ) async {
    final container = _scopeContainer(
      authFactory: _AuthMember.new,
      prefs: {'bnood.account.selection': _officeId},
    );
    addTearDown(container.dispose);

    await _pumpSwitcherTitle(tester, container: container);

    expect(find.byType(UserIdentityAvatar), findsOneWidget);
    expect(find.byIcon(Icons.expand_more), findsOneWidget);
  });

  testWidgets('named member on home keeps switcher chevron', (tester) async {
    await _pumpHomeHeader(
      tester,
      authFactory: _AuthMember.new,
      prefs: {'bnood.account.selection': _officeId},
    );

    expect(find.byIcon(Icons.expand_more), findsOneWidget);
    expect(
      find.text('مكتب النور'),
      findsOneWidget,
      reason: 'office context shows office title with switcher affordance',
    );
  });

  testWidgets('owner sees office title without switcher', (tester) async {
    final container = _scopeContainer(
      authFactory: _AuthOwner.new,
      prefs: {'bnood.account.selection': 'personal'},
    );
    addTearDown(container.dispose);

    await _pumpSwitcherTitle(tester, container: container);

    expect(container.read(accountSwitcherVisibleProvider), isFalse);
    expect(container.read(accountContextProvider).isPersonal, isFalse);
    expect(container.read(accountContextProvider).officeId, _officeId);
    expect(find.byIcon(Icons.expand_more), findsNothing);
    expect(find.text('مكتب المالك'), findsOneWidget);
    expect(find.text('شخصي'), findsNothing);
  });
}