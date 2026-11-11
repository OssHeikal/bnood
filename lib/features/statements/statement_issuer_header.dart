import 'package:flutter/material.dart';

import '../../core/clients/client_statement_record.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/utils/extensions/bidi_isolate.dart';
import '../auth/widgets/user_identity_avatar.dart';

/// Statement document header: issuer logo, name, and contact phone (LTR).
class StatementIssuerHeader extends StatelessWidget {
  const StatementIssuerHeader({super.key, required this.issuer});

  final StatementIssuer issuer;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final colors = context.colors;
    final logoUrl = issuer.logoUrl?.trim();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (logoUrl != null && logoUrl.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSize.radiusSM),
            child: Image.network(
              logoUrl,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => UserIdentityAvatar(displayName: issuer.name, size: 48),
            ),
          )
        else
          UserIdentityAvatar(displayName: issuer.name, size: 48),
        const SizedBox(width: AppSize.spaceMD),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(issuer.name, style: text.sectionTitle, textAlign: TextAlign.start, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: AppSize.spaceXS),
              Text(
                LtrIsolate.isolate(issuer.contactPhone),
                style: text.body.copyWith(color: colors.onSurfaceMuted),
                textAlign: TextAlign.start,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
