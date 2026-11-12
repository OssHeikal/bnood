import 'package:flutter/material.dart';

import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_shape.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/theme/app_colors.dart' as legacy;
import '../../../core/widgets/app_card.dart';
import '../../../l10n/app_localizations.dart';

/// Remote home craftsman snapshot — name only (matches providers list compact meta).
class HomeCraftsmanPreviewCard extends StatelessWidget {
  const HomeCraftsmanPreviewCard({
    super.key,
    required this.name,
    required this.accentKey,
    required this.onTap,
  });

  final String name;
  final String accentKey;
  final VoidCallback onTap;

  static const _stripeWidth = 4.0;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final accent = legacy.AppColors.accent(accentKey);

    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      radius: AppSize.radiusMD,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ColoredBox(
              color: accent,
              child: const SizedBox(width: _stripeWidth),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSize.spaceLG,
                  vertical: AppSize.spaceMD,
                ),
                child: Row(
                  children: [
                    _Avatar(initial: name.isNotEmpty ? name[0] : '?', accent: accent),
                    AppSize.spaceMD.gap,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            name,
                            style: text.bodyEmphasis,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                          ),
                          AppSize.spaceXS.gap,
                          Text(
                            l10n.directoryCraftsmanKindMeta,
                            style: text.caption.copyWith(color: colors.onSurfaceMuted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initial, required this.accent});

  final String initial;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: AppShape.superellipse(radius: 14),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [accent, Color.lerp(accent, Colors.black, 0.25)!],
          ),
        ),
        child: SizedBox(
          width: AppSize.hitMin,
          height: AppSize.hitMin,
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
