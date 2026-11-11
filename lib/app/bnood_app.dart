import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/settings_provider.dart';
import '../core/session/user_session_lifecycle.dart';
import '../core/theme/app_theme.dart';
import 'app_gate_lifecycle.dart';
import 'router.dart';

final appToastBuilder = BotToastInit();

class BnoodApp extends ConsumerWidget {
  const BnoodApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(userSessionLifecycleProvider);
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    return AppGateLifecycle(
      child: MaterialApp.router(
        builder: appToastBuilder,
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
