import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'account_context_providers.dart';
import 'account_office_policy.dart';
import 'office_membership.dart';
import 'office_permission_keys.dart';
import 'office_permissions.dart';
import 'package:bnood/features/auth/auth_controller.dart';

export 'account_office_mutations.dart';
export 'office_permission_keys.dart';
export 'office_permissions.dart';
export 'auth_office_payload.dart';
export 'office_membership.dart';

final officeMembershipsProvider = Provider<List<OfficeMembership>>((ref) {
  return ref.watch(authControllerProvider).officeContext?.offices ?? const [];
});

final userLocksToOwnedOfficeProvider = Provider<bool>((ref) {
  return userLocksToOwnedOffice(ref.watch(officeMembershipsProvider));
});

/// Office name in the home header when the user is locked to their owned office.
final accountOwnedOfficeHeaderVisibleProvider = Provider<bool>((ref) {
  if (!ref.watch(userLocksToOwnedOfficeProvider)) return false;
  final ctx = ref.watch(accountContextProvider);
  return !ctx.isPersonal;
});

final accountSwitcherVisibleProvider = Provider<bool>((ref) {
  final offices = ref.watch(officeMembershipsProvider);
  if (offices.isEmpty) return false;
  if (ref.watch(userLocksToOwnedOfficeProvider)) return false;
  return true;
});

final selectedOfficeMembershipProvider = Provider<OfficeMembership?>((ref) {
  final ctx = ref.watch(accountContextProvider);
  if (ctx.isPersonal) return null;
  final id = ctx.officeId;
  if (id == null) return null;
  for (final office in ref.watch(officeMembershipsProvider)) {
    if (office.id == id) return office;
  }
  return null;
});

final officeAccountPermissionsProvider = Provider<OfficeAccountPermissions>((
  ref,
) {
  final ctx = ref.watch(accountContextProvider);
  if (ctx.isPersonal) return OfficeAccountPermissions.personal();
  return OfficeAccountPermissions.office(
    ref.watch(selectedOfficeMembershipProvider),
  );
});

final accountOfficeMutationsEnabledProvider = Provider<bool>((ref) {
  return ref.watch(officeAccountPermissionsProvider).anyLedgerManageEnabled;
});

final accountOfficeCanManageProvider =
    Provider.family<bool, OfficePermissionArea>((ref, area) {
      return ref.watch(officeAccountPermissionsProvider).canManage(area);
    });

final accountOfficeCanViewProvider =
    Provider.family<bool, OfficePermissionArea>((ref, area) {
      return ref.watch(officeAccountPermissionsProvider).canView(area);
    });

final accountOfficeClientMoneyVisibleProvider = Provider<bool>((ref) {
  return ref.watch(officeAccountPermissionsProvider).canViewClientMoney;
});

final accountOfficeCanCreateVoucherProvider = Provider<bool>((ref) {
  return ref.watch(officeAccountPermissionsProvider).canCreateVoucher;
});

final accountOfficeVoucherEditEnabledProvider = Provider<bool>((ref) {
  return ref.watch(officeAccountPermissionsProvider).canEditVoucher;
});

final accountOfficeVoucherMutationsEnabledProvider = Provider<bool>((ref) {
  final perms = ref.watch(officeAccountPermissionsProvider);
  return perms.canEditVoucher || perms.canDeleteVoucher;
});

/// Visible router branches → dock tab order (maps dock index → branch index).
final shellVisibleBranchIndicesProvider = Provider<List<int>>((ref) {
  final perms = ref.watch(officeAccountPermissionsProvider);
  final out = <int>[];
  for (final branch in ShellNavBranch.values) {
    if (perms.shellBranchVisible(branch)) out.add(branch.routerIndex);
  }
  return out;
});

final officeReadOnlyBannerVisibleProvider = Provider<bool>((ref) {
  if (ref.watch(accountContextProvider).isPersonal) return false;
  return ref.watch(selectedOfficeMembershipProvider)?.isReadOnly ?? false;
});

typedef OfficeDashboardLaunch = ({bool show, String? url});

final officeDashboardLaunchProvider = Provider<OfficeDashboardLaunch>((ref) {
  final payload = ref.watch(authControllerProvider).officeContext;
  final isPersonal = ref.watch(accountContextProvider).isPersonal;
  final selected = ref.watch(selectedOfficeMembershipProvider);
  if (payload == null) return (show: false, url: null);

  if (isPersonal) {
    if (!payload.openDashboard) return (show: false, url: null);
    final url = payload.dashboardUrl?.trim();
    if (url == null || url.isEmpty) return (show: false, url: null);
    return (show: true, url: url);
  }

  final officeUrl = selected?.dashboardUrl?.trim();
  if (officeUrl != null && officeUrl.isNotEmpty) {
    return (show: true, url: officeUrl);
  }
  if (payload.openDashboard) {
    final url = payload.dashboardUrl?.trim();
    if (url != null && url.isNotEmpty) return (show: true, url: url);
  }
  return (show: false, url: null);
});

/// Home header face: personal logo, or the selected office logo.
/// Profile opens from that face only for a personal scope or the office owner.
({String displayName, String? imageUrl, bool opensProfile})
accountHeaderAvatar({
  required bool isPersonal,
  required String personalName,
  String? personalLogoUrl,
  OfficeMembership? office,
}) {
  if (!isPersonal && office != null) {
    return (
      displayName: office.name,
      imageUrl: office.logoUrl,
      opensProfile: office.isOwner,
    );
  }
  return (
    displayName: personalName,
    imageUrl: personalLogoUrl,
    opensProfile: true,
  );
}

String accountDisplayTitle({
  required bool isPersonal,
  required String? personalName,
  OfficeMembership? selectedOffice,
}) {
  if (isPersonal) {
    final trimmed = personalName?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    return '';
  }
  return selectedOffice?.name.trim() ?? '';
}
