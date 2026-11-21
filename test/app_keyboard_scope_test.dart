import 'package:bnood/core/ui/widgets/app_keyboard_scope.dart';
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
            body: SizedBox(
              width: 400,
              height: 400,
              child: Column(
                children: [
                  TextField(focusNode: focusNode),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);

    await tester.tapAt(const Offset(200, 350));
    await tester.pump();
    expect(focusNode.hasFocus, isFalse);
  });
}
