import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/auth_api_exception.dart';
import 'subscription_limit_handler.dart';

/// Maps subscription 403 codes to paywall or limit info when surfaces are enabled.
Future<bool> handleSubscriptionApiError({
  required BuildContext context,
  required WidgetRef ref,
  required AuthApiException error,
}) async {
  if (error.isActiveProjectCapReached) {
    if (!context.mounted) return true;
    await SubscriptionLimitHandler.presentBlocked(
      context: context,
      ref: ref,
      kind: SubscriptionLimitKind.activeProjects,
    );
    return true;
  }
  if (error.isSubscriptionFinancialReadOnly) {
    if (!context.mounted) return true;
    await SubscriptionLimitHandler.presentBlocked(
      context: context,
      ref: ref,
      kind: SubscriptionLimitKind.financialTransactions,
    );
    return true;
  }
  return false;
}

Future<bool> handleClientsApiSubscriptionError({
  required BuildContext context,
  required WidgetRef ref,
  required AuthApiException error,
}) =>
    handleSubscriptionApiError(context: context, ref: ref, error: error);