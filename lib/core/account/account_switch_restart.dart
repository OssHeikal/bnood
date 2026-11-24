import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_root_restart.dart';

/// After a user-driven account identity change, reload the app under a fresh scope.
void requestAccountSwitchRestart(Ref ref) {
  unawaited(
    Future.microtask(AppRootRestart.request),
  );
}