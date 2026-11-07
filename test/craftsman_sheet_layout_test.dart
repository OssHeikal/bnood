import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/database/connection.dart';
import 'package:bnood/core/providers/app_providers.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:bnood/core/widgets/bounded_sheet_navigator.dart';
import 'package:bnood/core/widgets/custom_text_field.dart';
import 'package:bnood/core/widgets/sheet_drag_handle.dart';
import 'package:bnood/features/clients/craftsman_agreement_amount_sheet.dart';
import 'package:bnood/features/clients/craftsman_assignments_sheet.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/features/suppliers/craftsman_detail_provider.dart';
import 'package:bnood/features/suppliers/craftsman_detail_snapshot.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _tallPhone = Size(390, 844);

double _sheetSurfaceHeight(WidgetTester tester) {
  final handle = find.descendant(
    of: find.byType(BottomSheet),
    matching: find.byType(SheetDragHandle),
  );
  final material = find.ancestor(of: handle, matching: find.byType(Material));
  return tester.getSize(material.first).height;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('agreement edit opener hugs content with handle near top', (tester) async {
    await tester.binding.setSurfaceSize(_tallPhone);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final client = await repo.createClient(name: 'Osama');
    final project = (await repo.primaryActiveProject(client.id))!;
    final craftsman = await repo.createCraftsman(name: 'Ahmed Plumber', phone: '01011112222');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          repositoryProvider.overrideWithValue(repo),
          craftsmanDetailProvider.overrideWith(_QuietCraftsmanDetailNotifier.new),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomeFoundationScope(
            child: Consumer(
              builder: (context, ref, _) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => showCraftsmanProjectAgreementEditSheet(
                    context: context,
                    ref: ref,
                    projectId: project.id,
                    craftsmanId: craftsman.id,
                    clientId: client.id,
                    clientName: client.name,
                    craftsmanName: craftsman.name,
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final handleY = tester.getTopLeft(find.byType(SheetDragHandle)).dy;
    expect(handleY, lessThan(140));
    expect(_sheetSurfaceHeight(tester), lessThan(SheetContentBounds.viewportCap(MediaQueryData(size: _tallPhone)).round() + 1));
    expect(_sheetSurfaceHeight(tester), lessThan(420));

    await tester.showKeyboard(find.byType(CustomTextField));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('roster modal save links two craftsmen without amounts on tall phone',
      (tester) async {
    await tester.binding.setSurfaceSize(_tallPhone);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final client = await repo.createClient(name: 'Osama');
    final project = (await repo.primaryActiveProject(client.id))!;
    await repo.createCraftsman(name: 'Ahmed Plumber', phone: '01011112222');
    await repo.createCraftsman(name: 'Mahmoud Carpenter', phone: '01033334444');

    late BuildContext host;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [repositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomeFoundationScope(
            child: Builder(
              builder: (ctx) {
                host = ctx;
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () => showCraftsmanAssignmentsSheet(
                      context: host,
                      projectId: project.id,
                      clientId: client.id,
                    ),
                    child: const Text('Open'),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open'));
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (find.byKey(const Key('craftsman_assignments_save')).evaluate().isNotEmpty) break;
    }

    await tester.tap(find.text('Ahmed Plumber'));
    await tester.pump();
    await tester.tap(find.text('Mahmoud Carpenter'));
    await tester.pump();

    await tester.ensureVisible(find.byKey(const Key('craftsman_assignments_save')));
    await tester.tap(find.byKey(const Key('craftsman_assignments_save')));
    await tester.pumpAndSettle();

    final agreements = await repo.agreementsForProject(project.id);
    expect(agreements, hasLength(2));
    expect(agreements.every((a) => a.initialAmountPiastres == null), isTrue);
    expect(find.text('Open'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _QuietCraftsmanDetailNotifier extends CraftsmanDetailNotifier {
  @override
  Future<CraftsmanDetailSnapshot> build(String craftsmanId) async {
    final craftsman = (await ref.read(repositoryProvider).getCraftsman(craftsmanId))!;
    return CraftsmanDetailSnapshot(
      craftsman: craftsman,
      totalLaborPaidPiastres: 0,
      linkedProjectCount: 0,
      jobs: const [],
      history: const [],
    );
  }

  @override
  Future<void> refreshSilently() async {}
}
