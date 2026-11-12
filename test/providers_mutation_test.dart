import 'package:bnood/core/api/auth_api_exception.dart';
import 'package:bnood/features/providers/provider_mutation_actions.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('duplicateProviderNameFieldError maps 422 duplicate_name', (tester) async {
    late AppLocalizations l10n;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Builder(
          builder: (context) {
            l10n = AppLocalizations.of(context);
            return const SizedBox();
          },
        ),
      ),
    );
    final error = AuthApiException(statusCode: 422, message: 'dup', code: 'duplicate_name');
    expect(duplicateProviderNameFieldError(l10n, error), l10n.providerDuplicateNameError);
  });
}
