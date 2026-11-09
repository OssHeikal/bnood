import 'package:flutter/material.dart';

import 'app_accent.dart';
import 'app_font.dart';

/// Semantic colors (index.html). ThemeExtension for foundation/preview widgets.
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.canvas,
    required this.surface,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.primary,
    required this.primaryDark,
    required this.onPrimary,
    required this.primaryPressed,
    required this.primaryDisabled,
    required this.error,
    required this.errorPressed,
    required this.onError,
    required this.outline,
    required this.muted,
    required this.warning,
    required this.success,
    required this.successBg,
    required this.warningBg,
    required this.errorBg,
    required this.primaryTint,
    required this.primaryOnTint,
    required this.surfaceSunken,
    required this.outlineSubtle,
    required this.remaining,
    required this.receive,
    required this.spend,
    required this.buttonShadow,
    required this.accentTeal,
    required this.info,
    required this.infoBg,
    required this.infoOnTint,
    required this.textTertiary,
    required this.textDisabled,
    required this.onSolid,
    required this.primarySoft,
    required this.warningStrong,
  });

  static const light = AppColors(
    canvas: Color(0xFFF4F7F6),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1A2422),
    onSurfaceMuted: Color(0xFF5C6B68),
    primary: Color(0xFF0D9B8A),
    primaryDark: Color(0xFF0A7A6C),
    onPrimary: Color(0xFFFFFFFF),
    primaryPressed: Color(0xFF0A7A6C),
    primaryDisabled: Color(0xFFB8D9D4),
    error: Color(0xFFD64545),
    errorPressed: Color(0xFFB83838),
    onError: Color(0xFFFFFFFF),
    outline: Color(0xFFD5DEDC),
    muted: Color(0xFF5C6B68),
    warning: Color(0xFFE6A23C),
    success: Color(0xFF1B9E5A),
    successBg: Color(0xFFE8F8EF),
    warningBg: Color(0xFFFFF8ED),
    errorBg: Color(0xFFFCECEC),
    primaryTint: Color(0x1F0D9B8A),
    primaryOnTint: Color(0xFF0A7A6C),
    surfaceSunken: Color(0xFFEEF2F1),
    outlineSubtle: Color(0xFFE8EDEC),
    remaining: Color(0xFF0D9B8A),
    receive: Color(0xFF1B9E5A),
    spend: Color(0xFFD64545),
    buttonShadow: BoxShadow(color: Color(0x0F1A2422), blurRadius: 12, offset: Offset(0, 2)),
    accentTeal: AppAccent(tint: Color(0xFFE6F6F4), border: Color(0xFFCFE6E1), ink: Color(0xFF0D9B8A)),
    info: Color(0xFF0A7A6C),
    infoBg: Color(0xFFE6F6F4),
    infoOnTint: Color(0xFF0A7A6C),
    textTertiary: Color(0xFF5C6B68),
    textDisabled: Color(0xFFB8D9D4),
    onSolid: Color(0xFFFFFFFF),
    primarySoft: Color(0xFFEEF2F1),
    warningStrong: Color(0xFFB8860B),
  );

  static const dark = AppColors(
    canvas: Color(0xFF121817),
    surface: Color(0xFF1E2624),
    onSurface: Color(0xFFE8EDEC),
    onSurfaceMuted: Color(0xFF9AA8A5),
    primary: Color(0xFF0D9B8A),
    primaryDark: Color(0xFF14B8A6),
    onPrimary: Color(0xFFFFFFFF),
    primaryPressed: Color(0xFF0A7A6C),
    primaryDisabled: Color(0xFF2A403C),
    error: Color(0xFFD64545),
    errorPressed: Color(0xFFB83838),
    onError: Color(0xFFFFFFFF),
    outline: Color(0xFF3A4543),
    muted: Color(0xFF9AA8A5),
    warning: Color(0xFFE6A23C),
    success: Color(0xFF1B9E5A),
    successBg: Color(0xFF0D2A1C),
    warningBg: Color(0xFF2E2410),
    errorBg: Color(0xFF351818),
    primaryTint: Color(0x330D9B8A),
    primaryOnTint: Color(0xFF14B8A6),
    surfaceSunken: Color(0xFF161E1C),
    outlineSubtle: Color(0xFF2A3230),
    remaining: Color(0xFF14B8A6),
    receive: Color(0xFF1B9E5A),
    spend: Color(0xFFD64545),
    buttonShadow: BoxShadow(color: Color(0x66000000), blurRadius: 12, offset: Offset(0, 2)),
    accentTeal: AppAccent(tint: Color(0xFF1A2E2B), border: Color(0xFF264540), ink: Color(0xFF14B8A6)),
    info: Color(0xFF14B8A6),
    infoBg: Color(0xFF1A2E2B),
    infoOnTint: Color(0xFF14B8A6),
    textTertiary: Color(0xFF9AA8A5),
    textDisabled: Color(0xFF2A403C),
    onSolid: Color(0xFFFFFFFF),
    primarySoft: Color(0xFF161E1C),
    warningStrong: Color(0xFFE6A23C),
  );

  final Color canvas;
  final Color surface;
  final Color onSurface;
  final Color onSurfaceMuted;
  final Color primary;
  final Color primaryDark;
  final Color onPrimary;
  final Color primaryPressed;
  final Color primaryDisabled;
  final Color error;
  final Color errorPressed;
  final Color onError;
  final Color outline;
  final Color muted;
  final Color warning;
  final Color success;
  final Color successBg;
  final Color warningBg;
  final Color errorBg;
  final Color primaryTint;
  final Color primaryOnTint;
  final Color surfaceSunken;
  final Color outlineSubtle;
  final Color remaining;
  final Color receive;
  final Color spend;
  final BoxShadow buttonShadow;
  final AppAccent accentTeal;
  final Color info;
  final Color infoBg;
  final Color infoOnTint;
  final Color textTertiary;
  final Color textDisabled;
  final Color onSolid;
  final Color primarySoft;
  final Color warningStrong;

  @override
  AppColors copyWith({
    Color? canvas,
    Color? surface,
    Color? onSurface,
    Color? onSurfaceMuted,
    Color? primary,
    Color? primaryDark,
    Color? onPrimary,
    Color? primaryPressed,
    Color? primaryDisabled,
    Color? error,
    Color? errorPressed,
    Color? onError,
    Color? outline,
    Color? muted,
    Color? warning,
    Color? success,
    Color? successBg,
    Color? warningBg,
    Color? errorBg,
    Color? tint,
    Color? primaryOnTint,
    Color? surfaceSunken,
    Color? outlineSubtle,
    Color? remaining,
    Color? receive,
    Color? spend,
    BoxShadow? buttonShadow,
    AppAccent? accentTeal,
    Color? info,
    Color? infoBg,
    Color? infoOnTint,
    Color? textTertiary,
    Color? textDisabled,
    Color? onSolid,
    Color? primarySoft,
    Color? warningStrong,
  }) {
    return AppColors(
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceMuted: onSurfaceMuted ?? this.onSurfaceMuted,
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryPressed: primaryPressed ?? this.primaryPressed,
      primaryDisabled: primaryDisabled ?? this.primaryDisabled,
      error: error ?? this.error,
      errorPressed: errorPressed ?? this.errorPressed,
      onError: onError ?? this.onError,
      outline: outline ?? this.outline,
      muted: muted ?? this.muted,
      warning: warning ?? this.warning,
      success: success ?? this.success,
      successBg: successBg ?? this.successBg,
      warningBg: warningBg ?? this.warningBg,
      errorBg: errorBg ?? this.errorBg,
      primaryTint: tint ?? primaryTint,
      primaryOnTint: primaryOnTint ?? this.primaryOnTint,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      outlineSubtle: outlineSubtle ?? this.outlineSubtle,
      remaining: remaining ?? this.remaining,
      receive: receive ?? this.receive,
      spend: spend ?? this.spend,
      buttonShadow: buttonShadow ?? this.buttonShadow,
      accentTeal: accentTeal ?? this.accentTeal,
      info: info ?? this.info,
      infoBg: infoBg ?? this.infoBg,
      infoOnTint: infoOnTint ?? this.infoOnTint,
      textTertiary: textTertiary ?? this.textTertiary,
      textDisabled: textDisabled ?? this.textDisabled,
      onSolid: onSolid ?? this.onSolid,
      primarySoft: primarySoft ?? this.primarySoft,
      warningStrong: warningStrong ?? this.warningStrong,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      canvas: l(canvas, other.canvas),
      surface: l(surface, other.surface),
      onSurface: l(onSurface, other.onSurface),
      onSurfaceMuted: l(onSurfaceMuted, other.onSurfaceMuted),
      primary: l(primary, other.primary),
      primaryDark: l(primaryDark, other.primaryDark),
      onPrimary: l(onPrimary, other.onPrimary),
      primaryPressed: l(primaryPressed, other.primaryPressed),
      primaryDisabled: l(primaryDisabled, other.primaryDisabled),
      error: l(error, other.error),
      errorPressed: l(errorPressed, other.errorPressed),
      onError: l(onError, other.onError),
      outline: l(outline, other.outline),
      muted: l(muted, other.muted),
      warning: l(warning, other.warning),
      success: l(success, other.success),
      successBg: l(successBg, other.successBg),
      warningBg: l(warningBg, other.warningBg),
      errorBg: l(errorBg, other.errorBg),
      primaryTint: l(primaryTint, other.primaryTint),
      primaryOnTint: l(primaryOnTint, other.primaryOnTint),
      surfaceSunken: l(surfaceSunken, other.surfaceSunken),
      outlineSubtle: l(outlineSubtle, other.outlineSubtle),
      remaining: l(remaining, other.remaining),
      receive: l(receive, other.receive),
      spend: l(spend, other.spend),
      buttonShadow: buttonShadow,
      accentTeal: accentTeal,
      info: l(info, other.info),
      infoBg: l(infoBg, other.infoBg),
      infoOnTint: l(infoOnTint, other.infoOnTint),
      textTertiary: l(textTertiary, other.textTertiary),
      textDisabled: l(textDisabled, other.textDisabled),
      onSolid: l(onSolid, other.onSolid),
      primarySoft: l(primarySoft, other.primarySoft),
      warningStrong: l(warningStrong, other.warningStrong),
    );
  }
}

