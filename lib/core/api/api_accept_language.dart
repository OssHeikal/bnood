/// Accept-Language for backend copy (`ar` when locale starts with `ar`, else `en`).
String acceptLanguageHeaderForLocale(String languageCode) {
  final code = languageCode.trim().toLowerCase();
  if (code.startsWith('ar')) return 'ar';
  return 'en';
}
