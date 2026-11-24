import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_state/bootstrap_prefs.dart';
import '../data/prefs/bnood_prefs_access.dart';
import 'account_context_store.dart';
import 'account_context_state.dart';
import 'account_office_policy.dart';
import 'account_scope.dart';
import 'api_office_header.dart';
import 'account_office_providers.dart';
import 'account_switch_restart.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/auth_state.dart';

class AccountContextController extends Notifier<AccountContextState> {
  var _bootstrapGeneration = 0;

  @override
  AccountContextState build() {
    final generation = ++_bootstrapGeneration;
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      final wasAuthed = previous?.isAuthenticated ?? false;
      if (wasAuthed && !next.isAuthenticated) {
        unawaited(_clearScopeOnLogout());
        return;
      }
      if (next.isAuthenticated) {
        unawaited(
          _reconcileOffices(
            next.officeContext?.offices ?? const [],
            _bootstrapGeneration,
          ),
        );
      }
    });

    scheduleMicrotask(() => _bootstrapScope(generation));
    return _initialStateFromDisk();
  }

  bool _isCurrentBootstrap(int generation) => generation == _bootstrapGeneration;

  AccountContextState _initialStateFromDisk() {
    final prefs = tryReadBootstrapPrefs(ref);
    final scope = _mergeOwnedOfficeScope(AccountContextStore.readScopeSync(prefs));
    ApiOfficeHeader.syncOfficeId(scope.officeId);
    return AccountContextState(scope: scope, restoredFromDisk: true);
  }

  AccountScope _mergeOwnedOfficeScope(AccountScope scope) {
    final offices =
        ref.read(authControllerProvider).officeContext?.offices ?? const [];
    final owned = primaryOwnedOffice(offices);
    if (owned != null && scope.isPersonal) {
      return AccountScope.office(owned.id);
    }
    return scope;
  }

  Future<void> selectPersonal() async {
    final offices =
        ref.read(authControllerProvider).officeContext?.offices ?? const [];
    if (userLocksToOwnedOffice(offices)) return;
    await _setScope(const AccountScope.personal(), restartAppOnChange: true);
  }

  Future<void> selectOffice(String officeId) async {
    final offices =
        ref.read(authControllerProvider).officeContext?.offices ?? const [];
    final owned = primaryOwnedOffice(offices);
    if (owned != null && officeId != owned.id) return;
    await _setScope(AccountScope.office(officeId), restartAppOnChange: true);
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

  Future<void> _bootstrapScope(int generation) async {
    try {
      await _restoreFromDisk(generation);
      if (!_isCurrentBootstrap(generation)) return;
      final auth = ref.read(authControllerProvider);
      if (auth.isAuthenticated) {
        await _reconcileOffices(
          auth.officeContext?.offices ?? const [],
          generation,
        );
      }
    } on StateError {
      return;
    }
  }

  Future<void> _restoreFromDisk([int? generation]) async {
    final prefs = await BnoodPrefsAccess.getInstance();
    var scope = await AccountContextStore.readScope(prefs);
    if (generation != null && !_isCurrentBootstrap(generation)) return;
    final diskWasPersonal = scope.isPersonal;
    scope = _mergeOwnedOfficeScope(scope);
    if (scope == state.scope) {
      if (!state.restoredFromDisk) {
        state = state.copyWith(restoredFromDisk: true);
      }
      if (diskWasPersonal && !scope.isPersonal) {
        await AccountContextStore.writeScope(prefs, scope);
      }
      return;
    }
    state = state.copyWith(scope: scope, restoredFromDisk: true);
    ApiOfficeHeader.syncOfficeId(scope.officeId);
    if (diskWasPersonal && !scope.isPersonal) {
      await AccountContextStore.writeScope(prefs, scope);
    }
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
    bool restartAppOnChange = false,
  }) async {
    if (scope == state.scope) return;

    final previousScope = state.scope;

    if (persist) {
      final prefs = await BnoodPrefsAccess.getInstance();
      await AccountContextStore.writePreviousScope(prefs, previousScope);
      await AccountContextStore.writeScope(prefs, scope);
    }

    state = state.copyWith(scope: scope, restoredFromDisk: true);
    ApiOfficeHeader.syncOfficeId(scope.officeId);

    if (ref.read(authControllerProvider).isAuthenticated) {
      await ref.read(authControllerProvider.notifier).refreshMeSilently();
    }

    if (restartAppOnChange) {
      requestAccountSwitchRestart(ref);
    }
  }

  Future<void> _reconcileOffices(
    List<OfficeMembership> offices, [
    int? generation,
  ]) async {
    try {
      if (generation != null && !_isCurrentBootstrap(generation)) return;
      if (offices.isEmpty) return;

      final owned = primaryOwnedOffice(offices);
    if (owned != null) {
      final ownedScope = AccountScope.office(owned.id);
      if (state.scope != ownedScope) {
        await _setScope(ownedScope);
      } else {
        final prefs = await BnoodPrefsAccess.getInstance();
        await AccountContextStore.writeScope(prefs, ownedScope);
      }
      return;
    }

    if (state.isPersonal) return;
    final id = state.officeId;
    if (id == null) return;
    if (officeMembershipListContains(offices, id)) return;
    await _setScope(const AccountScope.personal());
    } on StateError {
      return;
    }
  }
}