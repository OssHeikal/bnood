import 'package:bnood/core/config/theme/app_size.dart';
import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/widgets/app_amount.dart';
import 'package:bnood/core/widgets/app_card.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/features/statements/statement_summary_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('stat row equal height keeps compact label-to-amount gap', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    const short = 'مقبوض';
    const long =
        'المتبقي بنهاية الفترة بعنوان طويل جداً يلتف على أكثر من سطر واحد في الواجهة الضيقة';

    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.dark(),
        home: HomeFoundationScope(
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(AppSize.spaceMD),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: StatementSummaryStatCard(
                        label: short,
                        piastres: 0,
                        preset: AppCardPreset.statReceive,
                        role: AppAmountRole.receive,
                        localeCode: 'ar',
                      ),
                    ),
                    const SizedBox(width: AppSize.spaceSM),
                    Expanded(
                      child: StatementSummaryStatCard(
                        label: short,
                        piastres: 0,
                        preset: AppCardPreset.statSpend,
                        role: AppAmountRole.spend,
                        localeCode: 'ar',
                      ),
                    ),
                    const SizedBox(width: AppSize.spaceSM),
                    Expanded(
                      child: StatementSummaryStatCard(
                        label: long,
                        piastres: 0,
                        preset: AppCardPreset.statRemaining,
                        role: AppAmountRole.remaining,
                        localeCode: 'ar',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final gapFinder = find.byWidgetPredicate(
      (w) => w is SizedBox && w.height == statementSummaryLabelAmountGap,
    );
    expect(gapFinder, findsNWidgets(3));

    final shortLabelBox = tester.getRect(find.text(short).first);
    final shortAmountBox = tester.getRect(
      find.descendant(
        of: find.ancestor(of: find.text(short).first, matching: find.byType(AppCard)),
        matching: find.byType(AppAmount),
      ),
    );
    final gapPx = shortAmountBox.top - shortLabelBox.bottom;
    expect(gapPx, closeTo(statementSummaryLabelAmountGap, 2));

    final shortCardBox = tester.getRect(
      find.ancestor(of: find.text(short).first, matching: find.byType(AppCard)),
    );
    final tallestCardBox = tester.getRect(find.byType(AppCard).last);
    expect(shortCardBox.height, tallestCardBox.height);
    expect(shortCardBox.height, lessThan(120));
    expect(tester.takeException(), isNull);
  });
}
