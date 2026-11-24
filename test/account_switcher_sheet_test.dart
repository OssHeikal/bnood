import 'package:bnood/core/account/auth_office_payload.dart';
import 'package:bnood/core/account/office_membership.dart';
import 'package:bnood/core/app_state/settings_provider.dart';
import 'package:bnood/core/data/prefs/app_settings_store.dart';
import 'package:bnood/core/services/config/theme/app_size.dart';
import 'package:bnood/core/services/config/theme/app_theme.dart';
import 'package:bnood/core/ui/widgets/app_modal_sheet.dart';
import 'package:bnood/features/account/presentation/account_switcher_actions.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/home/data/home_row_models.dart';
import 'package:bnood/features/home/presentation/screens/home_screen.dart';
import 'package:bnood/features/settings/presentation/screens/more_screen.dart';
import 'package:bnood/features/auth/auth_state.dart';
import 'package:bnood/features/auth/models/user.dart';
import 'package:bnood/features/home/presentation/widgets/home_foundation_scope.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/home_notifier_stubs.dart';

const _officeId = '01J9Z8XQ8K9M2N3P4R5S6T7V8W';
const _homeIndicator = 34.0;

class _MemberAuth extends AuthController {
  @override
  AuthState build() {
    return const AuthState(
      bootstrapStatus: AuthBootstrapStatus.authenticated,
      user: User(id: 'u1', phone: '01000000001', name: 'أ. محمد'),
      officeContext: AuthOfficePayload(
        offices: [
          OfficeMembership(
            id: _officeId,
            name: 'مكتب الهيكل للتشطيبات',
            readOnly: false,
            isOwner: false,
          ),
        ],
      ),
    );
  }
}

MediaQueryData _iphoneInsets({double bottom = _homeIndicator}) {
  return MediaQueryData(
    size: const Size(390, 844),
    padding: EdgeInsets.only(bottom: bottom),
    viewPadding: EdgeInsets.only(bottom: bottom),
  );
}

void expectHomeIndicatorInset(WidgetTester tester, {double inset = _homeIndicator}) {
  final spacer = tester.widget<SizedBox>(find.byKey(AppModalSheet.bottomInsetKey));
  expect(spacer.height, AppSize.spaceMD + inset);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpModal(
    WidgetTester tester, {
    double bottomViewPadding = _homeIndicator,
    double bottomPadding = _homeIndicator,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsBootstrapProvider.overrideWithValue(
            const AppSettingsSnapshot(
              themeMode: ThemeMode.dark,
              locale: Locale('ar'),
              prefs: null,
            ),
          ),
          authControllerProvider.overrideWith(_MemberAuth.new),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.dark(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: _iphoneInsets(bottom: bottomViewPadding).copyWith(
              padding: EdgeInsets.only(bottom: bottomPadding),
            ),
            child: child ?? const SizedBox.shrink(),
          ),
          home: const HomeFoundationScope(child: _AccountSwitcherSheetHost()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(_AccountSwitcherSheetHost.openKey));
    await tester.pumpAndSettle();
  }

  testWidgets('account switcher modal lists scopes with subtitles', (tester) async {
    await pumpModal(tester);

    expect(find.text('اختر الحساب'), findsOneWidget);
    expect(find.text('شخصي'), findsOneWidget);
    expect(find.text('مكتب'), findsOneWidget);
    expect(find.text('مكتب الهيكل للتشطيبات'), findsOneWidget);
  });

  testWidgets('account switcher modal keeps last row above home indicator',
      (tester) async {
    await pumpModal(tester, bottomViewPadding: _homeIndicator);

    expectHomeIndicatorInset(tester);

    final lastRow = tester.renderObject<RenderBox>(
      find.text('مكتب الهيكل للتشطيبات'),
    );
    final lastBottom = lastRow.localToGlobal(Offset(0, lastRow.size.height)).dy;
    expect(lastBottom, lessThanOrEqualTo(844 - _homeIndicator - AppSize.spaceMD + 1));
  });

  testWidgets('account switcher modal uses spacing only when no home indicator',
      (tester) async {
    await pumpModal(tester, bottomViewPadding: 0, bottomPadding: 0);

    expectHomeIndicatorInset(tester, inset: 0);
  });

  testWidgets('home app bar title opens switcher with bottom inset', (tester) async {
    SharedPreferences.setMockInitialValues({
      'bnood.account.selection': _officeId,
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsBootstrapProvider.overrideWithValue(
            const AppSettingsSnapshot(
              themeMode: ThemeMode.dark,
              locale: Locale('ar'),
              prefs: null,
            ),
          ),
          authControllerProvider.overrideWith(_MemberAuth.new),
          homeTotalsOverride(const HomeTotals(receivedPiastres: 0, spentPiastres: 0)),
          homeActiveProjectsOverride(const []),
          emptyHomeSupplierSpendsOverride(),
          emptyHomeCraftsmenOverride(),
          emptyHomeSuppliersOverride(),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.dark(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: _iphoneInsets(),
            child: child ?? const SizedBox.shrink(),
          ),
          home: const HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pumpAndSettle();

    expect(find.text('اختر الحساب'), findsOneWidget);
    expectHomeIndicatorInset(tester);
  });

  testWidgets('more menu opens same switcher with bottom inset', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsBootstrapProvider.overrideWithValue(
            const AppSettingsSnapshot(
              themeMode: ThemeMode.dark,
              locale: Locale('ar'),
              prefs: null,
            ),
          ),
          authControllerProvider.overrideWith(_MemberAuth.new),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.dark(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: _iphoneInsets(),
            child: child ?? const SizedBox.shrink(),
          ),
          home: const MoreScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(tester.element(find.byType(MoreScreen)));
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -1200));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.accountSwitchMenu));
    await tester.pumpAndSettle();

    expect(find.text('اختر الحساب'), findsOneWidget);
    expectHomeIndicatorInset(tester);
  });
}

class _AccountSwitcherSheetHost extends ConsumerWidget {
  const _AccountSwitcherSheetHost();

  static const openKey = Key('open_account_switcher_sheet');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => showAccountSwitcherSheet(context, ref),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('م/ ياسر مهندس'),
              Icon(Icons.expand_more),
            ],
          ),
        ),
      ),
      body: Center(
        child: TextButton(
          key: openKey,
          onPressed: () => showAccountSwitcherSheet(context, ref),
          child: const Text('Open'),
        ),
      ),
    );
  }
}