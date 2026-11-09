import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/features/clients/client_movements_filters.dart';
import 'package:bnood/features/clients/widgets/client_movements_filter_bar.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('filter bar shows applied item name and clear-all', (tester) async {
    final controller = TextEditingController();
  addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomeFoundationScope(
          child: Scaffold(
            body: ClientMovementsFilterBar(
              searchController: controller,
              filters: const ClientMovementsFilters(
                itemId: 'i1',
                itemName: 'سباكة',
                sort: ClientMovementsSort.dateAsc,
              ),
              onOpenSort: () {},
              onOpenItem: () {},
              onOpenDate: () {},
              onClearAll: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('سباكة'), findsOneWidget);
    expect(find.text('الأقدم'), findsOneWidget);
    expect(find.text('مسح الفلاتر'), findsOneWidget);
  });
}
