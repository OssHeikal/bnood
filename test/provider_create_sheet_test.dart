import 'package:bnood/core/config/theme/app_colors.dart';
import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/features/providers/provider_create_sheet.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('provider create sheet uses directory tabs and contact import', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeFoundationScope(
            child: Scaffold(body: ProviderCreateSheet()),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(SegmentedButton<dynamic>), findsNothing);
    expect(find.text('اختيار من جهات الاتصال'), findsOneWidget);
    expect(find.byKey(const Key('provider_type_supplier')), findsOneWidget);
    expect(find.byKey(const Key('provider_type_craftsman')), findsOneWidget);

    final supplier = tester.widget<Material>(find.byKey(const Key('provider_type_supplier')));
    final craftsman = tester.widget<Material>(find.byKey(const Key('provider_type_craftsman')));
    expect(supplier.color, AppColors.light.primary);
    expect(craftsman.color, AppColors.light.surface);

    await tester.tap(find.byKey(const Key('provider_type_craftsman')));
    await tester.pump();

    expect(
      tester.widget<Material>(find.byKey(const Key('provider_type_craftsman'))).color,
      AppColors.light.primary,
    );
    expect(
      tester.widget<Material>(find.byKey(const Key('provider_type_supplier'))).color,
      AppColors.light.surface,
    );
  });
}
