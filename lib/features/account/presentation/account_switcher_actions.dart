import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/account/account_context_providers.dart';
import '../../../core/account/account_office_providers.dart';
import 'sheets/account_switcher_sheet.dart';

Future<void> showAccountSwitcherSheet(BuildContext context, WidgetRef ref) async {
  final memberships = ref.read(officeMembershipsProvider);
  if (memberships.isEmpty) return;
  if (!ref.read(accountSwitcherVisibleProvider)) return;

  final ctx = ref.read(accountContextProvider);
  final locksOwned = ref.read(userLocksToOwnedOfficeProvider);

  final picked = await showAccountSwitcherSheetModal(
    context,
    memberships: memberships,
    locksOwned: locksOwned,
    currentScope: ctx.scope,
  );
  if (picked == null || !context.mounted) return;
  if (picked == ref.read(accountContextProvider).scope) return;

  final notifier = ref.read(accountContextProvider.notifier);
  if (picked.isPersonal) {
    await notifier.selectPersonal();
  } else {
    await notifier.selectOffice(picked.officeId!);
  }
}