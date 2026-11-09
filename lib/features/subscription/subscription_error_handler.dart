import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/auth_api_exception.dart';
import 'paywall_launcher.dart';

/// Maps subscription 403 codes to paywall when surfaces are enabled.
Future<bool> handleSubscriptionApiError({
  required BuildContext context,
  required WidgetRef ref,
  required AuthApiException error,
}) async {
  if (error.isActiveProjectCapReached) {
    if (!context.mounted) return true;
    await PaywallLauncher.present(context, ref);
    return true;
  }
  if (error.isSubscriptionFinancialReadOnly) {
    if (!context.mounted) return true;
    await PaywallLauncher.present(context, ref);
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
