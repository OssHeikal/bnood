import 'package:bnood/core/widgets/entity_picker_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('entity picker back preserves root form field', (tester) async {
    final rootField = TextEditingController(text: 'draft-amount');
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Column(
              children: [
                TextField(controller: rootField),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EntityPickerPage(
                          title: 'Items',
                          entries: const [('a', 'Alpha')],
                          onCreateRoute: () => const _FakeCreate(),
                        ),
                      ),
                    );
                  },
                  child: const Text('open'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Items'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(rootField.text, 'draft-amount');
  });
}

class _FakeCreate extends StatelessWidget {
  const _FakeCreate();
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar());
}
