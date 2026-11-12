import 'package:bnood/core/api/api_error_user_message.dart';
import 'package:bnood/core/api/auth_api_exception.dart';
import 'package:bnood/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = AppLocalizationsEn();

  test('maps network and session errors to instructive copy', () {
    expect(
      apiAuthErrorUserMessage(l10n, AuthApiException(statusCode: 0, message: 'x', code: 'network')),
      l10n.apiErrorNetwork,
    );
    expect(
      apiAuthErrorUserMessage(
        l10n,
        AuthApiException(statusCode: 401, message: 'x', code: 'unauthorized'),
      ),
      l10n.apiErrorSessionExpired,
    );
  });

  test('prefers field validation messages', () {
    final error = AuthApiException(
      statusCode: 422,
      message: 'Validation failed',
      fieldErrors: {
        'phone': ['The phone number is not a valid Egyptian mobile number.'],
      },
    );
    expect(apiAuthErrorUserMessage(l10n, error), error.displayMessage);
  });

  test('generic object uses fallback', () {
    expect(apiErrorUserMessage(l10n, Exception('boom')), l10n.apiGenericFailure);
  });
}
