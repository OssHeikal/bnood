import 'dart:typed_data';

import 'package:image/image.dart' as img;

enum ProfileLogoValidationFailure {
  tooLarge,
  notSquare,
  unreadable,
}

class ProfileLogoValidation {
  const ProfileLogoValidation._();

  static const maxBytes = 2 * 1024 * 1024;

  static ProfileLogoValidationFailure? validateBytes(Uint8List bytes) {
    if (bytes.length > maxBytes) {
      return ProfileLogoValidationFailure.tooLarge;
    }
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return ProfileLogoValidationFailure.unreadable;
    }
    if (decoded.width != decoded.height) {
      return ProfileLogoValidationFailure.notSquare;
    }
    return null;
  }
}
