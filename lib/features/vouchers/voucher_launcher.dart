import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/theme/app_size.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/bounded_sheet_navigator.dart';
import '../home/home_foundation_scope.dart';
import 'voucher_draft.dart';
import 'voucher_draft_enrich.dart';
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
    final repo = container.read(repositoryProvider);
    final enriched = await enrichVoucherDraft(repo, draft);
    if (!context.mounted) return;
    container.read(voucherDraftProvider.notifier).state = enriched;
    await _show(context);
  }

  static Future<void> _show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: false,
      builder: (ctx) {
        final bottomInset = MediaQuery.viewInsetsOf(ctx).bottom;
        final keyboardGap = bottomInset > 0 ? AppSize.spaceMD : 0.0;
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset > 0 ? bottomInset + keyboardGap : 0),
          child: HomeFoundationScope(
            child: BoundedSheetNavigator(
              builder: (_) => const VoucherSheet(),
            ),
          ),
        );
      },
    );
  }
}
