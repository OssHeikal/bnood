import 'package:bnood/core/account/account_office_providers.dart';
import 'package:bnood/core/ui/theme/app_theme.dart';
import 'package:bnood/core/domain/ledger/ledger_entities.dart';
import 'package:bnood/features/clients/presentation/models/client_detail_snapshot.dart';
import 'package:bnood/features/clients/presentation/widgets/client_movement_card.dart';
import 'package:bnood/features/clients/presentation/widgets/interactive_movement_card.dart';
import 'package:bnood/features/home/presentation/widgets/home_foundation_scope.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('movement card hides amount when money permission missing', (
    tester,
  ) async {
    final line = ClientDetailMovementLine(
      transaction: Transaction(
        id: 't1',
        workspaceId: 'w',
        projectId: 'p1',
        amountPiastres: 50000,
        date: DateTime.utc(2026, 1, 1),
        kind: 'receive',
        method: 'cash',
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 1),
      ),
      itemName: null,
      payeeName: null,
      usesRemoteMinorUnits: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accountOfficeClientMoneyVisibleProvider.overrideWith((ref) => false),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomeFoundationScope(
            child: Scaffold(
              body: InteractiveMovementCard(
                line: line,
                localeCode: 'en',
                mutationsEnabled: false,
                hideAmount: true,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ClientMovementCard), findsOneWidget);
    expect(find.textContaining('500'), findsNothing);
  });

  test('voucher mutations off without edit or delete keys', () {
    final perms = OfficeAccountPermissions.office(
      const OfficeMembership(
        id: 'o',
        name: 'O',
        readOnly: false,
        permissionKeys: [
          OfficePermissionKeys.clientsView,
          OfficePermissionKeys.voucherCreate,
        ],
      ),
    );
    expect(perms.canEditVoucher, isFalse);
    expect(perms.canDeleteVoucher, isFalse);
    expect(perms.canCreateVoucher, isTrue);
  });
}