extension ThemeContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;

  AppText get text => Theme.of(this).extension<AppText>()!;
}

// Forward declare — defined in app_text.dart
class AppText extends ThemeExtension<AppText> {
  const AppText({
    required this.balance,
    required this.appBarTitle,
    required this.pageTitle,
    required this.sectionTitle,
    required this.cardTitle,
    required this.body,
    required this.bodyEmphasis,
    required this.label,
    required this.supporting,
    required this.caption,
    required this.button,
    required this.moneyMd,
    required this.moneySm,
    required this.groupTitle,
  });

  factory AppText.fromColors(AppColors colors) {
    TextStyle role({required double size, required double height, required double wght, Color? color}) {
      return AppFont.cairo(
        wght: wght,
        base: TextStyle(fontSize: size, height: height, color: color ?? colors.onSurface, letterSpacing: 0),
      );
    }

    return AppText(
      balance: role(size: 28, height: 1.15, wght: 700),
      appBarTitle: role(size: 22, height: 1.2, wght: 500),
      pageTitle: role(size: 22, height: 1.2, wght: 700),
      sectionTitle: role(size: 15, height: 1.25, wght: 700),
      cardTitle: role(size: 14, height: 1.3, wght: 700),
      body: role(size: 14, height: 1.4, wght: 400),
      bodyEmphasis: role(size: 14, height: 1.35, wght: 700),
      label: role(size: 13, height: 1.3, wght: 600, color: colors.muted),
      supporting: role(size: 13, height: 1.35, wght: 500, color: colors.muted),
      caption: role(size: 12, height: 1.4, wght: 500, color: colors.muted),
      button: role(size: 16, height: 1.3, wght: 600, color: colors.onPrimary),
      moneyMd: role(size: 18, height: 1.2, wght: 700).copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
      moneySm: role(size: 14, height: 1.2, wght: 700).copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
      groupTitle: role(size: 14, height: 1.22, wght: 600, color: colors.muted),
    );
  }

