import 'package:bnood/features/statements/statement_export_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('client and supplier export cursors are independent', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = StatementExportStore(prefs);
    const ws = 'w1';
    await store.recordSuccessfulExport(
      workspaceId: ws,
      kind: StatementEntityKind.client,
      entityId: 'c1',
      exportedAt: DateTime(2025, 6, 1, 14, 30),
      periodEndInclusive: DateTime(2025, 6, 30),
    );
    await store.recordSuccessfulExport(
      workspaceId: ws,
      kind: StatementEntityKind.supplier,
      entityId: 's1',
      exportedAt: DateTime(2025, 7, 2),
      periodEndInclusive: DateTime(2025, 7, 2),
    );

    final client = store.read(workspaceId: ws, kind: StatementEntityKind.client, entityId: 'c1');
    final supplier = store.read(workspaceId: ws, kind: StatementEntityKind.supplier, entityId: 's1');
    expect(client, isNotNull);
    expect(supplier, isNotNull);
    expect(client!.periodEndInclusive.day, 30);
    expect(supplier!.periodEndInclusive.day, 2);

    final missing = store.read(workspaceId: ws, kind: StatementEntityKind.client, entityId: 'c2');
    expect(missing, isNull);
  });

  test('record survives prefs round-trip', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = StatementExportStore(prefs);
    await store.recordSuccessfulExport(
      workspaceId: 'w',
      kind: StatementEntityKind.client,
      entityId: 'x',
      exportedAt: DateTime.utc(2025, 3, 5, 10),
      periodEndInclusive: DateTime(2025, 3, 5),
    );
    final r = store.read(workspaceId: 'w', kind: StatementEntityKind.client, entityId: 'x');
    expect(r!.exportedAt.toUtc().hour, 10);
    expect(r.periodEndInclusive.year, 2025);
  });
}
