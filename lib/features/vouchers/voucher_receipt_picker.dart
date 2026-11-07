import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

import '../../l10n/app_localizations.dart';

/// Voucher receipt sources via [image_picker] (camera / system gallery picker only).
class VoucherReceiptPicker {
  VoucherReceiptPicker({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;
  static var _androidPhotoPickerConfigured = false;

  static void configureAndroidPhotoPicker() {
    if (_androidPhotoPickerConfigured) {
      return;
    }
    final impl = ImagePickerPlatform.instance;
    if (impl is ImagePickerAndroid) {
      impl.useAndroidPhotoPicker = true;
    }
    _androidPhotoPickerConfigured = true;
  }

  /// Camera permission is requested by the platform when this runs; user cancel → null.
  Future<XFile?> pickCamera({int imageQuality = 85}) async {
    try {
      return await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: imageQuality,
        requestFullMetadata: false,
      );
    } on PlatformException catch (e) {
      throw VoucherReceiptPickException(e);
    }
  }

  /// Uses the system photo picker / scoped gallery intent; no broad storage permission.
  Future<List<XFile>> pickGallery({int imageQuality = 85}) async {
    configureAndroidPhotoPicker();
    try {
      return await _picker.pickMultiImage(
        imageQuality: imageQuality,
        requestFullMetadata: false,
      );
    } on PlatformException catch (e) {
      throw VoucherReceiptPickException(e);
    }
  }

  /// Android low-memory kill recovery; safe to call once when opening the voucher sheet.
  Future<List<XFile>> recoverLostData() async {
    final response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return const [];
    }
    if (response.exception != null) {
      throw VoucherReceiptPickException(response.exception!);
    }
    return response.files ?? const [];
  }
}

class VoucherReceiptPickException implements Exception {
  VoucherReceiptPickException(this.platform);

  final PlatformException platform;

  @override
  String toString() => 'VoucherReceiptPickException(${platform.code})';
}

String voucherReceiptPickUserMessage(AppLocalizations l10n, VoucherReceiptPickException error) {
  return switch (error.platform.code) {
    'camera_access_denied' => l10n.voucherReceiptCameraDenied,
    'camera_access_restricted' => l10n.voucherReceiptCameraRestricted,
    'photo_access_denied' => l10n.voucherReceiptGalleryDenied,
    'photo_access_restricted' => l10n.voucherReceiptGalleryRestricted,
    _ => l10n.voucherReceiptAttachFailed,
  };
}
