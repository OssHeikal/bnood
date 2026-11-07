import 'package:flutter/material.dart';

import '../client_detail_snapshot.dart';
import 'client_movement_card.dart';

/// Detail movements section; delegates to [ClientMovementCard].
class ClientDetailMovementRow extends StatelessWidget {
  const ClientDetailMovementRow({
    super.key,
    required this.line,
    required this.localeCode,
  });

  final ClientDetailMovementLine line;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    return ClientMovementCard(line: line, localeCode: localeCode);
  }
}
