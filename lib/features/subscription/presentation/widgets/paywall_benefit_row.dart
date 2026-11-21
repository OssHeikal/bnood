import 'package:flutter/material.dart';

import '../../../../core/services/config/theme/app_size.dart';
import 'package:bnood/features/subscription/presentation/widgets/paywall_theme.dart';
import 'package:bnood/features/subscription/presentation/widgets/paywall_icon_mapper.dart';

class PaywallBenefitRow extends StatelessWidget {
  const PaywallBenefitRow({
    super.key,
    required this.text,
    this.iconKey,
    this.textStyle,
    this.isLast = false,
    this.dense = false,
  });

  final String text;
  final String? iconKey;
  final TextStyle? textStyle;
  final bool isLast;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final style = textStyle ?? PaywallTheme.of(context).benefit;
    final rowGap = dense ? AppSize.spaceXS : AppSize.spaceSM;
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : rowGap),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (iconKey != null)
            Padding(
              padding: EdgeInsets.only(top: dense ? 0 : 1),
              child: paywallBenefitIcon(iconKey!, size: dense ? 15 : 18),
            )
          else
            _CheckGlyph(compact: dense),
          SizedBox(width: rowGap),
          Expanded(
            child: Text(
              text,
              style: style,
              textAlign: TextAlign.start,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckGlyph extends StatelessWidget {
  const _CheckGlyph({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 15.0 : 18.0;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.circle,
            size: size,
            color: const Color(0xFF0F9D8E).withValues(alpha: 0.12),
          ),
          Icon(
            Icons.check,
            size: compact ? 10 : 12,
            color: const Color(0xFF0F9D8E),
          ),
        ],
      ),
    );
  }
}
