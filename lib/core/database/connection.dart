import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'database.dart';

LazyDatabase openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'bnood.sqlite'));
    return NativeDatabase(file);
  });
}

/// In-memory database for tests.
AppDatabase openTestDatabase() {
  return AppDatabase(NativeDatabase.memory());
}

/// File-backed test database.
Future<AppDatabase> openTestFileDatabase() async {
  final file = File(p.join(Directory.systemTemp.path,
      'bnood_test_${DateTime.now().microsecondsSinceEpoch}.sqlite'));
  return AppDatabase(NativeDatabase(file));
}
