import 'package:flutter/material.dart';

/// Accept-Language for backend copy (`ar` when locale starts with `ar`, else `en`).
String acceptLanguageHeaderForLocale(String languageCode) {
  final code = languageCode.trim().toLowerCase();
  if (code.startsWith('ar')) return 'ar';
  return 'en';
}

/// Updated from [localeProvider] in [BnoodApp]; read on each Dio request.
abstract final class ApiAcceptLanguage {
  static Locale Function() _readLocale = () => const Locale('ar');

  static void bindLocaleReader(Locale Function() readLocale) {
    _readLocale = readLocale;
  }

  static void syncLocale(Locale locale) {
    _readLocale = () => locale;
  }

  static String headerValue() => acceptLanguageHeaderForLocale(_readLocale().languageCode);
}
