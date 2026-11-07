import 'dart:async';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';
import '../money/ledger_math.dart';

/// Clients tab list filter (archive flag on [Client], not balance).
enum ClientListArchiveFilter { all, active, archived }

class BnoodRepository {
  BnoodRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  Future<String> workspaceId() => _db.requireWorkspaceId();

  // --- Clients & projects ---

  Future<List<Client>> watchActiveClients() {
    return listClients(ClientListArchiveFilter.active);
  }

  Future<List<Client>> listClients(ClientListArchiveFilter filter) {
    final query = _db.select(_db.clients)..orderBy([(c) => OrderingTerm.asc(c.name)]);
    switch (filter) {
      case ClientListArchiveFilter.active:
        query.where((c) => c.archivedAt.isNull());
      case ClientListArchiveFilter.archived:
        query.where((c) => c.archivedAt.isNotNull());
      case ClientListArchiveFilter.all:
        break;
    }
    return query.get();
  }

  Future<Client> getClient(String clientId) {
    return (_db.select(_db.clients)..where((c) => c.id.equals(clientId))).getSingle();
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

  /// Primary project for detail/list regardless of archive status.
  Future<Project?> primaryProjectForClient(String clientId) async {
    return (_db.select(_db.projects)
          ..where((p) => p.clientId.equals(clientId))
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

  Future<Client> updateClient({
    required String clientId,
    String? name,
    String? phone,
  }) async {
    final now = DateTime.now().toUtc();
    await (_db.update(_db.clients)..where((c) => c.id.equals(clientId))).write(
      ClientsCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        phone: phone != null
            ? Value(phone.isEmpty ? null : phone)
            : const Value.absent(),
        updatedAt: Value(now),
      ),
    );
    return (_db.select(_db.clients)..where((c) => c.id.equals(clientId)))
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

  Future<void> unarchiveClient(String clientId) async {
    final now = DateTime.now().toUtc();
    await (_db.update(_db.clients)..where((c) => c.id.equals(clientId))).write(
      ClientsCompanion(archivedAt: const Value(null), updatedAt: Value(now)),
    );
    await (_db.update(_db.projects)
          ..where((p) => p.clientId.equals(clientId) & p.status.equals('archived')))
        .write(ProjectsCompanion(status: const Value('active'), updatedAt: Value(now)));
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

  Future<Item> updateItem({
    required String id,
    String? name,
    String? colorKey,
    String? iconName,
  }) async {
    final now = DateTime.now().toUtc();
    await (_db.update(_db.items)..where((i) => i.id.equals(id))).write(
      ItemsCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        colorKey: colorKey != null ? Value(colorKey) : const Value.absent(),
        iconName: iconName != null ? Value(iconName) : const Value.absent(),
        updatedAt: Value(now),
      ),
    );
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

  Future<void> archiveSupplier(String id) async {
    final now = DateTime.now().toUtc();
    await (_db.update(_db.suppliers)..where((s) => s.id.equals(id))).write(
        SuppliersCompanion(archivedAt: Value(now), updatedAt: Value(now)));
  }

  Stream<List<CraftsmenData>> watchActiveCraftsmen() {
    return (_db.select(_db.craftsmen)
          ..where((c) => c.archivedAt.isNull())
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .watch();
  }

  Future<List<CraftsmenData>> listActiveCraftsmen() {
    return (_db.select(_db.craftsmen)
          ..where((c) => c.archivedAt.isNull())
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .get();
  }

  Future<CraftsmenData> createCraftsman({
    required String name,
    String? phone,
    String? trade,
    String? notes,
  }) async {
    final storedPhone = phone?.trim() ?? '';
    final ws = await workspaceId();
    final now = DateTime.now().toUtc();
    final id = _uuid.v4();
    await _db.into(_db.craftsmen).insert(CraftsmenCompanion.insert(
          id: id,
          workspaceId: ws,
          name: name,
          phone: storedPhone,
          trade: Value(trade),
          notes: Value(notes),
          createdAt: now,
          updatedAt: now,
        ));
    return (_db.select(_db.craftsmen)..where((c) => c.id.equals(id)))
        .getSingle();
  }

  Future<void> archiveCraftsman(String id) async {
    final now = DateTime.now().toUtc();
    await (_db.update(_db.craftsmen)..where((c) => c.id.equals(id))).write(
        CraftsmenCompanion(archivedAt: Value(now), updatedAt: Value(now)));
  }

  Future<Item?> getItem(String id) =>
      (_db.select(_db.items)..where((i) => i.id.equals(id))).getSingleOrNull();

  // --- Agreements ---

  Future<List<ProjectCraftsmanAgreement>> agreementsForProject(
      String projectId) {
    return (_db.select(_db.projectCraftsmanAgreements)
          ..where((a) => a.projectId.equals(projectId)))
        .get();
  }

  Stream<void> watchProjectCraftsmenSignals(String projectId) {
    StreamSubscription<List<Transaction>>? txSub;
    StreamSubscription<List<ProjectCraftsmanAgreement>>? agSub;
    var closed = false;

    void emit(StreamController<void> controller) {
      if (!closed && !controller.isClosed) controller.add(null);
    }

    void stop() {
      closed = true;
      txSub?.cancel();
      agSub?.cancel();
      txSub = null;
      agSub = null;
    }

    return Stream.multi((controller) {
      closed = false;
      txSub = watchProjectTransactions(projectId).listen((_) => emit(controller));
      agSub = (_db.select(_db.projectCraftsmanAgreements)
            ..where((a) => a.projectId.equals(projectId)))
          .watch()
          .listen((_) => emit(controller));
      emit(controller);
      controller.onCancel = stop;
    });
  }

  Future<List<ProjectCraftsmanAgreement>> agreementsForCraftsman(String craftsmanId) {
    return (_db.select(_db.projectCraftsmanAgreements)
          ..where((a) => a.craftsmanId.equals(craftsmanId)))
        .get();
  }

  Future<List<Transaction>> craftsmanLaborTransactions(String craftsmanId) async {
    return (_db.select(_db.transactions)
          ..where((t) =>
              t.craftsmanId.equals(craftsmanId) &
              t.kind.equals('spend') &
              t.expenseType.equals('labor'))
          ..orderBy([
            (t) => OrderingTerm.desc(t.date),
            (t) => OrderingTerm.desc(t.createdAt),
          ]))
        .get();
  }

  Stream<void> watchCraftsmanDetailSignals(String craftsmanId) {
    StreamSubscription<List<Transaction>>? txSub;
    StreamSubscription<List<ProjectCraftsmanAgreement>>? agSub;
    var closed = false;

    void emit(StreamController<void> controller) {
      if (!closed && !controller.isClosed) controller.add(null);
    }

    void stop() {
      closed = true;
      txSub?.cancel();
      agSub?.cancel();
      txSub = null;
      agSub = null;
    }

    return Stream.multi((controller) {
      closed = false;
      txSub = (_db.select(_db.transactions)
            ..where((t) => t.craftsmanId.equals(craftsmanId)))
          .watch()
          .listen((_) => emit(controller));
      agSub = (_db.select(_db.projectCraftsmanAgreements)
            ..where((a) => a.craftsmanId.equals(craftsmanId)))
          .watch()
          .listen((_) => emit(controller));
      emit(controller);
      controller.onCancel = stop;
    });
  }

  Future<void> removeCraftsmanFromProject({
    required String projectId,
    required String craftsmanId,
  }) async {
    await (_db.delete(_db.projectCraftsmanAgreements)
          ..where((a) =>
              a.projectId.equals(projectId) & a.craftsmanId.equals(craftsmanId)))
        .go();
  }

  Future<Project?> projectById(String projectId) async {
    return (_db.select(_db.projects)..where((p) => p.id.equals(projectId)))
        .getSingleOrNull();
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

  Future<List<HomeSupplierSpendRow>> homeSupplierSpendsForActiveClients() async {
    final activeClients = await watchActiveClients();
    if (activeClients.isEmpty) return const [];
    final clientIds = activeClients.map((c) => c.id).toList();
    final projects = await (_db.select(_db.projects)
          ..where((p) => p.status.equals('active') & p.clientId.isIn(clientIds)))
        .get();
    final projectIds = projects.map((p) => p.id).toList();
    if (projectIds.isEmpty) return const [];

    final spends = await (_db.select(_db.transactions)
          ..where(
            (t) => t.kind.equals('spend') & t.supplierId.isNotNull() & t.projectId.isIn(projectIds),
          ))
        .get();

    final totalsBySupplier = <String, int>{};
    for (final row in spends) {
      final supplierId = row.supplierId;
      if (supplierId == null) continue;
      totalsBySupplier[supplierId] = (totalsBySupplier[supplierId] ?? 0) + row.amountPiastres;
    }
    if (totalsBySupplier.isEmpty) return const [];

    final suppliers = await (_db.select(_db.suppliers)
          ..where((s) => s.id.isIn(totalsBySupplier.keys.toList())))
        .get();

    return [
      for (final s in suppliers)
        HomeSupplierSpendRow(supplier: s, spentPiastres: totalsBySupplier[s.id] ?? 0),
    ]..sort((a, b) => b.spentPiastres.compareTo(a.spentPiastres));
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
          ..where((t) => t.supplierId.equals(supplierId) & t.kind.equals('spend'))
          ..orderBy([
            (t) => OrderingTerm.desc(t.date),
            (t) => OrderingTerm.desc(t.createdAt),
          ]))
        .get();
  }

  Stream<List<Transaction>> watchSupplierSpendTransactions(String supplierId) {
    StreamSubscription<List<Transaction>>? txSub;
    var closed = false;

    Future<void> publish(StreamController<List<Transaction>> controller) async {
      if (closed) return;
      try {
        final rows = await supplierTransactions(supplierId);
        if (!closed && !controller.isClosed) controller.add(rows);
      } catch (e, st) {
        if (!closed && !controller.isClosed) controller.addError(e, st);
      }
    }

    void stop() {
      closed = true;
      txSub?.cancel();
      txSub = null;
    }

    return Stream.multi((controller) {
      closed = false;
      txSub = (_db.select(_db.transactions)
            ..where((t) => t.supplierId.equals(supplierId)))
          .watch()
          .listen((_) => publish(controller));
      publish(controller);
      controller.onCancel = stop;
    });
  }

  Future<Map<String, ({String clientId, String clientName})>> clientInfoForProjectIds(
    Iterable<String> projectIds,
  ) async {
    final ids = projectIds.toSet();
    if (ids.isEmpty) return const {};
    final projects = await (_db.select(_db.projects)..where((p) => p.id.isIn(ids.toList()))).get();
    final clientIds = projects.map((p) => p.clientId).toSet();
    if (clientIds.isEmpty) return const {};
    final clients = await (_db.select(_db.clients)..where((c) => c.id.isIn(clientIds.toList()))).get();
    final clientById = {for (final c in clients) c.id: c.name};
    return {
      for (final p in projects)
        p.id: (
          clientId: p.clientId,
          clientName: clientById[p.clientId] ?? '—',
        ),
    };
  }

  Future<List<CraftsmenData>> craftsmenAssignedToProject(
      String projectId) async {
    final agreements = await agreementsForProject(projectId);
    if (agreements.isEmpty) return [];
    final ids = agreements.map((a) => a.craftsmanId).toSet();
    final all = await watchActiveCraftsmen().first;
    return all.where((c) => ids.contains(c.id)).toList();
  }

  Future<StatementPeriodTotals> supplierPeriodTotalsAsync({
    required String supplierId,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    final rows = await supplierTransactions(supplierId);
    final spendOnly = rows.where((t) => t.kind == 'spend').toList();
    return LedgerMath.periodTotals(
      projectRows: spendOnly,
      periodStart: periodStart,
      periodEnd: periodEnd,
    );
  }

  Future<List<Project>> allProjects() {
    return (_db.select(_db.projects)
          ..orderBy([(p) => OrderingTerm.asc(p.name)]))
        .get();
  }

  Future<Supplier?> getSupplier(String id) async {
    return (_db.select(_db.suppliers)..where((s) => s.id.equals(id)))
        .getSingleOrNull();
  }

  Future<CraftsmenData?> getCraftsman(String id) async {
    return (_db.select(_db.craftsmen)..where((c) => c.id.equals(id)))
        .getSingleOrNull();
  }

  Future<Map<String, int>> supplierPaidTotalsAllProjects() async {
    final t = _db.transactions;
    final query = _db.selectOnly(t)
      ..addColumns([t.supplierId, t.amountPiastres.sum()])
      ..where(t.supplierId.isNotNull() & t.kind.equals('spend'))
      ..groupBy([t.supplierId]);
    final rows = await query.get();
    final out = <String, int>{};
    for (final row in rows) {
      final id = row.read(t.supplierId);
      if (id == null) continue;
      out[id] = row.read(t.amountPiastres.sum()) ?? 0;
    }
    return out;
  }

  Future<Map<String, int>> craftsmanLaborPaidTotals() async {
    final t = _db.transactions;
    final query = _db.selectOnly(t)
      ..addColumns([t.craftsmanId, t.amountPiastres.sum()])
      ..where(
        t.craftsmanId.isNotNull() &
            t.kind.equals('spend') &
            t.expenseType.equals('labor'),
      )
      ..groupBy([t.craftsmanId]);
    final rows = await query.get();
    final out = <String, int>{};
    for (final row in rows) {
      final id = row.read(t.craftsmanId);
      if (id == null) continue;
      out[id] = row.read(t.amountPiastres.sum()) ?? 0;
    }
    return out;
  }

  Future<Map<String, int>> craftsmanAgreementCounts() async {
    final a = _db.projectCraftsmanAgreements;
    final query = _db.selectOnly(a)
      ..addColumns([a.craftsmanId, a.id.count()])
      ..groupBy([a.craftsmanId]);
    final rows = await query.get();
    final out = <String, int>{};
    for (final row in rows) {
      final id = row.read(a.craftsmanId);
      if (id == null) continue;
      out[id] = row.read(a.id.count()) ?? 0;
    }
    return out;
  }

  Stream<List<DirectorySupplierRow>> watchDirectorySupplierRows() {
    StreamSubscription<List<Supplier>>? suppliersSub;
    StreamSubscription<List<Transaction>>? txSub;
    var closed = false;

    Future<void> publish(StreamController<List<DirectorySupplierRow>> controller) async {
      if (closed) return;
      try {
        final suppliers = await (_db.select(_db.suppliers)
              ..where((s) => s.archivedAt.isNull())
              ..orderBy([(s) => OrderingTerm.asc(s.name)]))
            .get();
        final totals = await supplierPaidTotalsAllProjects();
        final rows = suppliers
            .map(
              (s) => DirectorySupplierRow(
                supplier: s,
                paidPiastres: totals[s.id] ?? 0,
              ),
            )
            .toList();
        if (!closed && !controller.isClosed) controller.add(rows);
      } catch (e, st) {
        if (!closed && !controller.isClosed) controller.addError(e, st);
      }
    }

    void stop() {
      closed = true;
      suppliersSub?.cancel();
      txSub?.cancel();
      suppliersSub = null;
      txSub = null;
    }

    return Stream.multi((controller) {
      closed = false;
      suppliersSub = watchActiveSuppliers().listen((_) => publish(controller));
      txSub = (_db.select(_db.transactions)
            ..where((t) => t.supplierId.isNotNull()))
          .watch()
          .listen((_) => publish(controller));
      publish(controller);
      controller.onCancel = stop;
    });
  }

  Stream<List<DirectoryCraftsmanRow>> watchDirectoryCraftsmanRows() {
    StreamSubscription<List<CraftsmenData>>? rosterSub;
    StreamSubscription<List<Transaction>>? txSub;
    StreamSubscription<List<ProjectCraftsmanAgreement>>? agreementSub;
    var closed = false;

    Future<void> publish(StreamController<List<DirectoryCraftsmanRow>> controller) async {
      if (closed) return;
      try {
        final craftsmen = await (_db.select(_db.craftsmen)
              ..where((c) => c.archivedAt.isNull())
              ..orderBy([(c) => OrderingTerm.asc(c.name)]))
            .get();
        final paid = await craftsmanLaborPaidTotals();
        final counts = await craftsmanAgreementCounts();
        final rows = craftsmen
            .map(
              (c) => DirectoryCraftsmanRow(
                craftsman: c,
                paidPiastres: paid[c.id] ?? 0,
                projectCount: counts[c.id] ?? 0,
              ),
            )
            .toList();
        if (!closed && !controller.isClosed) controller.add(rows);
      } catch (e, st) {
        if (!closed && !controller.isClosed) controller.addError(e, st);
      }
    }

    void stop() {
      closed = true;
      rosterSub?.cancel();
      txSub?.cancel();
      agreementSub?.cancel();
      rosterSub = null;
      txSub = null;
      agreementSub = null;
    }

    return Stream.multi((controller) {
      closed = false;
      rosterSub = watchActiveCraftsmen().listen((_) => publish(controller));
      txSub = (_db.select(_db.transactions)
            ..where((t) => t.craftsmanId.isNotNull()))
          .watch()
          .listen((_) => publish(controller));
      agreementSub =
          (_db.select(_db.projectCraftsmanAgreements)).watch().listen((_) => publish(controller));
      publish(controller);
      controller.onCancel = stop;
    });
  }
}

class HomeTotals {
  const HomeTotals(
      {required this.receivedPiastres, required this.spentPiastres});
  final int receivedPiastres;
  final int spentPiastres;
  int get remainingPiastres => receivedPiastres - spentPiastres;
}

class HomeSupplierSpendRow {
  const HomeSupplierSpendRow({required this.supplier, required this.spentPiastres});
  final Supplier supplier;
  final int spentPiastres;
}

class HomeClientBalanceRow {
  const HomeClientBalanceRow({
    required this.client,
    required this.remainingPiastres,
    required this.receivedPiastres,
    required this.spentPiastres,
  });

  final Client client;
  final int remainingPiastres;
  final int receivedPiastres;
  final int spentPiastres;
}

class DirectorySupplierRow {
  const DirectorySupplierRow({
    required this.supplier,
    required this.paidPiastres,
  });

  final Supplier supplier;
  final int paidPiastres;
}

class DirectoryCraftsmanRow {
  const DirectoryCraftsmanRow({
    required this.craftsman,
    required this.paidPiastres,
    required this.projectCount,
  });

  final CraftsmenData craftsman;
  final int paidPiastres;
  final int projectCount;
}
