import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/contacts/contact_import_action.dart';
import 'package:bnood/core/contacts/device_contact_import.dart';
import 'package:bnood/core/widgets/buttons/pressable_scale.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/features/vouchers/inline_create_routes.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() => DeviceContactPicker.pickOverride = null);

  testWidgets('add client sheet shows contact import action', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HomeFoundationScope(child: InlineCreateClientPage()),
      ),
    );
    await tester.pump();
    expect(find.text('اختيار من جهات الاتصال'), findsOneWidget);
  });

  Future<void> pumpContactAction(WidgetTester tester, Locale locale) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.dark(),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomeFoundationScope(
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: ContactImportAction(
                nameController: TextEditingController(),
                phoneController: TextEditingController(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Rect buttonRect(WidgetTester tester) {
    final button = find.ancestor(of: find.byIcon(Icons.contacts_outlined), matching: find.byType(PressableScale));
    return tester.getRect(button);
  }

  testWidgets('AR contact import icon leads at start (right), label before icon', (tester) async {
    await pumpContactAction(tester, const Locale('ar'));
    final button = buttonRect(tester);
    final icon = tester.getRect(find.byIcon(Icons.contacts_outlined));
    final label = tester.getRect(find.text('اختيار من جهات الاتصال'));
    expect(icon.left, greaterThan(label.left));
    expect(button.right - icon.right, lessThan(56));
    expect(icon.right, lessThanOrEqualTo(button.right));
    expect(label.right, lessThanOrEqualTo(icon.left + 8));
  });

  testWidgets('EN contact import icon leads at start (left), label after icon', (tester) async {
    await pumpContactAction(tester, const Locale('en'));
    final button = buttonRect(tester);
    final icon = tester.getRect(find.byIcon(Icons.contacts_outlined));
    final label = tester.getRect(find.text('Choose from contacts'));
    expect(icon.left, lessThan(label.left));
    expect(icon.left - button.left, lessThan(56));
    expect(icon.right + 4, lessThanOrEqualTo(label.left));
  });

  testWidgets('contact import fills client form without save', (tester) async {
    DeviceContactPicker.pickOverride = () async =>
        Contact(fullName: 'أسامة', selectedPhoneNumber: '01012345678', phoneNumbers: const ['01012345678']);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HomeFoundationScope(child: InlineCreateClientPage()),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('اختيار من جهات الاتصال'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('أسامة'), findsOneWidget);
    expect(find.textContaining('01012345678'), findsWidgets);
  });
}
