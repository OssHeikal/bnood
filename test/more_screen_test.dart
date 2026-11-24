import 'package:bnood/app/shell_bottom_inset.dart';
import 'package:bnood/core/services/config/theme/app_size.dart';
import 'package:bnood/core/ui/layout/bnood_list_canvas.dart';
import 'package:bnood/core/ui/theme/app_theme.dart';
import 'package:bnood/core/app_state/settings_provider.dart';
import 'package:bnood/core/data/prefs/app_settings_store.dart';
import 'package:bnood/core/account/auth_office_payload.dart';
import 'package:bnood/core/account/office_membership.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/auth_state.dart';
import 'package:bnood/features/auth/models/user.dart';
import 'package:bnood/features/settings/presentation/screens/more_screen.dart';
import 'package:bnood/features/settings/presentation/widgets/app_menu_body.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _AuthUser extends AuthController {
  @override
  AuthState build() => const AuthState(
        bootstrapStatus: AuthBootstrapStatus.authenticated,
        user: User(id: 'u1', phone: '+201012345678', name: 'Osama'),
        bootstrapStarted: true,
      );
}

class _AuthMember extends AuthController {
  @override
  AuthState build() => const AuthState(
        bootstrapStatus: AuthBootstrapStatus.authenticated,
        user: User(id: 'u1', phone: '+201012345678', name: 'Osama'),
        bootstrapStarted: true,
        officeContext: AuthOfficePayload(
          offices: [
            OfficeMembership(
              id: '01J9Z8XQ8K9M2N3P4R5S6T7V8W',
              name: 'مكتب الهيكل',
              readOnly: false,
              isOwner: false,
            ),
          ],
        ),
      );
}

Future<void> pumpMoreWithAuth(
  WidgetTester tester, {
  required AuthController Function() authFactory,
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appSettingsBootstrapProvider.overrideWithValue(
          AppSettingsSnapshot(
            themeMode: ThemeMode.dark,
            locale: const Locale('ar'),
            prefs: prefs,
          ),
        ),
        authControllerProvider.overrideWith(authFactory),
      ],
      child: MaterialApp(
        theme: AppTheme.dark(),
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const MoreScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpMore(WidgetTester tester, {Locale locale = const Locale('ar')}) async {
    await pumpMoreWithAuth(tester, authFactory: _AuthUser.new);
  }

  testWidgets('More list scroll padding clears floating dock', (tester) async {
    await pumpMore(tester);
    final scroll = tester.widget<SingleChildScrollView>(find.byType(SingleChildScrollView));
    final context = tester.element(find.byType(MoreScreen));
    final expectedMin = ShellBottomInset.listScrollBottomPadding(context);
    expect((scroll.padding as EdgeInsets).bottom, expectedMin);
  });

  testWidgets('menu body uses single horizontal gutter on More tab', (tester) async {
    await pumpMore(tester);
    final sections = tester.widgetList<Padding>(
      find.descendant(
        of: find.byType(AppMenuBody),
        matching: find.byWidgetPredicate(
          (w) =>
              w is Padding &&
              w.padding == const EdgeInsets.symmetric(horizontal: AppSize.spaceLG),
        ),
      ),
    );
    expect(sections, isNotEmpty);
    final canvas = tester.widget<BnoodListCanvas>(find.byType(BnoodListCanvas));
    expect(canvas.padding, EdgeInsetsDirectional.zero);
  });

  testWidgets('logout row is reachable by scrolling', (tester) async {
    await pumpMoreWithAuth(tester, authFactory: _AuthUser.new);
    final l10n = AppLocalizations.of(tester.element(find.byType(MoreScreen)));
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -800));
    await tester.pumpAndSettle();
    expect(find.text(l10n.authSignOut), findsOneWidget);
  });

  testWidgets('member sees switch account before sign out', (tester) async {
    await pumpMoreWithAuth(tester, authFactory: _AuthMember.new);
    final l10n = AppLocalizations.of(tester.element(find.byType(MoreScreen)));
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -1200));
    await tester.pumpAndSettle();

    expect(find.text(l10n.accountSwitchMenu), findsOneWidget);
    expect(find.text(l10n.authSignOut), findsOneWidget);
    expect(
      tester.getTopLeft(find.text(l10n.accountSwitchMenu)).dy,
      lessThan(tester.getTopLeft(find.text(l10n.authSignOut)).dy),
    );
  });

  testWidgets('single-account user has no switch row on more', (tester) async {
    await pumpMoreWithAuth(tester, authFactory: _AuthUser.new);
    final l10n = AppLocalizations.of(tester.element(find.byType(MoreScreen)));
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -1200));
    await tester.pumpAndSettle();

    expect(find.text(l10n.accountSwitchMenu), findsNothing);
    expect(find.text(l10n.authSignOut), findsOneWidget);
  });
}