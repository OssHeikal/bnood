import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';

import '../core/brand/app_brand_lockup.dart';
import '../core/config/theme/app_colors.dart';
import '../features/home/home_foundation_scope.dart';
import 'bnood_splash_session.dart';

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
    final theme = brightness == Brightness.dark
        ? ThemeData.dark()
        : ThemeData.light();
    return Theme(
      data: theme,
      child: Localizations(
        locale: locale,
        delegates: AppLocalizations.localizationsDelegates,
        child: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context);
            final colors = brightness == Brightness.dark
                ? AppColors.dark
                : AppColors.light;
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

/// Cold-start route. Fades in, fades out, then replaces itself with home.
class BnoodStartupSplashPage extends StatefulWidget {
  const BnoodStartupSplashPage({super.key});

  static const path = '/splash';
  static const handoffLocation = '/auth/bootstrap';

  @override
  State<BnoodStartupSplashPage> createState() => _BnoodStartupSplashPageState();
}

class _BnoodStartupSplashPageState extends State<BnoodStartupSplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fade;
  late final CurvedAnimation _fadeOpacity;
  var _fadeInDone = false;
  var _fadingOut = false;
  var _left = false;

  @override
  void initState() {
    super.initState();
    _fade = AnimationController(
      vsync: this,
      duration: BnoodStartupSplash.splashFadeInDuration,
    );
    _fadeOpacity = CurvedAnimation(
      parent: _fade,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
    _fade.addStatusListener(_onFadeStatus);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _startFadeInIfNeeded();
      _tryHandoff();
    });
  }

  void _onFadeStatus(AnimationStatus status) {
    if (_left) return;
    if (status == AnimationStatus.completed) {
      _fadeInDone = true;
      _tryHandoff();
    } else if (status == AnimationStatus.dismissed && _fadingOut) {
      _leave();
    }
  }

  void _startFadeInIfNeeded() {
    if (!mounted || _left) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _leave();
      return;
    }
    if (_fade.status == AnimationStatus.dismissed) {
      _fade.forward();
    }
  }

  void _tryHandoff() {
    if (!mounted || _left || _fadingOut || !_fadeInDone) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _leave();
      return;
    }
    _fadingOut = true;
    _fade.duration = BnoodStartupSplash.splashFadeOutDuration;
    _fade.reverse();
  }

  void _leave() {
    if (_left || !mounted) return;
    _left = true;
    BnoodSplashSession.completed = true;
    context.go(BnoodStartupSplashPage.handoffLocation);
  }

  @override
  void dispose() {
    _fadeOpacity.dispose();
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeOpacity,
      builder: (context, _) {
        return BnoodStartupSplash(
          brightness: Theme.of(context).brightness,
          locale: Localizations.localeOf(context),
          opacity: _fadeOpacity.value,
        );
      },
    );
  }
}
