import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'account_context_providers.dart';
import 'account_office_mutations.dart';
import 'office_membership.dart';
import 'package:bnood/features/auth/auth_controller.dart';

export 'account_office_mutations.dart';
export 'auth_office_payload.dart';
export 'office_membership.dart';

final officeMembershipsProvider = Provider<List<OfficeMembership>>((ref) {
  return ref.watch(authControllerProvider).officeContext?.offices ??
      const [];
});

final accountSwitcherVisibleProvider = Provider<bool>((ref) {
  return ref.watch(officeMembershipsProvider).isNotEmpty;
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

final accountOfficeMutationsEnabledProvider = Provider<bool>((ref) {
  final ctx = ref.watch(accountContextProvider);
  return accountOfficeMutationsEnabled(
    isPersonal: ctx.isPersonal,
    selectedOffice: ref.watch(selectedOfficeMembershipProvider),
  );
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