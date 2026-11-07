import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../seed/default_items.dart';
import 'connection.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  Workspaces,
  Clients,
  Projects,
  Items,
  Suppliers,
  Craftsmen,
  ProjectCraftsmanAgreements,
  Transactions,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  factory AppDatabase.production() => AppDatabase(openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedWorkspace(this);
        },
      );

  static Future<void> _seedWorkspace(AppDatabase db) async {
    const uuid = Uuid();
    final now = DateTime.now().toUtc();
    final workspaceId = uuid.v4();
    await db.into(db.workspaces).insert(
          WorkspacesCompanion.insert(
            id: workspaceId,
            createdAt: now,
            updatedAt: now,
          ),
        );
    for (final seed in defaultItemSeeds) {
      await db.into(db.items).insert(
            ItemsCompanion.insert(
              id: uuid.v4(),
              workspaceId: workspaceId,
              name: seed.arabicName,
              colorKey: seed.colorKey,
              iconName: seed.iconName,
              createdAt: now,
              updatedAt: now,
            ),
          );
    }
  }

  Future<String> requireWorkspaceId() async {
    final row = await (select(workspaces)..limit(1)).getSingleOrNull();
    if (row == null) {
      throw StateError('Workspace missing');
    }
    return row.id;
  }
}
