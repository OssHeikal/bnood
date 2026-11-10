import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/subscription/app_subscription.dart';
import '../../core/subscription/subscription_riverpod.dart';
import 'paywall_launcher.dart';

bool _allowsWithoutSurfaces(AppSubscriptionSnapshot? snap) {
  if (snap == null) return true;
  return !snap.showSurfaces;
}

/// Returns true when the action may proceed; false when paywall was shown.
Future<bool> guardCreateActiveProject(BuildContext context, WidgetRef ref) async {
  final snap = ref.read(subscriptionProvider).valueOrNull;
  if (_allowsWithoutSurfaces(snap) || snap!.entitlements.mayCreateActiveProject) {
    return true;
  }
  await PaywallLauncher.present(context);
  return false;
}

bool _mayMutateFinancial(AppSubscriptionSnapshot? snap) {
  if (_allowsWithoutSurfaces(snap)) return true;
  return snap!.entitlements.canMutateFinancialTransactions;
}

Future<bool> guardFinancialMutation(BuildContext context, WidgetRef ref) async {
  final snap = ref.read(subscriptionProvider).valueOrNull;
  if (_mayMutateFinancial(snap)) return true;
  await PaywallLauncher.present(context);
  return false;
}

Future<bool> guardFinancialMutationFromContainer(
  BuildContext context,
  ProviderContainer container,
) async {
  final snap = container.read(subscriptionProvider).valueOrNull;
  if (_mayMutateFinancial(snap)) return true;
  await PaywallLauncher.present(context);
  return false;
}

Future<bool> guardArchiveClient(BuildContext context, WidgetRef ref) async {
  final snap = ref.read(subscriptionProvider).valueOrNull;
  if (_allowsWithoutSurfaces(snap) || snap!.entitlements.canArchiveClient) {
    return true;
  }
  await PaywallLauncher.present(context);
  return false;
}
