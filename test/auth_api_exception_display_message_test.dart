import 'package:bnood/core/api/auth_api_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('displayMessage joins up to three distinct field errors', () {
    final error = AuthApiException(
      statusCode: 422,
      message: 'Validation failed',
      fieldErrors: {
        'phone': ['Phone invalid'],
        'name': ['Name invalid', 'Phone invalid'],
      },
    );
    expect(error.displayMessage, 'Phone invalid\nName invalid');
  });

  test('displayMessage falls back to message', () {
    final error = AuthApiException(statusCode: 400, message: 'Bad request');
    expect(error.displayMessage, 'Bad request');
  });
}
