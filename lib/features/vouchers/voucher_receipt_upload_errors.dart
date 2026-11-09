import 'package:bnood/l10n/app_localizations.dart';

import '../../core/api/auth_api_exception.dart';
import 'receipt_image_compress.dart';

String voucherReceiptUploadErrorMessage(AppLocalizations l10n, Object? error) {
  if (error is ReceiptImageCompressionException) {
    return l10n.voucherReceiptCompressFailed;
  }
  if (error is AuthApiException) {
    if (error.isInvalidSize || error.statusCode == 413) {
      return l10n.voucherReceiptTooLarge;
    }
    if (error.isInvalidMime) {
      return l10n.voucherReceiptInvalidMime;
    }
    if (!error.isNetwork) {
      return error.message;
    }
  }
  return l10n.voucherReceiptUploadRetry;
}
