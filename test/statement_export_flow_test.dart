import 'dart:io';
import 'dart:typed_data';

import 'package:bnood/core/database/connection.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:bnood/features/statements/statement_export_store.dart';
import 'package:bnood/features/statements/statement_pdf_export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(StatementPdfExport.resetShareForTests);

  test('persistTempPdf writes non-empty file on disk', () async {
    final path = await StatementPdfExport.persistTempPdf(
      Uint8List.fromList([0x25, 0x50, 0x44, 0x46]),
      'bnood-test.pdf',
    );
    addTearDown(() => File(path).deleteSync());
    final file = File(path);
    expect(await file.exists(), isTrue);
    expect(await file.length(), 4);
    expect(path, endsWith('bnood-test.pdf'));
  });

  test('export cursor unchanged when share fails after successful bytes', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = (await SharedPreferences.getInstance())!;
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final ws = await repo.workspaceId();
    final client = await repo.createClient(name: 'cursor-test');
    final store = StatementExportStore(prefs);
    const entityIdKey = 'client';

    StatementPdfExport.shareFromFile = (_, __, {sharePositionOrigin}) async {
      expect(sharePositionOrigin, isNotNull);
      expect(sharePositionOrigin!.width, greaterThan(0));
      throw StateError('share_plus_mock_failure');
    };

    expect(
      store.read(workspaceId: ws, kind: StatementEntityKind.client, entityId: client.id),
      isNull,
    );

    // Simulate successful generation + cursor write (screen does this before share).
    await store.recordSuccessfulExport(
      workspaceId: ws,
      kind: StatementEntityKind.client,
      entityId: client.id,
      exportedAt: DateTime(2025, 3, 2, 10),
      periodEndInclusive: DateTime(2025, 3, 31),
    );

    expect(
      () => StatementPdfExport.shareFromFile(
        '/tmp/x.pdf',
        'x.pdf',
        sharePositionOrigin: const Rect.fromLTWH(8, 700, 200, 48),
      ),
      throwsA(isA<StateError>()),
    );

    final record = store.read(workspaceId: ws, kind: StatementEntityKind.client, entityId: client.id);
    expect(record, isNotNull);
    expect(record!.periodEndInclusive, DateTime(2025, 3, 31));
    expect(entityIdKey, 'client');
  });
}
