import 'package:bnood/core/agreements/agreement_amount_api.dart';
import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/money/remote_money_units.dart';
import 'package:bnood/core/providers_api/providers_riverpod.dart';
import 'package:bnood/features/clients/craftsman_agreement_amount_sheet.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('agreementAmountMajorFromMinor converts remote minor to API major', () {
    expect(
      agreementAmountMajorFromMinor(RemoteMoneyUnits.majorToMinor(1000000)),
      1000000,
    );
    expect(agreementAmountMajorFromMinor(null), isNull);
  });

  testWidgets('remote amount sheet prefills major units not minor', (tester) async {
    const minor = 1000000 * RemoteMoneyUnits.minorPerMajor;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          remoteProvidersEnabledProvider.overrideWith((ref) => true),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeFoundationScope(
            child: Scaffold(
              body: CraftsmanAgreementAmountPage(
                entry: CraftsmanAgreementAmountEntry.rosterDraft,
                projectId: 'p1',
                craftsmanName: 'Karim',
                clientName: 'Client',
                initialAmountPiastres: minor,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1000000'), findsOneWidget);
    expect(find.text('10000000'), findsNothing);
  });

  testWidgets('local amount sheet still divides piastres by 100', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          remoteProvidersEnabledProvider.overrideWith((ref) => false),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeFoundationScope(
            child: Scaffold(
              body: CraftsmanAgreementAmountPage(
                entry: CraftsmanAgreementAmountEntry.rosterDraft,
                projectId: 'p1',
                craftsmanName: 'Karim',
                clientName: 'Client',
                initialAmountPiastres: 1500_00,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('1500'), findsOneWidget);
  });
}
