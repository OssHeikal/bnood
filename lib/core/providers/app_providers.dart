import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/connection.dart';
import '../database/database.dart';
import '../repositories/bnood_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.production();
  ref.onDispose(db.close);
  return db;
});

final databaseProviderForTest = Provider.family<AppDatabase, void>((ref, _) {
  final db = openTestDatabase();
  ref.onDispose(db.close);
  return db;
});

final repositoryProvider = Provider<BnoodRepository>((ref) {
  return BnoodRepository(ref.watch(databaseProvider));
});

final repositoryProviderForTest =
    Provider.family<BnoodRepository, AppDatabase>((ref, db) {
  return BnoodRepository(db);
});
