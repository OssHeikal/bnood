import 'package:bnood/features/items/item_semantic_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('known icon keys map to Material icons', () {
    expect(itemSemanticIconData('layers'), Icons.layers_outlined);
    expect(itemSemanticIconData('door_front_door'), Icons.door_front_door_outlined);
  });

  test('unknown icon key falls back', () {
    expect(itemSemanticIconData('not_a_real_key'), Icons.category_outlined);
  });

  test('unknown color key falls back to primary', () {
    expect(itemSemanticAccentColor('unknown'), itemSemanticAccentColor('teal'));
  });
}
