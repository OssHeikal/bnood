import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'voucher_draft.dart';
import 'voucher_sheet.dart';

final voucherDraftProvider =
    StateProvider<VoucherDraft>((ref) => VoucherDraft.fresh);

class VoucherLauncher {
  static Future<void> openFresh(BuildContext context) async {
    final container = ProviderScope.containerOf(context);
    container.read(voucherDraftProvider.notifier).state =
        VoucherDraft.fresh.copyWith(date: DateTime.now());
    await _show(context);
  }

  static Future<void> openForClient(
    BuildContext context, {
    required String clientId,
    required String projectId,
    required String kind,
  }) async {
    final container = ProviderScope.containerOf(context);
    container.read(voucherDraftProvider.notifier).state = VoucherDraft(
      clientId: clientId,
      projectId: projectId,
      kind: kind,
      date: DateTime.now(),
    );
    await _show(context);
  }

  static Future<void> openEdit(BuildContext context, VoucherDraft draft) async {
    final container = ProviderScope.containerOf(context);
    container.read(voucherDraftProvider.notifier).state = draft;
    await _show(context);
  }

  static Future<void> _show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: const VoucherSheet(),
      ),
    );
  }
}
