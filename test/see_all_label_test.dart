import 'package:bnood/core/formatting/see_all_label.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('seeAllLabelWithCount formats AR label', (tester) async {
    late AppLocalizations l10n;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            l10n = AppLocalizations.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(seeAllLabelWithCount(l10n, 34), 'عرض الكل (34)');
    expect(seeAllLabelWithCount(l10n, 0), l10n.seeAll);
    expect(sectionSeeAllCount(total: 40, visibleLength: 3), 40);
  });
}
