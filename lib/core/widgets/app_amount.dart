import 'package:flutter/material.dart';

import '../config/theme/app_colors.dart';
import '../config/theme/app_font.dart';
import '../money/money_format.dart';
import '../utils/extensions/bidi_isolate.dart';

enum AppAmountRole { receive, spend, remaining, neutral }

enum AppAmountSize { balance, medium, small }

/// Integer piastres → localized display with semantic color and bidi rules.
class AppAmount extends StatelessWidget {
  const AppAmount({
    super.key,
    required this.piastres,
    this.role = AppAmountRole.neutral,
    this.size = AppAmountSize.medium,
    this.localeCode = 'ar',
    this.showCurrency = true,
    this.showSign = false,
    this.style,
  });

  final int piastres;
  final AppAmountRole role;
  final AppAmountSize size;
  final String localeCode;
  final bool showCurrency;
  final bool showSign;
  final TextStyle? style;

  static String format({
    required int piastres,
    String localeCode = 'ar',
    bool showCurrency = true,
  }) {
    final locale = localeCode == 'ar' ? 'ar_EG' : 'en_US';
    final text = MoneyFormat.formatPiastres(piastres, locale: locale);
    if (!showCurrency) {
      return MoneyFormat.withoutCurrencySuffix(text);
    }
    return text;
  }

  Color _color(AppColors colors) {
    if (role == AppAmountRole.remaining) {
      if (piastres < 0) return colors.spend;
      if (piastres > 0) return colors.remaining;
      return colors.onSurface;
    }
    return switch (role) {
      AppAmountRole.receive => colors.receive,
      AppAmountRole.spend => colors.spend,
      AppAmountRole.remaining => colors.remaining,
      AppAmountRole.neutral => colors.onSurface,
    };
  }

  String _displayText() {
    if (role == AppAmountRole.remaining) {
      if (piastres < 0) {
        final body = format(piastres: piastres.abs(), localeCode: localeCode, showCurrency: showCurrency);
        return '−$body';
      }
      return format(piastres: piastres, localeCode: localeCode, showCurrency: showCurrency);
    }
    final sign = showSign && piastres != 0 ? (piastres > 0 ? '+' : '−') : '';
    final body = format(piastres: piastres.abs(), localeCode: localeCode, showCurrency: showCurrency);
    return sign.isEmpty ? body : '$sign$body';
  }

  TextStyle _base(AppText text) => switch (size) {
        AppAmountSize.balance => text.balance,
        AppAmountSize.medium => text.moneyMd,
        AppAmountSize.small => text.moneySm,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final display = _displayText();
    final resolved = (style ?? _base(text)).copyWith(color: _color(colors));
    return Text(
      LtrIsolate.isolate(display),
      style: AppFont.w700(resolved),
      textDirection: TextDirection.ltr,
    );
  }
}
