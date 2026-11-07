import 'package:bnood/core/config/theme/app_colors.dart';
import 'package:bnood/core/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('light stat gradients keep approved pastels', () {
    final receive = AppCard.statCardGradient(
      AppCardPreset.statReceive,
      AppColors.light,
      Brightness.light,
    ) as LinearGradient;
    expect(receive.colors.first, const Color(0xFFE8F8EF));
  });

  test('dark stat gradients use dark semantic tints', () {
    final receive = AppCard.statCardGradient(
      AppCardPreset.statReceive,
      AppColors.dark,
      Brightness.dark,
    ) as LinearGradient;
    expect(receive.colors.first, AppColors.dark.successBg);
    expect(receive.colors.first, isNot(const Color(0xFFE8F8EF)));

    final remaining = AppCard.statCardGradient(
      AppCardPreset.statRemaining,
      AppColors.dark,
      Brightness.dark,
    ) as LinearGradient;
    expect(remaining.colors.first, AppColors.dark.infoBg);
  });

  test('dark foundation colors use dark stat palette when theme brightness is light', () {
    expect(AppCard.usesDarkStatPalette(AppColors.dark, Brightness.light), isTrue);
    final receive = AppCard.statCardGradient(
      AppCardPreset.statReceive,
      AppColors.dark,
      Brightness.light,
    ) as LinearGradient;
    expect(receive.colors.first, AppColors.dark.successBg);
  });
}
