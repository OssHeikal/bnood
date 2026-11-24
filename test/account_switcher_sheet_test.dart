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

  Future<void> pumpSheet(WidgetTester tester, {double bottomInset = 34}) async {
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
            data: const MediaQueryData(
              size: Size(390, 844),
              padding: EdgeInsets.only(bottom: 34),
              viewPadding: EdgeInsets.only(bottom: 34),
            ),
            child: HomeFoundationScope(
              child: Scaffold(
                body: AppModalSheetScope(
                  footerScrollPadding: 0,
                  homeIndicatorBottom: bottomInset,
                  child: AccountSwitcherSheet(
                    memberships: const [
                      OfficeMembership(
                        id: _officeId,
                        name: 'مكتب الهيكل للتشطيبات',
                        readOnly: false,
                      ),
                    ],
                    locksOwned: false,
                    currentScope: const AccountScope.personal(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('account switcher sheet lists scopes with subtitles and safe inset',
      (tester) async {
    await pumpSheet(tester);

    expect(find.text('اختر الحساب'), findsOneWidget);
    expect(find.text('شخصي'), findsOneWidget);
    expect(find.text('مكتب'), findsOneWidget);
    expect(find.text('مكتب الهيكل للتشطيبات'), findsOneWidget);

    final sheetPadding = tester.widget<Padding>(
      find.byWidgetPredicate(
        (w) =>
            w is Padding &&
            w.child is Column &&
            (w.child as Column).children.isNotEmpty,
      ),
    );
    expect(
      (sheetPadding.padding as EdgeInsets).bottom,
      AppSize.spaceLG + 34,
    );
  });
}