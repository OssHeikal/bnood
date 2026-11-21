import 'package:flutter/material.dart';

import '../../../core/config/theme/app_size.dart';
import '../paywall_theme.dart';
import 'paywall_icon_mapper.dart';

class PaywallBenefitRow extends StatelessWidget {
  const PaywallBenefitRow({
    super.key,
    required this.text,
    this.iconKey,
    this.textStyle,
    this.isLast = false,
  });

  final String text;
  final String? iconKey;
  final TextStyle? textStyle;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final style = textStyle ?? PaywallTheme.of(context).benefit;
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSize.spaceSM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (iconKey != null)
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: paywallBenefitIcon(iconKey!),
            )
          else
            const _CheckGlyph(),
          const SizedBox(width: AppSize.spaceSM),
          Expanded(
            child: Text(
              text,
              style: style,
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckGlyph extends StatelessWidget {
  const _CheckGlyph();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.circle, size: 18, color: const Color(0xFF0F9D8E).withValues(alpha: 0.12)),
          const Icon(Icons.check, size: 12, color: Color(0xFF0F9D8E)),
        ],
      ),
    );
  }
}