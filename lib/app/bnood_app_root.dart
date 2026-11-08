import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/settings_provider.dart';
import 'bnood_app.dart';
import 'bnood_splash_session.dart';
import 'bnood_startup_splash.dart';

/// One cold-start overlay above [BnoodApp]; router and init stay underneath.
class BnoodAppRoot extends ConsumerStatefulWidget {
  const BnoodAppRoot({super.key});

  @override
  ConsumerState<BnoodAppRoot> createState() => _BnoodAppRootState();
}

class _BnoodAppRootState extends ConsumerState<BnoodAppRoot> with SingleTickerProviderStateMixin {
  AnimationController? _fade;
  Animation<double>? _fadeOpacity;
  var _appReady = false;
  var _fadeInDone = false;
  var _showOverlay = false;
  var _fadingOut = false;

  @override
  void initState() {
    super.initState();
    _showOverlay = !BnoodSplashSession.completed;
    if (_showOverlay) {
      _fade = AnimationController(
        vsync: this,
        duration: BnoodStartupSplash.splashFadeInDuration,
      );
      _fadeOpacity = CurvedAnimation(
        parent: _fade!,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      );
      _fade!.addListener(() {
        if (mounted) setState(() {});
      });
      _fade!.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _fadeInDone = true;
          _tryHandoff();
        } else if (status == AnimationStatus.dismissed && _fadingOut) {
          _completeSplash();
        }
      });
    }
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _appReady = true);
      _startFadeInIfNeeded();
      _tryHandoff();
    });
  }

  void _startFadeInIfNeeded() {
    if (!_showOverlay || _fade == null || !mounted) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _fade!.value = 1;
      _fadeInDone = true;
      return;
    }
    if (_fade!.status == AnimationStatus.dismissed) {
      _fade!.forward();
    }
  }

  void _tryHandoff() {
    if (!_showOverlay || !mounted || _fadingOut) return;
    if (!_appReady || !_fadeInDone) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _completeSplash();
      return;
    }
    _fadingOut = true;
    _fade!.duration = BnoodStartupSplash.splashFadeOutDuration;
    _fade!.reverse();
  }

  void _completeSplash() {
    BnoodSplashSession.completed = true;
    _fade?.dispose();
    _fade = null;
    _fadeOpacity = null;
    setState(() {
      _showOverlay = false;
      _fadingOut = false;
    });
  }

  Brightness _brightness(BuildContext context) {
    final mode = ref.watch(themeModeProvider);
    return switch (mode) {
      ThemeMode.dark => Brightness.dark,
      ThemeMode.light => Brightness.light,
      ThemeMode.system => MediaQuery.platformBrightnessOf(context),
    };
  }

  @override
  void dispose() {
    _fade?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final opacity = _fadeOpacity?.value ?? (_showOverlay ? 1.0 : 0.0);
    final textDirection =
        locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr;
    return Directionality(
      textDirection: textDirection,
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          const BnoodApp(),
          if (_showOverlay)
            Positioned.fill(
              child: BnoodStartupSplash(
                brightness: _brightness(context),
                locale: locale,
                opacity: opacity,
              ),
            ),
        ],
      ),
    );
  }
}
