import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/prefs/bnood_prefs_access.dart';
import 'account_context_store.dart';
import 'account_context_state.dart';
import 'account_office_policy.dart';
import 'account_scope.dart';
import 'api_office_header.dart';
import 'account_office_providers.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/auth_state.dart';

class AccountContextController extends Notifier<AccountContextState> {
  @override
  AccountContextState build() {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      final wasAuthed = previous?.isAuthenticated ?? false;
      if (wasAuthed && !next.isAuthenticated) {
        unawaited(_clearScopeOnLogout());
        return;
      }
      if (next.isAuthenticated) {
        unawaited(_reconcileOffices(next.officeContext?.offices ?? const []));
      }
    });

    scheduleMicrotask(_bootstrapScope);
    ApiOfficeHeader.syncOfficeId(null);
    return const AccountContextState.personal();
  }

  Future<void> selectPersonal() async {
    final offices =
        ref.read(authControllerProvider).officeContext?.offices ?? const [];
    if (userLocksToOwnedOffice(offices)) return;
    await _setScope(const AccountScope.personal());
  }

  Future<void> selectOffice(String officeId) async {
    final offices =
        ref.read(authControllerProvider).officeContext?.offices ?? const [];
    final owned = primaryOwnedOffice(offices);
    if (owned != null && officeId != owned.id) return;
    await _setScope(AccountScope.office(officeId));
  }

  /// Swaps to the last scope from prefs when the switcher is visible.
  Future<void> quickSwitchToPreviousScope() async {
    final offices =
        ref.read(authControllerProvider).officeContext?.offices ?? const [];
    if (userLocksToOwnedOffice(offices)) return;
    if (!ref.read(accountSwitcherVisibleProvider)) return;

    final prefs = await BnoodPrefsAccess.getInstance();
    var target = await AccountContextStore.readPreviousScope(prefs);

    if (target == null && offices.length == 1) {
      final only = offices.first;
      if (state.isPersonal) {
        target = AccountScope.office(only.id);
      } else if (state.officeId == only.id) {
        target = const AccountScope.personal();
      }
    }

    if (target == null || target == state.scope) return;
    if (target.isPersonal) {
      await selectPersonal();
      return;
    }
    final id = target.officeId;
    if (id == null || !officeMembershipListContains(offices, id)) return;
    await selectOffice(id);
  }

  Future<void> _bootstrapScope() async {
    await _restoreFromDisk();
    final auth = ref.read(authControllerProvider);
    if (auth.isAuthenticated) {
      await _reconcileOffices(auth.officeContext?.offices ?? const []);
    }
  }

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

  Future<void> _clearScopeOnLogout() async {
    state = const AccountContextState.personal();
    ApiOfficeHeader.syncOfficeId(null);
    final prefs = await BnoodPrefsAccess.getInstance();
    await AccountContextStore.clearPersisted(prefs);
  }

  Future<void> _setScope(
    AccountScope scope, {
    bool persist = true,
  }) async {
    if (scope == state.scope) return;

    final previousScope = state.scope;
    state = state.copyWith(scope: scope, restoredFromDisk: true);
    ApiOfficeHeader.syncOfficeId(scope.officeId);

    if (persist) {
      final prefs = await BnoodPrefsAccess.getInstance();
      await AccountContextStore.writePreviousScope(prefs, previousScope);
      await AccountContextStore.writeScope(prefs, scope);
    }
  }

  Future<void> _reconcileOffices(List<OfficeMembership> offices) async {
    final owned = primaryOwnedOffice(offices);
    if (owned != null) {
      if (state.scope != AccountScope.office(owned.id)) {
        await _setScope(AccountScope.office(owned.id));
      }
      return;
    }

    if (state.isPersonal) return;
    final id = state.officeId;
    if (id == null) return;
    if (officeMembershipListContains(offices, id)) return;
    await _setScope(const AccountScope.personal());
  }
}