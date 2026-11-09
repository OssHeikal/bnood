import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/providers_api/app_provider_record.dart';
import 'package:bnood/core/providers_api/providers_riverpod.dart';
import 'package:bnood/core/shared/pagination/pagination.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/auth_state.dart';
import 'package:bnood/features/auth/models/user.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/core/shared/pagination/paged_fetch_page.dart';
import 'package:bnood/core/widgets/skeleton/skeleton.dart';
import 'package:bnood/features/providers/providers_list_paging.dart';
import 'package:bnood/features/providers/providers_screen.dart';
import 'package:bnood/features/providers/widgets/providers_loading_skeleton.dart';
import 'package:bnood/features/suppliers/widgets/directory_list_loading_skeleton.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final now = DateTime.utc(2026, 11, 9);
  final sample = [
    AppProvider(
      id: '01J',
      name: 'مورد مواد',
      phone: '+201012345678',
      type: AppProviderType.supplier,
      createdAt: now,
      updatedAt: now,
    ),
  ];

  testWidgets('providers screen shows directory skeleton on first load', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(() => _AuthStub()),
          remoteProvidersEnabledProvider.overrideWith((ref) => true),
          providersListPagingProvider.overrideWith(
            (ref) => ({required int page, required int pageSize}) async {
              await Future<void>.delayed(const Duration(milliseconds: 200));
              return PagedFetchPage(items: sample, hasMore: false);
            },
          ),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => HomeFoundationScope(child: child!),
          home: const ProvidersScreen(),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(ProvidersLoadingSkeleton), findsOneWidget);
    expect(find.byType(DirectoryListRowSkeleton), findsWidgets);
    expect(find.byType(Skeleton), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();
    expect(find.text('مورد مواد'), findsOneWidget);
  });

  testWidgets('providers screen lists rows and filter chips in AR', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(() => _AuthStub()),
          remoteProvidersEnabledProvider.overrideWith((ref) => true),
          providersListPagingProvider.overrideWith(
            (ref) => ({required int page, required int pageSize}) async {
              if (page > 1) {
                return const PagedFetchPage(items: [], hasMore: false);
              }
              return PagedFetchPage(items: sample, hasMore: false);
            },
          ),
        ],
        child: MaterialApp(
          theme: AppFoundationTheme.light(),
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => HomeFoundationScope(child: child!),
          home: const ProvidersScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('مورد مواد'), findsOneWidget);
    expect(find.byKey(const Key('providers_filter_suppliers')), findsOneWidget);
    expect(find.byKey(const Key('providers_filter_craftsmen')), findsOneWidget);
    expect(find.textContaining('201012345678'), findsOneWidget);
  });
}

class _AuthStub extends AuthController {
  @override
  AuthState build() => AuthState(
        bootstrapStatus: AuthBootstrapStatus.authenticated,
        user: const User(id: 'u1', phone: '+201000000000', name: 'Test'),
        bootstrapStarted: true,
      );
}
