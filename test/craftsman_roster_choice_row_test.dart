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
    expect(find.text('Set agreed amount'), findsOneWidget);
    expect(find.byType(CustomTextField), findsNothing);
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
            onManageAmount: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.textContaining('1,500 EGP'), findsOneWidget);
    expect(find.text('Edit agreed amount'), findsOneWidget);
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
