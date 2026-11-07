import 'package:flutter/material.dart';

import '../client_detail_snapshot.dart';
import 'client_movement_card.dart';

/// Detail movements section; delegates to [ClientMovementCard].
class ClientDetailMovementRow extends StatelessWidget {
  const ClientDetailMovementRow({
    super.key,
    required this.line,
    required this.localeCode,
    this.contextMode = ClientMovementCardContext.clientLedger,
    this.partyClientId,
    this.partyClientName,
  });

  final ClientDetailMovementLine line;
  final String localeCode;
  final ClientMovementCardContext contextMode;
  final String? partyClientId;
  final String? partyClientName;

  @override
  Widget build(BuildContext context) {
    return ClientMovementCard(
      line: line,
      localeCode: localeCode,
      contextMode: contextMode,
      partyClientId: partyClientId,
      partyClientName: partyClientName,
    );
  }
}