  final TextStyle balance;
  final TextStyle appBarTitle;
  final TextStyle pageTitle;
  final TextStyle sectionTitle;
  final TextStyle cardTitle;
  final TextStyle body;
  final TextStyle bodyEmphasis;
  final TextStyle label;
  final TextStyle supporting;
  final TextStyle caption;
  final TextStyle button;
  final TextStyle moneyMd;
  final TextStyle moneySm;
  final TextStyle groupTitle;

  // Legacy aliases for ported SmartRx widgets
  TextStyle get title => sectionTitle;
  TextStyle get titleLarge => pageTitle;
  TextStyle get bodyLarge => body;
  TextStyle get h3 => cardTitle;
  TextStyle get display => balance;

  @override
  AppText copyWith({
    TextStyle? balance,
    TextStyle? appBarTitle,
    TextStyle? pageTitle,
    TextStyle? sectionTitle,
    TextStyle? cardTitle,
    TextStyle? body,
    TextStyle? bodyEmphasis,
    TextStyle? label,
    TextStyle? supporting,
    TextStyle? caption,
    TextStyle? button,
    TextStyle? moneyMd,
    TextStyle? moneySm,
    TextStyle? groupTitle,
  }) {
    return AppText(
      balance: balance ?? this.balance,
      appBarTitle: appBarTitle ?? this.appBarTitle,
      pageTitle: pageTitle ?? this.pageTitle,
      sectionTitle: sectionTitle ?? this.sectionTitle,
      cardTitle: cardTitle ?? this.cardTitle,
      body: body ?? this.body,
      bodyEmphasis: bodyEmphasis ?? this.bodyEmphasis,
      label: label ?? this.label,
      supporting: supporting ?? this.supporting,
      caption: caption ?? this.caption,
      button: button ?? this.button,
      moneyMd: moneyMd ?? this.moneyMd,
      moneySm: moneySm ?? this.moneySm,
      groupTitle: groupTitle ?? this.groupTitle,
    );
  }

  @override
  AppText lerp(AppText? other, double t) {
    if (other == null) return this;
    TextStyle? l(TextStyle a, TextStyle b) => TextStyle.lerp(a, b, t);
    return AppText(
      balance: l(balance, other.balance)!,
      appBarTitle: l(appBarTitle, other.appBarTitle)!,
      pageTitle: l(pageTitle, other.pageTitle)!,
      sectionTitle: l(sectionTitle, other.sectionTitle)!,
      cardTitle: l(cardTitle, other.cardTitle)!,
      body: l(body, other.body)!,
      bodyEmphasis: l(bodyEmphasis, other.bodyEmphasis)!,
      label: l(label, other.label)!,
      supporting: l(supporting, other.supporting)!,
      caption: l(caption, other.caption)!,
      button: l(button, other.button)!,
      moneyMd: l(moneyMd, other.moneyMd)!,
      moneySm: l(moneySm, other.moneySm)!,
      groupTitle: l(groupTitle, other.groupTitle)!,
    );
  }
}
