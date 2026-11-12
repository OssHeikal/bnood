import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../vouchers/voucher_receipt_picker.dart';

enum ProfileLogoPickSource { camera, gallery }

/// Profile logo from camera or single gallery image (same stack as voucher receipts).
class ProfileLogoPicker {
  ProfileLogoPicker({VoucherReceiptPicker? receiptPicker})
      : _receiptPicker = receiptPicker ?? VoucherReceiptPicker();

  final VoucherReceiptPicker _receiptPicker;

  Future<XFile?> pick(ProfileLogoPickSource source) async {
    VoucherReceiptPicker.configureAndroidPhotoPicker();
    try {
      return switch (source) {
        ProfileLogoPickSource.camera => _receiptPicker.pickCamera(imageQuality: 90),
        ProfileLogoPickSource.gallery => _singleFromGallery(),
      };
    } on VoucherReceiptPickException {
      rethrow;
    } on PlatformException {
      rethrow;
    }
  }

  Future<XFile?> _singleFromGallery() async {
    final files = await _receiptPicker.pickGallery(imageQuality: 90);
    if (files.isEmpty) return null;
    return files.first;
  }
}
