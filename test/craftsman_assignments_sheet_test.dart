import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/database/connection.dart';
import 'package:bnood/core/providers/app_providers.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/core/widgets/custom_text_field.dart';
import 'package:bnood/core/widgets/sheet_drag_handle.dart';
import 'package:bnood/core/widgets/skeleton/skeleton.dart';
import 'package:bnood/features/clients/craftsman_assignments_sheet.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

late BuildContext _hostContext;

Widget _wrap(Widget child, BnoodRepository repo, {Locale locale = const Locale('en')}) {
  return ProviderScope(
    overrides: [repositoryProvider.overrideWithValue(repo)],
    child: MaterialApp(
      theme: AppFoundationTheme.light(),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: HomeFoundationScope(
        child: Builder(
          builder: (ctx) {
            _hostContext = ctx;
            return Scaffold(body: child);
          },
        ),
      ),
    ),
  );
}

Future<void> _pumpLoaded(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(child);
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (find.byType(Skeleton).evaluate().isEmpty && find.text('Save').evaluate().isNotEmpty) {
      return;
    }
  }
}

Future<void> _openAssignmentsModal(
  WidgetTester tester, {
  required BnoodRepository repo,
  required String projectId,
  required String clientId,
  Locale locale = const Locale('en'),
  Size surface = const Size(390, 844),
}) async {
  await tester.binding.setSurfaceSize(surface);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    _wrap(
      Center(
        child: ElevatedButton(
          onPressed: () =>
              showCraftsmanAssignmentsSheet(context: _hostContext, projectId: projectId, clientId: clientId),
          child: const Text('Open'),
        ),
      ),
      repo,
      locale: locale,
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Open'));
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (find.text('Save').evaluate().isNotEmpty && find.byType(Skeleton).evaluate().isEmpty) {
      break;
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('modal shows one title line and handle in AR', (tester) async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final client = await repo.createClient(name: 'برج');
    final project = (await repo.primaryActiveProject(client.id))!;
    await repo.createCraftsman(name: 'أحمد', phone: '01012345678');

    await _openAssignmentsModal(
      tester,
      repo: repo,
      projectId: project.id,
      clientId: client.id,
      locale: const Locale('ar'),
    );

    expect(find.text('تحديد الصنايعية'), findsOneWidget);
    expect(find.byType(SheetDragHandle), findsOneWidget);
    expect(find.byType(CustomTextField), findsNothing);
  });

  testWidgets('select then set agreed amount updates roster summary draft', (tester) async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final client = await repo.createClient(name: 'Site');
    final project = (await repo.primaryActiveProject(client.id))!;
    await repo.createCraftsman(name: 'Karim', phone: '01000000001');

    await _openAssignmentsModal(tester, repo: repo, projectId: project.id, clientId: client.id);

    await tester.tap(find.text('Karim'));
    await tester.pump();
    expect(find.text('Set amount'), findsOneWidget);

    await tester.tap(find.text('Set amount'));
    await tester.pumpAndSettle();
    expect(find.text('Agreed amount'), findsOneWidget);
    expect(find.text('Assign craftsmen'), findsNothing);

    await tester.enterText(find.byType(CustomTextField), '1000');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Assign craftsmen'), findsOneWidget);
    expect(find.text('Edit amount'), findsOneWidget);
    expect(find.textContaining('1,000 EGP'), findsOneWidget);
    expect(await repo.agreementsForProject(project.id), isEmpty);
  });

  testWidgets('cancel amount sub-sheet keeps roster without summary', (tester) async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final client = await repo.createClient(name: 'Site');
    final project = (await repo.primaryActiveProject(client.id))!;
    await repo.createCraftsman(name: 'Karim', phone: '01000000001');

    await _openAssignmentsModal(tester, repo: repo, projectId: project.id, clientId: client.id);
    await tester.tap(find.text('Karim'));
    await tester.pump();
    await tester.tap(find.text('Set amount'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Set amount'), findsOneWidget);
    expect(find.text('Edit amount'), findsNothing);
  });

  testWidgets('dismiss main roster without save leaves DB unchanged', (tester) async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final client = await repo.createClient(name: 'Site');
    final project = (await repo.primaryActiveProject(client.id))!;

    await _openAssignmentsModal(tester, repo: repo, projectId: project.id, clientId: client.id);
    await tester.tap(find.text('Karim'));
    await tester.pump();
    await tester.tap(find.text('Set amount'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(CustomTextField), '500');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    Navigator.of(_hostContext).pop();
    await tester.pumpAndSettle();

    expect(await repo.agreementsForProject(project.id), isEmpty);
    expect(find.text('Open'), findsOneWidget);
  });

  testWidgets('main save persists link without required amount', (tester) async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final client = await repo.createClient(name: 'Site');
    final project = (await repo.primaryActiveProject(client.id))!;
    await repo.createCraftsman(name: 'Karim', phone: '01000000001');

    await _openAssignmentsModal(
      tester,
      repo: repo,
      projectId: project.id,
      clientId: client.id,
      surface: const Size(390, 820),
    );
    await tester.tap(find.text('Karim'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('craftsman_assignments_save')));
    await tester.pumpAndSettle();

    final agreements = await repo.agreementsForProject(project.id);
    expect(agreements, hasLength(1));
    expect(agreements.single.initialAmountPiastres, isNull);
    expect(find.text('Open'), findsOneWidget);
  });

  testWidgets('draft zero amount persists as explicit zero', (tester) async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final client = await repo.createClient(name: 'Site');
    final project = (await repo.primaryActiveProject(client.id))!;
    await repo.createCraftsman(name: 'Zero', phone: '01000000004');

    await _openAssignmentsModal(tester, repo: repo, projectId: project.id, clientId: client.id);
    await tester.tap(find.text('Zero'));
    await tester.pump();
    await tester.tap(find.text('Set amount'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(CustomTextField), '0');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save').last);
    await tester.tap(find.text('Save').last);
    await tester.pumpAndSettle();

    expect((await repo.agreementsForProject(project.id)).single.initialAmountPiastres, 0);
  });

  testWidgets('assignments sheet shows roster without inline amount fields', (tester) async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final client = await repo.createClient(name: 'Tower Client');
    final project = (await repo.primaryActiveProject(client.id))!;
    await repo.createCraftsman(name: 'Ahmed Plumber', phone: '01012345678', trade: 'Plumbing');

    await _pumpLoaded(
      tester,
      _wrap(
        SizedBox(
          height: 640,
          child: CraftsmanAssignmentsSheet(projectId: project.id, clientId: client.id),
        ),
        repo,
      ),
    );

    expect(find.text('Ahmed Plumber'), findsOneWidget);
    expect(find.byType(CustomTextField), findsNothing);
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('empty directory fallback has single create CTA', (tester) async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final client = await repo.createClient(name: 'Empty');
    final project = (await repo.primaryActiveProject(client.id))!;

    await _pumpLoaded(
      tester,
      _wrap(
        SizedBox(
          height: 640,
          child: CraftsmanAssignmentsSheet(projectId: project.id, clientId: client.id),
        ),
        repo,
      ),
    );

    expect(find.text('No craftsmen yet'), findsOneWidget);
    expect(find.text('Add craftsman to directory'), findsOneWidget);
  });

  test('upsert zero agreed amount is distinct from null', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final client = await repo.createClient(name: 'B');
    final project = (await repo.primaryActiveProject(client.id))!;
    final craftsman = await repo.createCraftsman(name: 'Zero', phone: '01000000004');
    await repo.upsertAgreement(projectId: project.id, craftsmanId: craftsman.id, clearInitial: true);
    expect((await repo.agreementsForProject(project.id)).single.initialAmountPiastres, isNull);
    await repo.upsertAgreement(projectId: project.id, craftsmanId: craftsman.id, initialAmountPiastres: 0);
    expect((await repo.agreementsForProject(project.id)).single.initialAmountPiastres, 0);
  });
}
