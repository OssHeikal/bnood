import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bnood/features/auth/auth_paths.dart';
import 'package:bnood/features/vouchers/presentation/screens/voucher_screen.dart';
import 'account_context_providers.dart';
import 'account_office_providers.dart';

/// Returns home when [location] is not allowed for the active office scope.
String? officePermissionRedirect(Ref ref, String location) {
  return officePermissionRedirectForScope(
    isPersonal: ref.read(accountContextProvider).isPersonal,
    perms: ref.read(officeAccountPermissionsProvider),
    location: location,
  );
}

String? officePermissionRedirectForScope({
  required bool isPersonal,
  required OfficeAccountPermissions perms,
  required String location,
}) {
  if (isPersonal) return null;

  if (location == VoucherScreen.path && !perms.canCreateVoucher) {
    return _localHome;
  }
  if (location == '/items' && !perms.canView(OfficePermissionArea.items)) {
    return _localHome;
  }
  if (location == '/clients' || _isClientSubRoute(location)) {
    if (!perms.canView(OfficePermissionArea.clients)) {
      return _localHome;
    }
  }
  if (location == '/projects' || location.startsWith('/projects/')) {
    if (!perms.canView(OfficePermissionArea.projects)) {
      return _localHome;
    }
  }
  if (location == '/directory' ||
      isRemoteProviderDetailLocation(location) ||
      location.startsWith('/suppliers/') ||
      location.startsWith('/craftsmen/')) {
    if (!perms.canView(OfficePermissionArea.providers)) {
      return _localHome;
    }
  }
  if (isStatementRoute(location) && !canOpenStatement(perms)) {
    return _localHome;
  }

  return null;
}

bool canOpenStatement(OfficeAccountPermissions perms) {
  return perms.canViewClientMoney &&
      perms.canView(OfficePermissionArea.clients);
}

bool isStatementRoute(String location) {
  final segments = Uri.parse(location).pathSegments;
  return segments.length >= 3 &&
      segments[0] == 'clients' &&
      segments.last == 'statement';
}

bool _isClientSubRoute(String location) {
  return location.startsWith('/clients/');
}

const _localHome = '/home';