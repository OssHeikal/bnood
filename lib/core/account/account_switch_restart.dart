import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/router.dart';
import 'account_context_reset.dart';

/// Bumps when the active ledger account changes so shell subtrees fully rebuild.
final appLedgerScopeEpochProvider = StateProvider<int>((ref) => 0);

const accountShellHomePath = '/home';

/// Clears ledger caches, rebuilds shell scope, and returns navigation to Home.
void performAccountSwitchRestart(Ref ref) {
  resetAccountScopedState(ref);
  ref.read(appLedgerScopeEpochProvider.notifier).state++;
  ref.read(goRouterProvider).go(accountShellHomePath);
}