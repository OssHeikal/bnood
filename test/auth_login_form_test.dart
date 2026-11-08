import 'package:bnood/features/auth/auth_form_utils.dart';
import 'package:bnood/features/auth/login_screen.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bnood/core/theme/app_theme.dart';

Widget _wrap(Widget child, Locale locale) {
  return ProviderScope(
    child: HomeFoundationScope(
      child: MaterialApp(
        theme: AppTheme.light(),
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    ),
  );
}

void main() {
  testWidgets('login retains phone after validation error (AR)', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_wrap(const LoginScreen(), const Locale('ar')));
    await tester.enterText(find.byType(EditableText).first, '01012345678');
    await tester.tap(find.text('تسجيل الدخول'));
    await tester.pump();
    expect(find.textContaining('01012345678'), findsWidgets);
  });

  testWidgets('login retains phone after validation error (EN)', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_wrap(const LoginScreen(), const Locale('en')));
    await tester.enterText(find.byType(EditableText).first, '01012345678');
    await tester.tap(find.text('Sign in'));
    await tester.pump();
    expect(find.textContaining('01012345678'), findsWidgets);
  });

  test('verification code accepts four-digit development length', () {
    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(validateVerificationCode(l10n, '1111'), isNull);
    expect(validateVerificationCode(l10n, '12'), isNotNull);
    expect(validateVerificationCode(l10n, '123456789'), isNotNull);
  });
}
