import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/config/navigation/root_navigator_key.dart';
import '../core/config/theme/app_theme.dart';
import 'ui_foundation_preview_screen.dart';

class UiFoundationPreviewApp extends StatelessWidget {
  const UiFoundationPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      debugShowCheckedModeBanner: true,
      theme: AppFoundationTheme.light(),
      darkTheme: AppFoundationTheme.dark(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar'), Locale('en')],
      home: const UiFoundationPreviewScreen(),
    );
  }
}
