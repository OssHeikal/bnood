import 'package:bnood/core/account/account_office_providers.dart';
import 'package:bnood/core/account/office_membership.dart';
import 'package:bnood/core/account/office_permission_keys.dart';
import 'package:bnood/core/account/office_permissions.dart';
import 'package:bnood/core/ui/theme/app_theme.dart';
import 'package:bnood/features/clients/presentation/screens/clients_list_screen.dart';
import 'package:bnood/features/clients/presentation/widgets/client_detail_action_grid.dart';
import 'package:bnood/features/home/presentation/widgets/home_foundation_scope.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/home_notifier_stubs.dart';

void main() {
  testWidgets('clients list hides add when office cannot manage clients', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          officeAccountPermissionsProvider.overrideWithValue(
            OfficeAccountPermissions.office(
              const OfficeMembership(
                id: 'o1',
                name: 'Office',
                readOnly: false,
                permissionKeys: [OfficePermissionKeys.clientsView],
              ),
            ),
          ),
          clientsListBalancesOverride(const []),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ClientsListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('clients_app_bar_add')), findsNothing);
  });

  testWidgets('action grid enables statement without ledger manage', (
    tester,
  ) async {
    var statementTapped = false;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomeFoundationScope(
          child: Scaffold(
            body: ClientDetailActionGrid(
              isArchived: false,
              mutationsEnabled: false,
              statementEnabled: true,
              onReceive: () {},
              onSpend: () {},
              onStatement: () => statementTapped = true,
              onArchive: () {},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('client_detail_action_statement')));
    await tester.pump();
    expect(statementTapped, isTrue);
  });
}