import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ui/widgets/app_toaster.dart';
import 'account_office_providers.dart';

bool _mutationsEnabled(BuildContext context, WidgetRef? ref) {
  if (ref != null) {
    return ref.read(accountOfficeMutationsEnabledProvider);
  }
  return ProviderScope.containerOf(
    context,
    listen: false,
  ).read(accountOfficeMutationsEnabledProvider);
}

bool _canCreateVoucher(BuildContext context, WidgetRef? ref) {
  if (ref != null) {
    return ref.read(accountOfficeCanCreateVoucherProvider);
  }
  return ProviderScope.containerOf(
    context,
    listen: false,
  ).read(accountOfficeCanCreateVoucherProvider);
}

bool _canManageArea(
  BuildContext context,
  WidgetRef? ref,
  OfficePermissionArea area,
) {
  if (ref != null) {
    return ref.read(accountOfficeCanManageProvider(area));
  }
  return ProviderScope.containerOf(
    context,
    listen: false,
  ).read(accountOfficeCanManageProvider(area));
}

Future<bool> guardOfficeWritable(BuildContext context, WidgetRef? ref) async {
  if (_mutationsEnabled(context, ref)) return true;
  notifyOfficePermissionDenied(context);
  return false;
}

Future<bool> guardOfficeVoucherCreate(BuildContext context, WidgetRef? ref) async {
  if (_canCreateVoucher(context, ref)) return true;
  notifyOfficePermissionDenied(context);
  return false;
}

Future<bool> guardOfficeManage(
  BuildContext context,
  WidgetRef? ref,
  OfficePermissionArea area,
) async {
  if (_canManageArea(context, ref, area)) return true;
  notifyOfficePermissionDenied(context);
  return false;
}

void notifyOfficePermissionDenied(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  AppToaster.show(l10n.officeReadOnlyActionBlocked, kind: ToastKind.failure);
}