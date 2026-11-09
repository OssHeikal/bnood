import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/providers_api/app_provider_record.dart';
import 'package:bnood/features/auth/models/user.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/auth_state.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/features/providers/provider_detail_provider.dart';
import 'package:bnood/features/providers/provider_detail_screen.dart';
import 'package:bnood/features/providers/provider_detail_snapshot.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubProviderDetailNotifier extends ProviderDetailNotifier {
  @override
  Future<ProviderDetailSnapshot> build(String arg) async => loadSnapshot(arg);

  @override
  Future<ProviderDetailSnapshot> loadSnapshot(String providerId) async {
    return ProviderDetailSnapshot(
      provider: AppProvider(
        id: providerId,
        name: 'Ali Craftsman',
        phone: '+201011111111',
        type: AppProviderType.craftsman,
        createdAt: DateTime.utc(2026, 11, 9),
        updatedAt: DateTime.utc(2026, 11, 9),
      ),
      clientAgreements: const [],
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('craftsman provider detail shows linked clients section', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          providerDetailProvider.overrideWith(_StubProviderDetailNotifier.new),
          authControllerProvider.overrideWith(_AuthOk.new),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeFoundationScope(
            child: ProviderDetailScreen(providerId: '01JCRAFT'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ali Craftsman'), findsWidgets);
    expect(find.text('Linked clients'), findsOneWidget);
    expect(find.text('No linked clients yet'), findsOneWidget);
  });
}

class _AuthOk extends AuthController {
  @override
  AuthState build() {
    return const AuthState(
      bootstrapStatus: AuthBootstrapStatus.authenticated,
      user: User(
        id: 'u1',
        phone: '+201000000001',
        name: 'Osama',
      ),
      bootstrapStarted: true,
    );
  }
}
