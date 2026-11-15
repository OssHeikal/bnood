import 'package:bnood/core/widgets/app_keyboard_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tap outside text field unfocuses', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: AppKeyboardScope(
          child: Scaffold(
            body: Column(
              children: [
                TextField(focusNode: focusNode),
                const Text('outside'),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);

    await tester.tap(find.text('outside'));
    await tester.pump();
    expect(focusNode.hasFocus, isFalse);
  });
}