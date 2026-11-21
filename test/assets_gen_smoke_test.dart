import 'package:bnood/core/ui/resources/gen/assets.gen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('icons bundle lists all SVGs', () {
    expect(Assets.icons.values.length, 79);
  });

  test('home outline path matches file name', () {
    expect(Assets.icons.homeOutline.keyName, 'assets/icons/home_outline.svg');
  });

  test('social SVG key names match files', () {
    expect(
      Assets.icons.whatsappColor.keyName,
      'assets/icons/whatsapp_color.svg',
    );
    expect(
      Assets.icons.whatsappMonochrome.keyName,
      'assets/icons/whatsapp_monochrome.svg',
    );
  });
}
