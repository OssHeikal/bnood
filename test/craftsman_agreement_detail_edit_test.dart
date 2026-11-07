import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/database/connection.dart';
import 'package:bnood/core/providers/app_providers.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:bnood/features/clients/craftsman_agreement_amount_sheet.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/features/suppliers/craftsman_detail_provider.dart';
import 'package:bnood/features/suppliers/craftsman_detail_snapshot.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bnood/core/widgets/custom_text_field.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('detail edit sheet saves amount without showing roster picker', (tester) async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final client = await repo.createClient(name: 'Client A');
    final project = (await repo.primaryActiveProject(client.id))!;
    final craftsman = await repo.createCraftsman(name: 'Ali', phone: '01000000009');
    await repo.upsertAgreement(
      projectId: project.id,
      craftsmanId: craftsman.id,
      clearInitial: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          repositoryProvider.overrideWithValue(repo),
          craftsmanDetailProvider.overrideWith(_QuietCraftsmanDetailNotifier.new),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomeFoundationScope(
            child: Consumer(
              builder: (context, ref, _) {
                return Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () => showCraftsmanProjectAgreementEditSheet(
                        context: context,
                        ref: ref,
                        projectId: project.id,
                        craftsmanId: craftsman.id,
                        clientId: client.id,
                        clientName: client.name,
                        craftsmanName: craftsman.name,
                        initialAmountPiastres: null,
                      ),
                      child: const Text('Open edit'),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open edit'));
    await tester.pumpAndSettle();

    expect(find.text('Assign craftsmen'), findsNothing);
    expect(find.text('Edit agreement'), findsOneWidget);

    await tester.enterText(find.byType(CustomTextField), '750');
    await tester.tap(find.text('Save'));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (find.text('Open edit').evaluate().isNotEmpty) break;
    }

    final agreements = await repo.agreementsForProject(project.id);
    expect(agreements.single.initialAmountPiastres, 750_00);
    expect(find.text('Open edit'), findsOneWidget);
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
