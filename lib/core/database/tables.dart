import 'package:drift/drift.dart';

class Workspaces extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Clients extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  DateTimeColumn get archivedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Projects extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId => text()();
  TextColumn get clientId => text()();
  TextColumn get name => text()();
  TextColumn get unitAddress => text().nullable()();
  TextColumn get status => text()();
  IntColumn get engineerBasisPoints => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Items extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId => text()();
  TextColumn get name => text()();
  TextColumn get colorKey => text()();
  TextColumn get iconName => text()();
  DateTimeColumn get archivedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Suppliers extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get archivedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Craftsmen extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId => text()();
  TextColumn get name => text()();
  TextColumn get phone => text()();
  TextColumn get trade => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get archivedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class ProjectCraftsmanAgreements extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId => text()();
  TextColumn get projectId => text()();
  TextColumn get craftsmanId => text()();
  IntColumn get initialAmountPiastres => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId => text()();
  TextColumn get projectId => text()();
  TextColumn get kind => text()();
  IntColumn get amountPiastres => integer()();
  DateTimeColumn get date => dateTime()();
  TextColumn get method => text()();
  TextColumn get description => text().nullable()();
  TextColumn get receiptImagePath => text().nullable()();
  TextColumn get itemId => text().nullable()();
  TextColumn get expenseType => text().nullable()();
  TextColumn get supplierId => text().nullable()();
  TextColumn get craftsmanId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
