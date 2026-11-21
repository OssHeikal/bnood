import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'account_context_controller.dart';
import 'account_context_reset.dart';
import 'account_context_state.dart';

export 'account_context_controller.dart';
export 'account_context_reset.dart';
export 'account_context_state.dart';
export 'account_context_store.dart';
export 'account_scope.dart';
export 'api_office_header.dart';

final accountContextProvider =
    NotifierProvider<AccountContextController, AccountContextState>(
      AccountContextController.new,
    );

String? _accountSelectionKey(AccountContextState state) {
  if (state.isPersonal) return 'personal';
  return 'office:${state.officeId}';
}

/// Resets cached ledger data when [accountContextProvider] changes identity.
final accountContextLifecycleProvider = Provider<void>((ref) {
  ref.listen<AccountContextState>(accountContextProvider, (previous, next) {
    if (previous == null) return;
    if (_accountSelectionKey(previous) == _accountSelectionKey(next)) return;
    resetAccountScopedState(ref);
  });
});