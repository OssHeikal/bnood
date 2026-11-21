import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../core/ui/layout/app_breakpoints.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/analytics/providers/analytics_providers.dart';
import '../core/network/api/api_accept_language.dart';
import '../core/services/error_reporting/error_reporting_lifecycle.dart';
import '../core/app_state/settings_provider.dart';
import '../core/network/push/push_coordinator.dart';
import '../core/network/session/user_session_lifecycle.dart';
import '../core/ui/theme/app_theme.dart';
import '../core/ui/widgets/app_keyboard_scope.dart';
import 'app_gate_lifecycle.dart';
import 'router.dart';

final appToastBuilder = BotToastInit();

class BnoodApp extends ConsumerWidget {
  const BnoodApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(userSessionLifecycleProvider);
    ref.watch(errorReportingLifecycleProvider);
    ref.watch(pushLifecycleProvider);
    ref.watch(analyticsLifecycleProvider);
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    ApiAcceptLanguage.syncLocale(locale);
    return AppGateLifecycle(
      child: MaterialApp.router(
        builder: (context, child) {
          final responsive = ResponsiveBreakpoints.builder(
            breakpoints: AppBreakpoints.all,
            child: child ?? const SizedBox.shrink(),
          );
          return AppKeyboardScope(child: appToastBuilder(context, responsive));
        },
        onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appTitle,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: themeMode,
        locale: locale,
        debugShowCheckedModeBanner: false,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: router,
      ),
    );
  }
}
