import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/account/account_context_providers.dart';
import '../../../core/account/account_office_providers.dart';
import '../../../core/ui/widgets/sheet/app_sheet.dart';
import 'package:bnood/l10n/app_localizations.dart';

Future<void> showAccountSwitcherSheet(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final memberships = ref.read(officeMembershipsProvider);
  if (memberships.isEmpty) return;

  final ctx = ref.read(accountContextProvider);
  final choices = <SheetChoice<AccountScope>>[
    SheetChoice(
      value: const AccountScope.personal(),
      label: l10n.accountScopePersonal,
      leading: ctx.isPersonal ? const Icon(Icons.check, size: 20) : null,
    ),
    for (final office in memberships)
      SheetChoice(
        value: AccountScope.office(office.id),
        label: office.name.isNotEmpty ? office.name : office.id,
        leading: ctx.officeId == office.id
            ? const Icon(Icons.check, size: 20)
            : null,
      ),
  ];

  final picked = await AppSheet.choices<AccountScope>(
    context,
    title: l10n.accountSwitchTitle,
    choices: choices,
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