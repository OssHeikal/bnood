import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';

import '../core/brand/app_brand_lockup.dart';
import '../core/config/theme/app_colors.dart';
import '../features/home/home_foundation_scope.dart';

/// Branded cold-start splash: canvas + centered hero lockup, single opacity fade.
class BnoodStartupSplash extends StatelessWidget {
  const BnoodStartupSplash({
    super.key,
    required this.brightness,
    required this.locale,
    required this.opacity,
  });

  final Brightness brightness;
  final Locale locale;
  final double opacity;

  static const splashLogoHeight = 212.0;
  static const splashFadeInDuration = Duration(milliseconds: 520);
  static const splashFadeOutDuration = Duration(milliseconds: 380);

  @override
  Widget build(BuildContext context) {
    final theme = brightness == Brightness.dark ? ThemeData.dark() : ThemeData.light();
    return Theme(
      data: theme,
      child: Localizations(
        locale: locale,
        delegates: AppLocalizations.localizationsDelegates,
        child: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context);
            final colors = brightness == Brightness.dark ? AppColors.dark : AppColors.light;
            return HomeFoundationScope(
              child: Opacity(
                opacity: opacity.clamp(0.0, 1.0),
                child: ColoredBox(
                  color: colors.canvas,
                  child: Semantics(
                    namesRoute: true,
                    label: l10n.appTitle,
                    child: Center(
                      child: RepaintBoundary(
                        child: ExcludeSemantics(
                          child: AppBrandLockup(
                            kind: AppBrandLockupKind.hero,
                            height: splashLogoHeight,
                            onDarkSurface: brightness == Brightness.dark,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
