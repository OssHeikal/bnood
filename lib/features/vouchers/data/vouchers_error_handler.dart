import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/auth_paths.dart';
import 'package:bnood/features/subscription/presentation/actions/subscription_error_handler.dart';
import 'package:bnood/core/network/api/auth_api_exception.dart';

Future<bool> handleVouchersApiAuthError({
  required BuildContext context,
  required WidgetRef ref,
  required AuthApiException error,
}) async {
  if (error.isProfileIncomplete) {
    if (context.mounted) context.go(AuthPaths.completeProfile);
    return true;
  }
  if (error.isSessionExpired ||
      (error.isUnauthorized && error.code != 'invalid_credentials')) {
    await ref.read(authControllerProvider.notifier).logout();
    if (context.mounted) context.go(AuthPaths.login);
    return true;
  }
  if (await handleSubscriptionApiError(
    context: context,
    ref: ref,
    error: error,
  )) {
    return true;
  }
  return false;
}
