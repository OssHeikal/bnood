import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/database/database.dart';
import 'package:bnood/core/widgets/custom_text_field.dart';
import 'package:bnood/core/widgets/entity_picker_row.dart';
import 'package:bnood/features/clients/widgets/craftsman_roster_choice_row.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('roster row full padding tap toggles selection in EN', (tester) async {
    var selected = false;
    final craftsman = CraftsmenData(
      id: 'c1',
      workspaceId: 'w',
      name: 'Hassan',
      phone: '01000000000',
      trade: 'Electric',
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => CraftsmanRosterChoiceRow(
              craftsman: craftsman,
              selected: selected,
              selectionLocked: false,
              onToggle: () => setState(() => selected = !selected),
              showDivider: true,
              onManageAmount: selected ? () {} : null,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final box = tester.getRect(find.text('Hassan'));
    await tester.tapAt(box.centerLeft + const Offset(4, 0));
    await tester.pump();
    expect(selected, isTrue);
    expect(find.text('Set amount'), findsOneWidget);
    expect(find.byType(CustomTextField), findsNothing);
  });

  testWidgets('remote scale shows one million EGP not ten million', (tester) async {
    final craftsman = CraftsmenData(
      id: 'c-remote',
      workspaceId: 'w',
      name: 'Samir',
      phone: '01000000002',
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: CraftsmanRosterChoiceRow(
            craftsman: craftsman,
            selected: true,
            selectionLocked: false,
            onToggle: () {},
            showDivider: false,
            showAmountSummary: true,
            agreedPiastres: 1000000 * 1000,
            localeCode: 'en',
            minorPerMajor: 1000,
            onManageAmount: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.textContaining('1,000,000 EGP'), findsOneWidget);
    expect(find.textContaining('10,000,000 EGP'), findsNothing);
  });

  testWidgets('selected row shows summary and edit CTA', (tester) async {
    final craftsman = CraftsmenData(
      id: 'c2',
      workspaceId: 'w',
      name: 'Karim',
      phone: '01000000001',
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );

    var opened = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: CraftsmanRosterChoiceRow(
            craftsman: craftsman,
            selected: true,
            selectionLocked: false,
            onToggle: () {},
            showDivider: false,
            showAmountSummary: true,
            agreedPiastres: 1500_00,
            localeCode: 'en',
            onManageAmount: () => opened++,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.textContaining('1,500 EGP'), findsOneWidget);
    expect(find.text('Edit amount'), findsOneWidget);
    expect(find.bySemanticsLabel('Selected'), findsNothing);

    final amount = tester.getRect(find.textContaining('1,500 EGP'));
    final link = tester.getRect(find.text('Edit amount'));
    final name = tester.getRect(find.text('Karim'));
    expect(link.top, greaterThan(amount.top));
    expect((link.right - amount.right).abs(), lessThan(8));
    expect(link.left, greaterThan(name.left));

    await tester.tap(find.textContaining('1,500 EGP'));
    await tester.tap(find.text('Edit amount'));
    expect(opened, 2);
  });

  testWidgets('AR amount stack shares the trailing edge', (tester) async {
    final craftsman = CraftsmenData(
      id: 'c4',
      workspaceId: 'w',
      name: 'أحمد',
      phone: '01000000001',
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: CraftsmanRosterChoiceRow(
            craftsman: craftsman,
            selected: true,
            selectionLocked: false,
            onToggle: () {},
            showDivider: false,
            showAmountSummary: true,
            agreedPiastres: 5000_00,
            localeCode: 'ar',
            onManageAmount: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    final amount = tester.getRect(find.textContaining('5,000 EGP'));
    final link = tester.getRect(find.text('تعديل المبلغ'));
    final name = tester.getRect(find.text('أحمد'));
    expect(link.top, greaterThan(amount.top));
    expect((link.left - amount.left).abs(), lessThan(8));
    expect(link.right, lessThan(name.right));
    expect(find.bySemanticsLabel('Selected'), findsNothing);
  });

  testWidgets('divider inset mirrors logical start in AR', (tester) async {
    final craftsman = CraftsmenData(
      id: 'c3',
      workspaceId: 'w',
      name: 'علي',
      phone: '01000000001',
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: CraftsmanRosterChoiceRow(
            craftsman: craftsman,
            selected: false,
            selectionLocked: false,
            onToggle: () {},
            showDivider: true,
          ),
        ),
      ),
    );
    await tester.pump();

    final divider = tester.widget<Divider>(find.byType(Divider));
    expect(divider.indent, EntityPickerOptionRow.dividerStartInset(36));
    expect(divider.endIndent, 0);
  });
}
