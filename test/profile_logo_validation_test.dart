import 'dart:typed_data';

import 'package:bnood/features/auth/profile_logo_validation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test('rejects image larger than 2MB', () {
    final bytes = Uint8List(ProfileLogoValidation.maxBytes + 1);
    expect(ProfileLogoValidation.validateBytes(bytes), ProfileLogoValidationFailure.tooLarge);
  });

  test('rejects non-square image', () {
    final png = img.encodePng(img.Image(width: 100, height: 50));
    expect(ProfileLogoValidation.validateBytes(Uint8List.fromList(png)), ProfileLogoValidationFailure.notSquare);
  });

  test('accepts square image within size limit', () {
    final png = img.encodePng(img.Image(width: 64, height: 64));
    expect(ProfileLogoValidation.validateBytes(Uint8List.fromList(png)), isNull);
  });
}
