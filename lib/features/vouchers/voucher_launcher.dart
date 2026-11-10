import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../core/vouchers/vouchers_riverpod.dart';
import '../../core/widgets/bnood_modal_sheet.dart';
import '../../core/widgets/bounded_sheet_navigator.dart';
import '../home/home_foundation_scope.dart';
import '../subscription/subscription_gates.dart';
import 'voucher_draft.dart';
import 'voucher_draft_enrich.dart';
import 'voucher_draft_enrich_remote.dart';
import 'voucher_sheet.dart';

final voucherDraftProvider =
    StateProvider<VoucherDraft>((ref) => VoucherDraft.fresh);

class VoucherLauncher {
  /// Home satellite `+` ([FloatingShellDock.onVoucher] → [openFresh]): spend (صرف) by default.
  static VoucherDraft draftForFreshEntry({DateTime? date}) {
    return VoucherDraft.fresh.copyWith(
      kind: 'spend',
      date: date ?? DateTime.now(),
    );
  }

  /// Opens a single root bottom sheet; all pickers push on the nested [Navigator].
  static Future<void> openFresh(BuildContext context) async {
    final container = ProviderScope.containerOf(context);
    container.read(voucherDraftProvider.notifier).state = draftForFreshEntry();
    await _show(context);
  }

  static Future<void> openForClient(
    BuildContext context, {
    required String clientId,
    required String projectId,
    required String kind,
    String? clientLabel,
  }) async {
    final container = ProviderScope.containerOf(context);
    container.read(voucherDraftProvider.notifier).state = VoucherDraft(
      clientId: clientId,
      projectId: projectId,
      clientLabel: clientLabel,
      kind: kind,
      date: DateTime.now(),
    );
    await _show(context);
  }

  static Future<void> openEdit(BuildContext context, VoucherDraft draft) async {
    final container = ProviderScope.containerOf(context);
    final VoucherDraft enriched;
    if (container.read(remoteVouchersEnabledProvider)) {
      enriched = await enrichVoucherDraftRemote(ProviderScope.containerOf(context), draft);
    } else {
      final repo = container.read(repositoryProvider);
      enriched = await enrichVoucherDraft(repo, draft);
    }
    if (!context.mounted) return;
    container.read(voucherDraftProvider.notifier).state = enriched;
    await _show(context);
  }

  static Future<void> _show(BuildContext context) async {
    final container = ProviderScope.containerOf(context);
    if (container.read(remoteVouchersEnabledProvider)) {
      if (!await guardFinancialMutationFromContainer(context, container)) return;
    }
    if (!context.mounted) return;
    await BnoodModalSheet.show<void>(
      context: context,
      builder: (_) => HomeFoundationScope(
        child: BoundedSheetNavigator(builder: (_) => const VoucherSheet()),
      ),
    );
  }
}
