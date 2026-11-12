import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/formatting/see_all_label.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_fallback.dart';
import '../../../core/widgets/app_pressable.dart';
import '../../../l10n/app_localizations.dart';
import '../client_detail_snapshot.dart';
import 'client_detail_craftsman_row.dart';

class ClientDetailLinkedProvidersSection extends StatelessWidget {
  const ClientDetailLinkedProvidersSection({
    super.key,
    required this.title,
    required this.assignLabel,
    required this.emptyTitle,
    required this.emptyDescription,
    required this.seeAllRoute,
    required this.previews,
    required this.localeCode,
    required this.mutationsEnabled,
    required this.onAssign,
    this.totalCount,
  });

  final String title;
  final String assignLabel;
  final String emptyTitle;
  final String emptyDescription;
  final String seeAllRoute;
  final List<ClientCraftsmanPreviewRow> previews;
  final String localeCode;
  final bool mutationsEnabled;
  final VoidCallback onAssign;
  final int? totalCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = context.text;
    final colors = context.colors;
    final seeAll = seeAllLabelWithCount(
      l10n,
      sectionSeeAllCount(total: totalCount, visibleLength: previews.length),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: text.sectionTitle)),
            AppPressable(
              enabled: mutationsEnabled,
              onPressed: mutationsEnabled ? onAssign : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                child: Text(
                  assignLabel,
                  style: text.caption.copyWith(
                    color: mutationsEnabled ? colors.primaryDark : colors.onSurfaceMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            AppSize.spaceSM.gap,
            AppPressable(
              enabled: mutationsEnabled,
              onPressed: mutationsEnabled ? () => context.push(seeAllRoute) : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                child: Text(
                  seeAll,
                  style: text.caption.copyWith(
                    color: mutationsEnabled ? colors.primaryDark : colors.onSurfaceMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
        AppSize.spaceSM.gap,
        if (previews.isEmpty)
          AppCard(
            child: AppFallback.section(
              icon: Icons.group_outlined,
              title: emptyTitle,
              description: emptyDescription,
              actions: [
                if (mutationsEnabled)
                  AppFallbackAction(
                    label: assignLabel,
                    onPressed: onAssign,
                    role: AppFallbackActionRole.tertiary,
                  ),
              ],
            ),
          )
        else
          for (var i = 0; i < previews.length; i++) ...[
            if (i > 0) AppSize.spaceMD.gap,
            ClientDetailCraftsmanRow(preview: previews[i], localeCode: localeCode),
          ],
      ],
    );
  }
}
