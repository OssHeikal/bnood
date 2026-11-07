import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/database/database.dart';
import 'package:bnood/features/suppliers/craftsman_detail_provider.dart';
import 'package:bnood/features/suppliers/craftsman_detail_screen.dart';
import 'package:bnood/features/suppliers/craftsman_detail_snapshot.dart';
import 'package:bnood/features/suppliers/supplier_detail_provider.dart';
import 'package:bnood/features/suppliers/supplier_detail_screen.dart';
import 'package:bnood/features/suppliers/supplier_detail_snapshot.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('supplier detail shows name once in EN', (tester) async {
    final now = DateTime.utc(2026, 11, 1);
    final snap = SupplierDetailSnapshot(
      supplier: Supplier(
        id: 's1',
        workspaceId: 'w',
        name: 'Steel Co',
        phone: '01012345678',
        createdAt: now,
        updatedAt: now,
      ),
      totalPaidPiastres: 0,
      history: const [],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [supplierDetailProvider.overrideWith(() => _StubSupplierNotifier(snap))],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SupplierDetailScreen(supplierId: 's1'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Steel Co'), findsOneWidget);
    expect(find.textContaining('01012345678'), findsOneWidget);
    expect(find.text('Materials supplier'), findsNothing);
  });

  testWidgets('craftsman detail shows name once in AR', (tester) async {
    final now = DateTime.utc(2026, 11, 1);
    final snap = CraftsmanDetailSnapshot(
      craftsman: CraftsmenData(
        id: 'c1',
        workspaceId: 'w',
        name: 'أحمد',
        phone: '01011112222',
        createdAt: now,
        updatedAt: now,
      ),
      totalLaborPaidPiastres: 0,
      linkedProjectCount: 0,
      jobs: const [],
      history: const [],
    );

    await tester.binding.setSurfaceSize(const Size(360, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [craftsmanDetailProvider.overrideWith(() => _StubCraftsmanNotifier(snap))],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const CraftsmanDetailScreen(craftsmanId: 'c1'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('أحمد'), findsOneWidget);
    expect(find.textContaining('01011112222'), findsOneWidget);
    expect(find.text('صنايعي'), findsNothing);
  });
}

class _StubSupplierNotifier extends SupplierDetailNotifier {
  _StubSupplierNotifier(this.value);
  final SupplierDetailSnapshot value;
  @override
  Future<SupplierDetailSnapshot> build(String arg) async => value;
}

class _StubCraftsmanNotifier extends CraftsmanDetailNotifier {
  _StubCraftsmanNotifier(this.value);
  final CraftsmanDetailSnapshot value;
  @override
  Future<CraftsmanDetailSnapshot> build(String arg) async => value;
}
