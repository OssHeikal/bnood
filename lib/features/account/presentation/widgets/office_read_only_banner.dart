import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/account/account_office_providers.dart';
import '../../../../core/services/config/extensions/num_extensions.dart';
import '../../../../core/services/config/theme/app_colors.dart';
import '../../../../core/services/config/theme/app_size.dart';
import '../../../../core/ui/widgets/app_card.dart';
import 'package:bnood/l10n/app_localizations.dart';

class OfficeReadOnlyBanner extends ConsumerWidget {
  const OfficeReadOnlyBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(officeReadOnlyBannerVisibleProvider)) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final text = context.text;

    return Column(
      children: [
        AppCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: colors.warning, size: AppSize.icon),
              AppSize.spaceMD.gap,
              Expanded(
                child: Text(
                  l10n.officeReadOnlyBanner,
                  style: text.body.copyWith(color: colors.onSurface),
                ),
              ),
            ],
          ),
        ),
        AppSize.spaceMD.gap,
      ],
    );
  }
}