import 'package:bnood/core/api/auth_api_exception.dart';
import 'package:bnood/features/vouchers/receipt_image_compress.dart';
import 'package:bnood/features/vouchers/voucher_receipt_upload_errors.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('maps 413 and compression errors to localized messages', () {
    final l10n = lookupAppLocalizations(const Locale('en'));
    final sizeMsg = voucherReceiptUploadErrorMessage(
      l10n,
      AuthApiException(statusCode: 413, message: 'Network request failed', code: 'invalid_size'),
    );
    expect(sizeMsg, l10n.voucherReceiptTooLarge);
    expect(
      voucherReceiptUploadErrorMessage(l10n, const ReceiptImageCompressionException()),
      l10n.voucherReceiptCompressFailed,
    );
  });
}
