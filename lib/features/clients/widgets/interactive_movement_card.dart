import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/theme/app_size.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/app_card.dart';
import '../../vouchers/voucher_launcher.dart';
import '../client_detail_snapshot.dart';
import '../voucher_draft_from_transaction.dart';
import 'client_movement_card.dart';

/// Tap opens edit voucher sheet (delete lives in that sheet only).
class InteractiveMovementCard extends ConsumerStatefulWidget {
  const InteractiveMovementCard({
    super.key,
    required this.line,
    required this.localeCode,
    required this.mutationsEnabled,
    this.contextMode = ClientMovementCardContext.clientLedger,
    this.partyClientId,
    this.partyClientName,
    this.padding = const EdgeInsets.symmetric(vertical: AppSize.spaceSM),
  });

  final ClientDetailMovementLine line;
  final String localeCode;
  final bool mutationsEnabled;
  final ClientMovementCardContext contextMode;
  final String? partyClientId;
  final String? partyClientName;
  final EdgeInsetsGeometry padding;

  @override
  ConsumerState<InteractiveMovementCard> createState() => _InteractiveMovementCardState();
}

class _InteractiveMovementCardState extends ConsumerState<InteractiveMovementCard> {
  final _busy = false;

  Future<void> _openEdit() async {
    if (_busy || !widget.mutationsEnabled) return;
    final repo = ref.read(repositoryProvider);
    final draft = await voucherDraftFromTransaction(repo, widget.line.transaction);
    if (!mounted || draft == null) return;
    await VoucherLauncher.openEdit(context, draft);
  }

  @override
  Widget build(BuildContext context) {
    final canMutate = widget.mutationsEnabled && !_busy;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSize.spaceLG, vertical: AppSize.spaceXS),
      onTap: canMutate ? _openEdit : null,
      child: ClientMovementCard(
        line: widget.line,
        localeCode: widget.localeCode,
        padding: widget.padding,
        contextMode: widget.contextMode,
        partyClientId: widget.partyClientId,
        partyClientName: widget.partyClientName,
      ),
    );
  }
}
