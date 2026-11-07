import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/database/connection.dart';
import 'package:bnood/core/providers/app_providers.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:bnood/features/suppliers/directory_providers.dart';
import 'package:bnood/features/suppliers/directory_screen.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpDirectory(
    WidgetTester tester, {
    required List<Override> overrides,
    required Locale locale,
    int initialTabIndex = 0,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: DirectoryScreen(initialTabIndex: initialTabIndex),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('directory suppliers tab shows paid EGP in Arabic', (tester) async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final supplier = await repo.createSupplier(name: 'شركة النور للدهانات الطويلة جدًا');

    await pumpDirectory(
      tester,
      locale: const Locale('ar'),
      overrides: [
        repositoryProvider.overrideWithValue(repo),
        directorySuppliersProvider.overrideWith(
          (ref) => Stream.value([
            DirectorySupplierRow(supplier: supplier, paidPiastres: 123456),
          ]),
        ),
        directoryCraftsmenProvider.overrideWith((ref) => Stream.value(const [])),
      ],
    );
    expect(tester.takeException(), isNull);
    expect(find.text('شركة النور للدهانات الطويلة جدًا'), findsOneWidget);
    expect(find.text('Materials supplier'), findsNothing);
    expect(find.textContaining('EGP'), findsWidgets);
    expect(find.textContaining('1,234.56'), findsWidgets);
    expect(find.textContaining('٠'), findsNothing);
  });

  testWidgets('directory craftsmen empty shows CTA', (tester) async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);

    await pumpDirectory(
      tester,
      locale: const Locale('en'),
      initialTabIndex: 1,
      overrides: [
        repositoryProvider.overrideWithValue(repo),
        directorySuppliersProvider.overrideWith((ref) => Stream.value(const [])),
        directoryCraftsmenProvider.overrideWith((ref) => Stream.value(const [])),
      ],
    );

    expect(find.text('No craftsmen yet'), findsOneWidget);
    expect(find.text('Add craftsman'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('directory supplier hint visible in English', (tester) async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);

    await pumpDirectory(
      tester,
      locale: const Locale('en'),
      overrides: [
        repositoryProvider.overrideWithValue(repo),
        directorySuppliersProvider.overrideWith((ref) => Stream.value(const [])),
        directoryCraftsmenProvider.overrideWith((ref) => Stream.value(const [])),
      ],
    );
    expect(
      find.text('Material suppliers · recorded payments only, no payables or credit balances.'),
      findsOneWidget,
    );
  });
}
