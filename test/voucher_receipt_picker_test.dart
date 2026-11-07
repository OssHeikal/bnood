import 'package:bnood/features/vouchers/voucher_receipt_picker.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('maps platform denial codes to localized messages', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    expect(
      voucherReceiptPickUserMessage(
        l10n,
        VoucherReceiptPickException(PlatformException(code: 'camera_access_denied')),
      ),
      l10n.voucherReceiptCameraDenied,
    );
    expect(
      voucherReceiptPickUserMessage(
        l10n,
        VoucherReceiptPickException(PlatformException(code: 'photo_access_denied')),
      ),
      l10n.voucherReceiptGalleryDenied,
    );
  });

  test('Arabic ARB permission strings use Western digits when applicable', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    expect(l10n.voucherReceiptAttachFailed, isNotEmpty);
    expect(l10n.voucherReceiptCameraDenied, isNotEmpty);
  });
}
