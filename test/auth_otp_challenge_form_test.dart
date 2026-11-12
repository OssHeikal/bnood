import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/features/auth/widgets/auth_otp_challenge_form.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppFoundationTheme.light(),
    locale: const Locale('en'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('full pin submits once and resend clears the cells', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final pin = PinInputController();
    addTearDown(pin.dispose);
    final formKey = GlobalKey<FormState>();
    var verifies = 0;
    var resends = 0;

    await tester.pumpWidget(
      _wrap(
        AuthOtpChallengeForm(
          formKey: formKey,
          pinController: pin,
          phone: '01000000000',
          autovalidateMode: AutovalidateMode.disabled,
          loading: false,
          verifyLabel: 'Verify',
          onVerify: () => verifies++,
          onResend: () => resends++,
        ),
      ),
    );

    await tester.enterText(find.byType(EditableText), '12345');
    await tester.pump();
    expect(verifies, 0);

    await tester.enterText(find.byType(EditableText), '123456');
    await tester.pump();
    expect(verifies, 1);
    expect(pin.text, '123456');

    await tester.tap(find.text('Resend code'));
    await tester.pump();
    expect(resends, 1);
    expect(pin.text, isEmpty);
    expect(find.text('1'), findsNothing);
  });
}
