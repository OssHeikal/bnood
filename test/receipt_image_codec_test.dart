import 'package:bnood/features/vouchers/receipt_image_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('decode single path legacy', () {
    expect(ReceiptImageCodec.decode('/a.jpg'), ['/a.jpg']);
  });

  test('encode and decode multiple paths', () {
    const paths = ['/a.jpg', '/b.jpg'];
    final encoded = ReceiptImageCodec.encode(paths);
    expect(encoded, isNotNull);
    expect(ReceiptImageCodec.decode(encoded), paths);
  });

  test('encode empty returns null', () {
    expect(ReceiptImageCodec.encode(const []), isNull);
  });
}
