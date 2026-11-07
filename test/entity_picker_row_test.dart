import 'package:bnood/core/config/theme/app_size.dart';
import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/widgets/entity_picker_page.dart';
import 'package:bnood/core/widgets/entity_picker_row.dart';
import 'package:bnood/features/vouchers/voucher_picker_cards.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('picker row tap on title padding returns selected id', (tester) async {
    String? picked;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                picked = await Navigator.of(context).push<String>(
                  MaterialPageRoute(
                    builder: (_) => EntityPickerPage(
                      title: 'Clients',
                      selectedId: 'b',
                      entries: const [('a', 'Alpha'), ('b', 'Beta')],
                      tileBuilder: (ctx, id, selected, onSelect, showDivider) {
                        return VoucherPickerClientCard(
                          name: id == 'a' ? 'Alpha' : 'Beta',
                          clientId: id,
                          remainingPiastres: 0,
                          localeCode: 'en',
                          selected: selected,
                          onTap: onSelect,
                          showDivider: showDivider,
                        );
                      },
                      onCreateRoute: () => const _FakeCreate(),
                    ),
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alpha'));
    await tester.pumpAndSettle();
    expect(picked, 'a');
  });

  testWidgets('selected row shows trailing check', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: VoucherPickerClientCard(
            name: 'Hana',
            clientId: 'c1',
            remainingPiastres: 1200,
            localeCode: 'en',
            selected: true,
            onTap: () {},
            showDivider: false,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.getSemantics(find.text('Hana')).hasFlag(SemanticsFlag.isSelected), isTrue);
    expect(find.byType(SvgPicture), findsOneWidget);
  });

  testWidgets('EN divider start inset aligns with title column', (tester) async {
    const leadingWidth = AppSize.hitMin;
    final expectedInset = EntityPickerOptionRow.dividerStartInset(leadingWidth);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: EntityPickerOptionRow(
            selected: false,
            onSelect: _noop,
            leadingWidth: leadingWidth,
            leading: SizedBox(width: leadingWidth, height: leadingWidth),
            title: 'Client',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final divider = tester.widget<Divider>(find.byType(Divider));
    expect(divider.indent, expectedInset);
    expect(divider.endIndent, 0);

    final titleLeft = tester.getTopLeft(find.text('Client')).dx;
    expect(titleLeft, closeTo(expectedInset, 1.5));

    final dividerBox = tester.getRect(find.byType(Divider));
    expect(dividerBox.right, closeTo(tester.getSize(find.byType(Scaffold)).width, 1.5));
  });

  testWidgets('AR divider uses logical indent with zero end indent', (tester) async {
    const leadingWidth = AppSize.hitMin;
    final expectedInset = EntityPickerOptionRow.dividerStartInset(leadingWidth);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: EntityPickerOptionRow(
            selected: false,
            onSelect: _noop,
            leadingWidth: leadingWidth,
            leading: SizedBox(width: leadingWidth, height: leadingWidth),
            title: 'عميل',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final divider = tester.widget<Divider>(find.byType(Divider));
    expect(divider.indent, expectedInset);
    expect(divider.endIndent, 0);
  });

  testWidgets('full row hit area includes horizontal padding', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: EntityPickerOptionRow(
            selected: false,
            onSelect: () => tapped = true,
            leadingWidth: AppSize.statIconBox,
            leading: const SizedBox(width: AppSize.statIconBox, height: AppSize.statIconBox),
            title: 'Row',
            showDivider: false,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final rowBox = tester.getRect(find.byType(InkWell));
    final leftPad = tester.getTopLeft(find.text('Row')).dx;
    final tapLeft = Offset(leftPad - 8, rowBox.center.dy);
    expect(rowBox.contains(tapLeft), isTrue);
    await tester.tapAt(tapLeft);
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });
}

void _noop() {}

class _FakeCreate extends StatelessWidget {
  const _FakeCreate();
  @override
  Widget build(BuildContext context) => const Scaffold(body: SizedBox());
}
