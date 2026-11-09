import 'package:flutter/material.dart';

import '../provider_detail_snapshot.dart';
import 'provider_detail_client_agreement_actions.dart';
import 'provider_detail_client_agreement_card.dart';

class ProviderDetailLinkedClientBlock extends StatelessWidget {
  const ProviderDetailLinkedClientBlock({
    super.key,
    required this.row,
    required this.providerId,
    required this.providerName,
    required this.localeCode,
    required this.onChanged,
  });

  final ProviderDetailClientRow row;
  final String providerId;
  final String providerName;
  final String localeCode;
  final Future<void> Function() onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProviderDetailClientAgreementCard(
          row: row,
          localeCode: localeCode,
          clipBottom: true,
        ),
        ProviderDetailClientAgreementActions(
          row: row,
          providerId: providerId,
          providerName: providerName,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
