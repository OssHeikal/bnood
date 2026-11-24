import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_root_restart.dart';

/// After a user-driven account identity change, reload the app under a fresh scope.
void requestAccountSwitchRestart(Ref ref) {
  if (!AppRootRestart.isBound) return;
  AppRootRestart.request();
}