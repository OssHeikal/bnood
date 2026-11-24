import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'account_context_controller.dart';
import 'account_context_state.dart';

export 'account_context_controller.dart';
export 'account_context_reset.dart';
export 'account_context_state.dart';
export 'account_context_store.dart';
export 'account_scope.dart';
export 'account_switch_restart.dart';
export 'api_office_header.dart';

final accountContextProvider =
    NotifierProvider<AccountContextController, AccountContextState>(
      AccountContextController.new,
    );

/// Keeps account lifecycle registered on the widget tree (reserved for future hooks).
final accountContextLifecycleProvider = Provider<void>((ref) {});