import 'package:bnood/features/items/item_semantic_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('known catalog keys resolve to assets', () {
    expect(itemSemanticIconAsset('layers'), isNotNull);
    expect(itemSemanticIconAsset('door'), isNotNull);
  });

  test('legacy icon keys map to catalog keys', () {
    expect(resolveItemIconKey('door_front_door'), 'door');
    expect(resolveItemIconKey('category'), 'grid_table');
    expect(resolveItemIconKey('plumbing'), 'sink');
  });

  test('unknown icon key falls back to tools asset', () {
    expect(resolveItemIconKey('not_a_real_key'), 'tools');
    expect(itemSemanticIconAsset('not_a_real_key'), isNotNull);
  });

  test('unknown color key falls back to primary', () {
    expect(itemSemanticAccentColor('unknown'), itemSemanticAccentColor('teal'));
  });

  testWidgets('itemSemanticIconWidget builds for catalog key', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: _IconHarness(),
      ),
    );
    expect(find.byType(FlutterLogo), findsNothing);
  });
}

class _IconHarness extends StatelessWidget {
  const _IconHarness();

  @override
  Widget build(BuildContext context) {
    return itemSemanticIconWidget(
      iconKey: 'layers',
      color: const Color(0xFF1EAAB2),
    );
  }
}
