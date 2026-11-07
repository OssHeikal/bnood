import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'voucher_draft.dart';
import 'voucher_sheet.dart';

final voucherDraftProvider =
    StateProvider<VoucherDraft>((ref) => VoucherDraft.fresh);

class VoucherLauncher {
  /// Opens a single root bottom sheet; all pickers push on the nested [Navigator].
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
    container.read(voucherDraftProvider.notifier).state = draft;
    await _show(context);
  }

  static Future<void> _show(BuildContext context) {
    final sheetNavKey = GlobalKey<NavigatorState>();
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
          child: SizedBox(
            height: MediaQuery.sizeOf(ctx).height * 0.88,
            child: Navigator(
              key: sheetNavKey,
              onGenerateRoute: (settings) {
                return MaterialPageRoute<void>(
                  builder: (_) => const VoucherSheet(),
                  settings: settings,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
