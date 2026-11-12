import 'package:bnood/core/clients/client_statement_record.dart';
import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/features/statements/statement_issuer_header.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('StatementIssuerHeader shows name and phone LTR', (tester) async {
    const issuer = StatementIssuer(
      name: 'Statement Owner',
      contactPhone: '+201033334444',
      logoUrl: null,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppFoundationTheme.light(),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: StatementIssuerHeader(issuer: issuer)),
      ),
    );

    expect(find.text('Statement Owner'), findsOneWidget);
    expect(find.textContaining('201033334444'), findsOneWidget);
  });
}
