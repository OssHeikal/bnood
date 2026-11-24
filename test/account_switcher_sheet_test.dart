import 'package:bnood/core/account/account_scope.dart';
import 'package:bnood/core/account/auth_office_payload.dart';
import 'package:bnood/core/account/office_membership.dart';
import 'package:bnood/core/app_state/settings_provider.dart';
import 'package:bnood/core/data/prefs/app_settings_store.dart';
import 'package:bnood/core/services/config/theme/app_size.dart';
import 'package:bnood/core/services/config/theme/app_theme.dart';
import 'package:bnood/core/ui/widgets/app_modal_sheet.dart';
import 'package:bnood/features/account/presentation/sheets/account_switcher_sheet.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/auth_state.dart';
import 'package:bnood/features/auth/models/user.dart';
import 'package:bnood/features/home/presentation/widgets/home_foundation_scope.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(390, 844),
              padding: EdgeInsets.only(bottom: bottomPadding),
              viewPadding: EdgeInsets.only(bottom: bottomViewPadding),
            ),
            child: const HomeFoundationScope(
              child: _AccountSwitcherSheetHost(),
            ),
          ),
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

    final inset = tester.widget<SizedBox>(find.byKey(AppModalSheet.bottomInsetKey));
    expect(inset.height, AppSize.spaceMD + _homeIndicator);

    final lastRow = tester.renderObject<RenderBox>(
      find.text('مكتب الهيكل للتشطيبات'),
    );
    final lastBottom = lastRow.localToGlobal(Offset(0, lastRow.size.height)).dy;
    expect(lastBottom, lessThanOrEqualTo(844 - _homeIndicator - AppSize.spaceMD + 1));
  });

  testWidgets('account switcher modal uses spacing only when no home indicator',
      (tester) async {
    await pumpModal(tester, bottomViewPadding: 0, bottomPadding: 0);

    final inset = tester.widget<SizedBox>(find.byKey(AppModalSheet.bottomInsetKey));
    expect(inset.height, AppSize.spaceMD);
  });
}

class _AccountSwitcherSheetHost extends ConsumerWidget {
  const _AccountSwitcherSheetHost();

  static const openKey = Key('open_account_switcher_sheet');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: TextButton(
          key: openKey,
          onPressed: () => showAccountSwitcherSheetModal(
            context,
            memberships: const [
              OfficeMembership(
                id: _officeId,
                name: 'مكتب الهيكل للتشطيبات',
                readOnly: false,
              ),
            ],
            locksOwned: false,
            currentScope: AccountScope.personal(),
          ),
          child: const Text('Open'),
        ),
      ),
    );
  }
}