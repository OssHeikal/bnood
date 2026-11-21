import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/formatting/display_digits.dart';
import 'package:bnood/features/subscription/data/app_subscription.dart';
import 'package:bnood/features/subscription/data/paywall_v3_models.dart';
import 'package:bnood/features/subscription/data/subscription_riverpod.dart';
import '../../../../core/widgets/app_decision.dart';
import '../../../../core/widgets/toast/app_tone.dart';
import 'package:bnood/features/subscription/presentation/actions/paywall_launcher.dart';

/// Subscription cap kinds surfaced when entitlements block an action.
enum SubscriptionLimitKind {
  activeProjects,
  clients,
  financialTransactions,
  archiveClient,
}

typedef _LimitCopy = ({String title, String? message});

/// When paywall surfaces are on, opens the paywall; otherwise a neutral info dialog.
abstract final class SubscriptionLimitHandler {
  static AppSubscriptionSnapshot? _readSnapshot(
    WidgetRef? ref,
    BuildContext context,
  ) {
    if (ref != null) {
      return ref.read(subscriptionProvider).valueOrNull;
    }
    return ProviderScope.containerOf(
      context,
      listen: false,
    ).read(subscriptionProvider).valueOrNull;
  }

  static PaywallFetchTrigger _paywallTrigger(SubscriptionLimitKind kind) {
    return switch (kind) {
      SubscriptionLimitKind.activeProjects ||
      SubscriptionLimitKind.clients => PaywallFetchTrigger.limitReached,
      _ => PaywallFetchTrigger.defaultTrigger,
    };
  }

  static _LimitCopy _copyFor(
    AppLocalizations l10n,
    SubscriptionLimitKind kind,
    int? cap,
  ) {
    final limitText = cap == null ? null : DisplayDigits.formatInteger(cap);
    return switch (kind) {
      SubscriptionLimitKind.activeProjects => (
        title: l10n.subscriptionLimitProjectsTitle,
        message: limitText == null
            ? null
            : l10n.subscriptionLimitProjectsMessage(limitText),
      ),
      SubscriptionLimitKind.clients => (
        title: l10n.subscriptionLimitClientsTitle,
        message: limitText == null
            ? null
            : l10n.subscriptionLimitClientsMessage(limitText),
      ),
      SubscriptionLimitKind.financialTransactions => (
        title: l10n.subscriptionLimitFinancialTitle,
        message: null,
      ),
      SubscriptionLimitKind.archiveClient => (
        title: l10n.subscriptionLimitArchiveClientTitle,
        message: null,
      ),
    };
  }

  /// Presents paywall or info dialog. Returns when dismissed.
  static Future<void> presentBlocked({
    required BuildContext context,
    WidgetRef? ref,
    required SubscriptionLimitKind kind,
    AppSubscriptionSnapshot? snapshot,
    int? cap,
  }) async {
    if (!context.mounted) return;
    snapshot ??= _readSnapshot(ref, context);
    if (snapshot?.bypassSubscriptionLimits ?? false) {
      return;
    }
    final showPaywall = snapshot?.showSurfaces ?? false;

    if (showPaywall) {
      await PaywallLauncher.present(context, ref, _paywallTrigger(kind));
      return;
    }

    final l10n = AppLocalizations.of(context);
    final resolvedCap = cap ?? snapshot?.entitlements.activeProjectCap;
    final copy = _copyFor(l10n, kind, resolvedCap);
    await AppDecision.show(
      context,
      title: copy.title,
      description: copy.message,
      confirmLabel: l10n.subscriptionLimitDismiss,
      cancelLabel: null,
      tone: AppTone.brand,
    );
  }

  /// Returns `false` when the limit UI was shown (action must not proceed).
  static Future<bool> gate({
    required BuildContext context,
    WidgetRef? ref,
    required SubscriptionLimitKind kind,
    required bool allowed,
    int? cap,
    AppSubscriptionSnapshot? snapshot,
  }) async {
    snapshot ??= _readSnapshot(ref, context);
    if (snapshot?.bypassSubscriptionLimits ?? false) {
      return true;
    }
    if (allowed) return true;
    await presentBlocked(
      context: context,
      ref: ref,
      kind: kind,
      cap: cap,
      snapshot: snapshot,
    );
    return false;
  }
}
