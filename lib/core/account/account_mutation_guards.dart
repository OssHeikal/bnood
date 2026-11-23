import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ui/widgets/app_toaster.dart';
import 'account_office_providers.dart';

Future<bool> guardOfficeWritable(BuildContext context, WidgetRef? ref) async {
  final enabled = ref != null
      ? ref.read(accountOfficeMutationsEnabledProvider)
      : ProviderScope.containerOf(
          context,
          listen: false,
        ).read(accountOfficeMutationsEnabledProvider);
  if (enabled) return true;
  final l10n = AppLocalizations.of(context);
  AppToaster.show(l10n.officeReadOnlyActionBlocked, kind: ToastKind.failure);
  return false;
}