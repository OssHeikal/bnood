import 'dart:async';

import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/brand/app_brand_lockup.dart';
import '../core/config/theme/app_colors.dart';
import '../core/app_gate/app_config_record.dart';
import '../features/app_gate/app_gate_cold_start.dart';
import '../features/app_gate/app_gate_provider.dart';
import '../features/app_gate/app_gate_session.dart';
import '../features/auth/auth_controller.dart';
import '../features/auth/auth_state.dart';
import '../features/home/home_foundation_scope.dart';
import 'app_splash_routing.dart';
import 'app_splash_session.dart';

/// Branded cold-start splash canvas + hero lockup (logo opacity animated).
class AppStartupSplash extends StatelessWidget {
  const AppStartupSplash({
    super.key,
    required this.brightness,
    required this.locale,
    required this.logoOpacity,
    this.logoScale = 1,
    this.showSessionWait = false,
  });

  final Brightness brightness;
  final Locale locale;
  final double logoOpacity;
  final double logoScale;
  final bool showSessionWait;

  static const splashLogoHeight = 212.0;
  static const splashEntranceDuration = Duration(milliseconds: 420);
  static const splashMinDisplayDuration = Duration(milliseconds: 520);
  static const splashBootstrapTimeout = Duration(seconds: 12);

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
              child: ColoredBox(
                color: colors.canvas,
                child: Semantics(
                  namesRoute: true,
                  label: l10n.appTitle,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RepaintBoundary(
                          child: ExcludeSemantics(
                            child: Opacity(
                              opacity: logoOpacity.clamp(0.0, 1.0),
                              child: Transform.scale(
                                scale: logoScale,
                                child: AppBrandLockup(
                                  kind: AppBrandLockupKind.hero,
                                  height: splashLogoHeight,
                                  onDarkSurface: brightness == Brightness.dark,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (showSessionWait) ...[
                          const SizedBox(height: 28),
                          const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator.adaptive(
                              strokeWidth: 2,
                            ),
                          ),
                        ],
                      ],
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

/// Cold-start route. Entrance animation, then holds until auth bootstrap completes.
class AppStartupSplashPage extends ConsumerStatefulWidget {
  const AppStartupSplashPage({super.key});

  static const path = '/splash';

  @override
  ConsumerState<AppStartupSplashPage> createState() =>
      _AppStartupSplashPageState();
}

class _AppStartupSplashPageState extends ConsumerState<AppStartupSplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  Timer? _bootstrapTimeout;
  Timer? _minDisplayTimer;
  var _minDisplayElapsed = false;
  var _entranceDone = false;
  var _left = false;
  var _reducedMotion = false;
  var _configReady = false;
  AppConfigData? _gateConfig;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: AppStartupSplash.splashEntranceDuration,
    );
    _logoOpacity = CurvedAnimation(
      parent: _entrance,
      curve: Curves.easeOutCubic,
    );
    _logoScale = Tween<double>(begin: 0.96, end: 1).animate(
      CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic),
    );
    _entrance.addStatusListener(_onEntranceStatus);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _reducedMotion = MediaQuery.disableAnimationsOf(context);
      ref.read(authControllerProvider.notifier).ensureBootstrap();
      ref.read(appGateProvider.notifier).fetchConfig(failOpen: true).then((config) {
        if (!mounted || _left) return;
        _gateConfig = config;
        setState(() => _configReady = true);
        _tryHandoff();
      });
      _bootstrapTimeout = Timer(
        AppStartupSplash.splashBootstrapTimeout,
        _onBootstrapTimeout,
      );
      _minDisplayTimer = Timer(
        AppStartupSplash.splashMinDisplayDuration,
        () {
          if (!mounted) return;
          setState(() => _minDisplayElapsed = true);
          _tryHandoff();
        },
      );
      _startEntranceIfNeeded();
    });
  }

  void _onEntranceStatus(AnimationStatus status) {
    if (_left) return;
    if (status == AnimationStatus.completed) {
      _entranceDone = true;
      _tryHandoff();
    }
  }

  void _onBootstrapTimeout() {
    if (_left || !mounted) return;
    final auth = ref.read(authControllerProvider);
    if (!appSplashSessionResolved(auth)) {
      ref
          .read(authControllerProvider.notifier)
          .abandonBootstrapAsUnauthenticated();
    }
    if (!_configReady) {
      _gateConfig = AppConfigData.failOpen();
      _configReady = true;
    }
    _tryHandoff();
  }

  void _startEntranceIfNeeded() {
    if (!mounted || _left) return;
    if (_reducedMotion) {
      _entrance.value = 1;
      _entranceDone = true;
      _tryHandoff();
      return;
    }
    if (_entrance.status == AnimationStatus.dismissed) {
      _entrance.forward();
    }
  }

  void _tryHandoff() {
    if (!mounted || _left) return;
    if (!_entranceDone || !_minDisplayElapsed) return;

    final auth = ref.read(authControllerProvider);
    if (!appSplashSessionResolved(auth)) return;
    if (!_configReady) return;

    _leave(auth);
  }

  void _leave(AuthState auth) {
    if (_left || !mounted) return;
    _left = true;
    _bootstrapTimeout?.cancel();
    _minDisplayTimer?.cancel();
    AppSplashSession.completed = true;
    final destination = appSplashDestinationFor(auth);
    AppGateSession.postSplashDestination = destination;
    final config = _gateConfig ?? ref.read(appGateProvider).valueOrNull ?? AppConfigData.failOpen();
    final route = splashRouteForGate(config, destination);
    AppGateColdStart.splashHandoffDone = true;
    context.go(route);
  }

  @override
  void dispose() {
    _bootstrapTimeout?.cancel();
    _minDisplayTimer?.cancel();
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (_left) return;
      if (appSplashSessionResolved(next)) {
        _tryHandoff();
      }
    });

    final auth = ref.watch(authControllerProvider);
    final waitingOnSession =
        _entranceDone && !appSplashSessionResolved(auth) && !_left;

    return AnimatedBuilder(
      animation: _entrance,
      builder: (context, _) {
        return AppStartupSplash(
          brightness: Theme.of(context).brightness,
          locale: Localizations.localeOf(context),
          logoOpacity: _reducedMotion ? 1 : _logoOpacity.value,
          logoScale: _reducedMotion ? 1 : _logoScale.value,
          showSessionWait: waitingOnSession && !_reducedMotion,
        );
      },
    );
  }
}
