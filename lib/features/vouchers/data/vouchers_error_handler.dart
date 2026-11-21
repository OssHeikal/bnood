import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/auth_controller.dart';
import '../../auth/auth_paths.dart';
import '../../subscription/subscription_error_handler.dart';
import 'package:bnood/core/api/auth_api_exception.dart';

Future<bool> handleVouchersApiAuthError({
  required BuildContext context,
  required WidgetRef ref,
  required AuthApiException error,
}) async {
  if (error.isProfileIncomplete) {
    if (context.mounted) context.go(AuthPaths.completeProfile);
    return true;
  }
  if (error.isSessionExpired || (error.isUnauthorized && error.code != 'invalid_credentials')) {
    await ref.read(authControllerProvider.notifier).logout();
    if (context.mounted) context.go(AuthPaths.login);
    return true;
  }
  if (await handleSubscriptionApiError(context: context, ref: ref, error: error)) {
    return true;
  }
  return false;
}
