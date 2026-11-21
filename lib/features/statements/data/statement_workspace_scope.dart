import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bnood/features/auth/auth_controller.dart';

/// Key for statement export prefs (per signed-in user).
String statementWorkspaceId(WidgetRef ref) {
  final user = ref.read(authControllerProvider).user;
  return user?.id ?? 'anonymous';
}
