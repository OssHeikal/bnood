import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';
import '../money/ledger_math.dart';

class BnoodRepository {
  BnoodRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  Future<String> workspaceId() => _db.requireWorkspaceId();

  // --- Clients & projects ---

  Future<List<Client>> watchActiveClients() {
    return (_db.select(_db.clients)
          ..where((c) => c.archivedAt.isNull())
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .get();
  }

  Future<Client> createClient({required String name, String? phone}) async {
    final ws = await workspaceId();
    final now = DateTime.now().toUtc();
    final clientId = _uuid.v4();
    final projectId = _uuid.v4();
    await _db.into(_db.clients).insert(
          ClientsCompanion.insert(
            id: clientId,
            workspaceId: ws,
            name: name,
            phone: Value(phone),
            createdAt: now,
            updatedAt: now,
          ),
        );
    await _db.into(_db.projects).insert(
          ProjectsCompanion.insert(
            id: projectId,
            workspaceId: ws,
            clientId: clientId,
            name: name,
            status: 'active',
            createdAt: now,
            updatedAt: now,
          ),
        );
    return (await (_db.select(_db.clients)..where((c) => c.id.equals(clientId)))
        .getSingle());
  }

  Future<Project?> primaryActiveProject(String clientId) async {
    return (_db.select(_db.projects)
          ..where(
              (p) => p.clientId.equals(clientId) & p.status.equals('active'))
          ..orderBy([(p) => OrderingTerm.asc(p.createdAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<Project> updateProject({
    required String projectId,
    String? name,
    String? unitAddress,
    int? engineerBasisPoints,
    bool clearEngineerRate = false,
  }) async {
    final now = DateTime.now().toUtc();
    await (_db.update(_db.projects)..where((p) => p.id.equals(projectId)))
        .write(
      ProjectsCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        unitAddress:
            unitAddress != null ? Value(unitAddress) : const Value.absent(),
        engineerBasisPoints: clearEngineerRate
            ? const Value(null)
            : engineerBasisPoints != null
                ? Value(engineerBasisPoints)
                : const Value.absent(),
        updatedAt: Value(now),
      ),
    );
    return (_db.select(_db.projects)..where((p) => p.id.equals(projectId)))
        .getSingle();
  }

  Future<void> archiveClient(String clientId) async {
    final now = DateTime.now().toUtc();
    await (_db.update(_db.clients)..where((c) => c.id.equals(clientId)))
        .write(ClientsCompanion(archivedAt: Value(now), updatedAt: Value(now)));
    await (_db.update(_db.projects)..where((p) => p.clientId.equals(clientId)))
        .write(ProjectsCompanion(
            status: const Value('archived'), updatedAt: Value(now)));
  }

  // --- Catalogs ---

  Stream<List<Item>> watchActiveItems() {
    return (_db.select(_db.items)
          ..where((i) => i.archivedAt.isNull())
          ..orderBy([(i) => OrderingTerm.asc(i.name)]))
        .watch();
  }

  Future<Item> createItem({
    required String name,
    required String colorKey,
    required String iconName,
  }) async {
    final ws = await workspaceId();
    final now = DateTime.now().toUtc();
    final id = _uuid.v4();
    await _db.into(_db.items).insert(ItemsCompanion.insert(
          id: id,
          workspaceId: ws,
          name: name,
          colorKey: colorKey,
          iconName: iconName,
          createdAt: now,
          updatedAt: now,
        ));
    return (_db.select(_db.items)..where((i) => i.id.equals(id))).getSingle();
  }

  Future<void> archiveItem(String id) async {
    final now = DateTime.now().toUtc();
    await (_db.update(_db.items)..where((i) => i.id.equals(id)))
        .write(ItemsCompanion(archivedAt: Value(now), updatedAt: Value(now)));
  }

  Stream<List<Supplier>> watchActiveSuppliers() {
    return (_db.select(_db.suppliers)
          ..where((s) => s.archivedAt.isNull())
          ..orderBy([(s) => OrderingTerm.asc(s.name)]))
        .watch();
  }

  Future<Supplier> createSupplier(
      {required String name, String? phone, String? notes}) async {
    final ws = await workspaceId();
    final now = DateTime.now().toUtc();
    final id = _uuid.v4();
    await _db.into(_db.suppliers).insert(SuppliersCompanion.insert(
          id: id,
          workspaceId: ws,
          name: name,
          phone: Value(phone),
          notes: Value(notes),
          createdAt: now,
          updatedAt: now,
        ));
    return (_db.select(_db.suppliers)..where((s) => s.id.equals(id)))
        .getSingle();
  }

  Stream<List<CraftsmenData>> watchActiveCraftsmen() {
    return (_db.select(_db.craftsmen)
          ..where((c) => c.archivedAt.isNull())
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .watch();
  }

  Future<CraftsmenData> createCraftsman({
    required String name,
    required String phone,
    String? trade,
    String? notes,
  }) async {
    final ws = await workspaceId();
    final now = DateTime.now().toUtc();
    final id = _uuid.v4();
    await _db.into(_db.craftsmen).insert(CraftsmenCompanion.insert(
          id: id,
          workspaceId: ws,
          name: name,
          phone: phone,
          trade: Value(trade),
          notes: Value(notes),
          createdAt: now,
          updatedAt: now,
        ));
    return (_db.select(_db.craftsmen)..where((c) => c.id.equals(id)))
        .getSingle();
  }

  // --- Agreements ---

  Future<List<ProjectCraftsmanAgreement>> agreementsForProject(
      String projectId) {
    return (_db.select(_db.projectCraftsmanAgreements)
          ..where((a) => a.projectId.equals(projectId)))
        .get();
  }

  Future<ProjectCraftsmanAgreement> upsertAgreement({
    required String projectId,
    required String craftsmanId,
    int? initialAmountPiastres,
    bool clearInitial = false,
  }) async {
    final ws = await workspaceId();
    final now = DateTime.now().toUtc();
    final existing = await (_db.select(_db.projectCraftsmanAgreements)
          ..where((a) =>
              a.projectId.equals(projectId) &
              a.craftsmanId.equals(craftsmanId)))
        .getSingleOrNull();
    if (existing == null) {
      final id = _uuid.v4();
      await _db
          .into(_db.projectCraftsmanAgreements)
          .insert(ProjectCraftsmanAgreementsCompanion.insert(
            id: id,
            workspaceId: ws,
            projectId: projectId,
            craftsmanId: craftsmanId,
            initialAmountPiastres:
                clearInitial ? const Value(null) : Value(initialAmountPiastres),
            createdAt: now,
            updatedAt: now,
          ));
      return (_db.select(_db.projectCraftsmanAgreements)
            ..where((a) => a.id.equals(id)))
          .getSingle();
    }
    await (_db.update(_db.projectCraftsmanAgreements)
          ..where((a) => a.id.equals(existing.id)))
        .write(
      ProjectCraftsmanAgreementsCompanion(
        initialAmountPiastres:
            clearInitial ? const Value(null) : Value(initialAmountPiastres),
        updatedAt: Value(now),
      ),
    );
    return (_db.select(_db.projectCraftsmanAgreements)
          ..where((a) => a.id.equals(existing.id)))
        .getSingle();
  }

  // --- Transactions ---

  Stream<List<Transaction>> watchProjectTransactions(String projectId) {
    return (_db.select(_db.transactions)
          ..where((t) => t.projectId.equals(projectId))
          ..orderBy([
            (t) => OrderingTerm.desc(t.date),
            (t) => OrderingTerm.desc(t.createdAt)
          ]))
        .watch();
  }

  Future<List<Transaction>> transactionsForProject(String projectId) {
    return (_db.select(_db.transactions)
          ..where((t) => t.projectId.equals(projectId)))
        .get();
  }

  Future<Transaction> insertTransaction({
    required String projectId,
    required String kind,
    required int amountPiastres,
    required DateTime date,
    required String method,
    String? description,
    String? receiptImagePath,
    String? itemId,
    String? expenseType,
    String? supplierId,
    String? craftsmanId,
  }) async {
    final ws = await workspaceId();
    final now = DateTime.now().toUtc();
    final id = _uuid.v4();
    await _db.into(_db.transactions).insert(TransactionsCompanion.insert(
          id: id,
          workspaceId: ws,
          projectId: projectId,
          kind: kind,
          amountPiastres: amountPiastres,
          date: date,
          method: method,
          description: Value(description),
          receiptImagePath: Value(receiptImagePath),
          itemId: Value(itemId),
          expenseType: Value(expenseType),
          supplierId: Value(supplierId),
          craftsmanId: Value(craftsmanId),
          createdAt: now,
          updatedAt: now,
        ));
    return (_db.select(_db.transactions)..where((t) => t.id.equals(id)))
        .getSingle();
  }

  Future<void> updateTransaction(
      String id, TransactionsCompanion companion) async {
    await (_db.update(_db.transactions)..where((t) => t.id.equals(id)))
        .write(companion.copyWith(updatedAt: Value(DateTime.now().toUtc())));
  }

  Future<void> deleteTransaction(String id) async {
    await (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
  }

  Future<Transaction?> getTransaction(String id) async {
    return (_db.select(_db.transactions)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  // --- Aggregates ---

  Future<ProjectBalance> projectBalance(String projectId) async {
    final rows = await transactionsForProject(projectId);
    return LedgerMath.projectBalance(rows);
  }

  Future<HomeTotals> homeTotals() async {
    final activeProjects = await (_db.select(_db.projects)
          ..where((p) => p.status.equals('active')))
        .get();
    var received = 0;
    var spent = 0;
    for (final p in activeProjects) {
      final b = await projectBalance(p.id);
      received += b.receivedPiastres;
      spent += b.spentPiastres;
    }
    return HomeTotals(receivedPiastres: received, spentPiastres: spent);
  }

  Future<List<Transaction>> supplierTransactions(String supplierId) async {
    return (_db.select(_db.transactions)
          ..where((t) => t.supplierId.equals(supplierId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<List<Project>> allProjects() {
    return (_db.select(_db.projects)
          ..orderBy([(p) => OrderingTerm.asc(p.name)]))
        .get();
  }

  Future<Client?> getClient(String id) async {
    return (_db.select(_db.clients)..where((c) => c.id.equals(id)))
        .getSingleOrNull();
  }

  Future<Supplier?> getSupplier(String id) async {
    return (_db.select(_db.suppliers)..where((s) => s.id.equals(id)))
        .getSingleOrNull();
  }

  Future<CraftsmenData?> getCraftsman(String id) async {
    return (_db.select(_db.craftsmen)..where((c) => c.id.equals(id)))
        .getSingleOrNull();
  }
}

class HomeTotals {
  const HomeTotals(
      {required this.receivedPiastres, required this.spentPiastres});
  final int receivedPiastres;
  final int spentPiastres;
  int get remainingPiastres => receivedPiastres - spentPiastres;
}
