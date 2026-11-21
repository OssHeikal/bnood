import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/subscription_riverpod.dart';
import 'subscription_limit_handler.dart';

Future<bool> guardCreateActiveProject(
  BuildContext context,
  WidgetRef ref, {
  SubscriptionLimitKind limitKind = SubscriptionLimitKind.activeProjects,
}) async {
  final snap = ref.read(subscriptionProvider).valueOrNull;
  if (snap == null) return true;
  return SubscriptionLimitHandler.gate(
    context: context,
    ref: ref,
    kind: limitKind,
    allowed: snap.entitlements.mayCreateActiveProject,
    cap: snap.entitlements.activeProjectCap,
    snapshot: snap,
  );
}

Future<bool> guardFinancialMutation(BuildContext context, WidgetRef ref) async {
  final snap = ref.read(subscriptionProvider).valueOrNull;
  if (snap == null) return true;
  return SubscriptionLimitHandler.gate(
    context: context,
    ref: ref,
    kind: SubscriptionLimitKind.financialTransactions,
    allowed: snap.entitlements.canMutateFinancialTransactions,
    snapshot: snap,
  );
}

Future<bool> guardFinancialMutationFromContainer(
  BuildContext context,
  ProviderContainer container,
) async {
  final snap = container.read(subscriptionProvider).valueOrNull;
  if (snap == null) return true;
  return SubscriptionLimitHandler.gate(
    context: context,
    kind: SubscriptionLimitKind.financialTransactions,
    allowed: snap.entitlements.canMutateFinancialTransactions,
    snapshot: snap,
  );
}

Future<bool> guardArchiveClient(BuildContext context, WidgetRef ref) async {
  final snap = ref.read(subscriptionProvider).valueOrNull;
  if (snap == null) return true;
  return SubscriptionLimitHandler.gate(
    context: context,
    ref: ref,
    kind: SubscriptionLimitKind.archiveClient,
    allowed: snap.entitlements.canArchiveClient,
    snapshot: snap,
  );
}