import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/prefs/bnood_prefs_access.dart';
import 'account_context_store.dart';
import 'account_context_state.dart';
import 'account_scope.dart';
import 'api_office_header.dart';
import 'account_office_mutations.dart';
import 'office_membership.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/auth_state.dart';

class AccountContextController extends Notifier<AccountContextState> {
  @override
  AccountContextState build() {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      final wasAuthed = previous?.isAuthenticated ?? false;
      if (wasAuthed && !next.isAuthenticated) {
        unawaited(_setScope(const AccountScope.personal(), persist: true));
        return;
      }
      if (next.isAuthenticated) {
        unawaited(_reconcileOffices(next.officeContext?.offices ?? const []));
      }
    });

    scheduleMicrotask(_restoreFromDisk);
    ApiOfficeHeader.syncOfficeId(null);
    return const AccountContextState.personal();
  }

  Future<void> selectPersonal() => _setScope(const AccountScope.personal());

  Future<void> selectOffice(String officeId) =>
      _setScope(AccountScope.office(officeId));

  Future<void> _restoreFromDisk() async {
    final prefs = await BnoodPrefsAccess.getInstance();
    final scope = await AccountContextStore.readScope(prefs);
    if (scope == state.scope) {
      if (!state.restoredFromDisk) {
        state = state.copyWith(restoredFromDisk: true);
      }
      return;
    }
    state = state.copyWith(scope: scope, restoredFromDisk: true);
    ApiOfficeHeader.syncOfficeId(scope.officeId);
  }

  Future<void> _setScope(
    AccountScope scope, {
    bool persist = true,
  }) async {
    if (scope == state.scope) return;

    state = state.copyWith(scope: scope, restoredFromDisk: true);
    ApiOfficeHeader.syncOfficeId(scope.officeId);

    if (persist) {
      final prefs = await BnoodPrefsAccess.getInstance();
      await AccountContextStore.writeScope(prefs, scope);
    }
  }

  Future<void> _reconcileOffices(List<OfficeMembership> offices) async {
    if (state.isPersonal) return;
    final id = state.officeId;
    if (id == null) return;
    if (officeMembershipListContains(offices, id)) return;
    await _setScope(const AccountScope.personal());
  }
}