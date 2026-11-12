import 'package:bnood/core/config/theme/app_theme.dart';
import 'package:bnood/core/api/items_api.dart';
import 'package:bnood/core/database/database.dart';
import 'package:bnood/core/items/item_api_record.dart';
import 'package:bnood/core/prefs/app_settings_store.dart';
import 'package:bnood/core/home/home_section_counts.dart';
import 'package:bnood/core/providers/app_providers.dart';
import 'package:bnood/core/providers/dashboard_providers.dart';
import 'package:bnood/core/providers/settings_provider.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:bnood/core/items/items_providers.dart';
import 'package:bnood/core/items/items_repository.dart';
import 'package:bnood/core/layout/bnood_breakpoints.dart';
import 'package:bnood/core/layout/bnood_layout.dart';
import 'package:bnood/core/layout/bnood_column_grid.dart';
import 'package:bnood/core/layout/bnood_list_canvas.dart';
import 'package:bnood/core/database/connection.dart';
import 'package:bnood/core/layout/bnood_two_column.dart';
import 'package:bnood/core/providers_api/app_provider_record.dart';
import 'package:bnood/core/providers_api/providers_riverpod.dart';
import 'package:bnood/core/shared/pagination/pagination.dart';
import 'package:bnood/core/shared/pagination/paged_sliver_two_column.dart';
import 'package:bnood/core/shared/pagination/paged_fetch_page.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/auth_state.dart';
import 'package:bnood/features/auth/complete_profile_screen.dart';
import 'package:bnood/features/auth/forgot_password_screen.dart';
import 'package:bnood/features/auth/login_screen.dart';
import 'package:bnood/features/auth/models/user.dart';
import 'package:bnood/features/auth/register_screen.dart';
import 'package:bnood/features/auth/register_verify_screen.dart';
import 'package:bnood/features/auth/reset_password_screen.dart';
import 'package:bnood/features/auth/user_profile_screen.dart';
import 'package:bnood/core/clients/clients_providers.dart';
import 'package:bnood/features/clients/client_detail_provider.dart';
import 'package:bnood/features/clients/client_detail_screen.dart';
import 'package:bnood/features/clients/client_detail_snapshot.dart';
import 'package:bnood/features/clients/clients_list_paging.dart';
import 'package:bnood/features/clients/clients_list_screen.dart';
import 'package:bnood/features/content/content_page_provider.dart';
import 'package:bnood/features/content/content_page_screen.dart';
import 'package:bnood/core/content/content_page_record.dart';
import 'package:bnood/features/home/home_screen.dart';
import 'package:bnood/features/items/items_screen.dart';
import 'package:bnood/features/providers/provider_detail_provider.dart';
import 'package:bnood/features/providers/provider_detail_screen.dart';
import 'package:bnood/features/providers/provider_detail_snapshot.dart';
import 'package:bnood/features/providers/providers_list_paging.dart';
import 'package:bnood/features/providers/providers_screen.dart';
import 'package:bnood/features/settings/app_preferences_screen.dart';
import 'package:bnood/features/settings/app_settings_screen.dart';
import 'package:bnood/features/home/home_foundation_scope.dart';
import 'package:bnood/features/statements/client_statement_screen.dart';
import 'package:bnood/features/suppliers/directory_screen.dart';
import 'package:bnood/features/suppliers/directory_providers.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/home_notifier_stubs.dart';

void _setSurface(WidgetTester tester, double width) {
  tester.binding.window.physicalSizeTestValue = Size(width, 900);
  tester.binding.window.devicePixelRatioTestValue = 1.0;
  addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
  addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
}

Widget _wrap({
  required Widget child,
  required double width,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: AppFoundationTheme.light(),
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, appChild) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(size: Size(width, 900)),
          child: ResponsiveBreakpoints.builder(
            breakpoints: BnoodBreakpoints.all,
            child: HomeFoundationScope(child: appChild!),
          ),
        );
      },
      home: child,
    ),
  );
}

bool _hasTabletGutter(WidgetTester tester) {
  return tester.widgetList<Padding>(find.byType(Padding)).any((widget) {
    final pad = widget.padding;
    if (pad is EdgeInsets) {
      return pad.left == BnoodLayout.gutterTablet || pad.right == BnoodLayout.gutterTablet;
    }
  if (pad is EdgeInsetsDirectional) {
      return pad.start == BnoodLayout.gutterTablet || pad.end == BnoodLayout.gutterTablet;
    }
    return false;
  });
}

bool _hasMaxWidth(WidgetTester tester, double maxWidth) {
  return tester
      .widgetList<ConstrainedBox>(find.byType(ConstrainedBox))
      .any((box) => box.constraints.maxWidth == maxWidth);
}

bool _hasFormCanvasWidth(WidgetTester tester) {
  return tester
      .widgetList<SizedBox>(find.byType(SizedBox))
      .any((box) => box.width == BnoodLayout.formMaxWidth);
}

class _AuthStub extends AuthController {
  @override
  AuthState build() => AuthState(
        bootstrapStatus: AuthBootstrapStatus.authenticated,
        bootstrapStarted: true,
        user: User(
          id: 'u1',
          phone: '+96890000000',
          name: 'Tester',
        ),
      );
}

Future<void> _pumpHome(WidgetTester tester, double width) async {
  await tester.pumpWidget(
    _wrap(
      width: width,
      overrides: [
        homeTotalsProvider.overrideWith(() => StubHomeTotalsNotifier(const HomeTotals(receivedPiastres: 0, spentPiastres: 0))),
        homeClientBalancesOverride(const []),
        emptyHomeSupplierSpendsOverride(),
        emptyHomeCraftsmenOverride(),
        homeSectionCountsProvider.overrideWith((ref) => const HomeSectionCounts()),
        remoteClientsEnabledProvider.overrideWith((ref) => false),
      ],
      child: const HomeScreen(),
    ),
  );
  await tester.pump();
  await tester.pumpAndSettle();
}

ClientDetailSnapshot _minimalClientSnapshot() {
  final now = DateTime.utc(2026, 1, 1);
  return ClientDetailSnapshot(
    client: Client(id: 'c1', workspaceId: 'w', name: 'Client', createdAt: now, updatedAt: now),
    project: Project(
      id: 'p1',
      workspaceId: 'w',
      clientId: 'c1',
      name: 'Project',
      status: 'active',
      createdAt: now,
      updatedAt: now,
    ),
    receivedPiastres: 0,
    spentPiastres: 0,
    estimatedProfitPiastres: null,
    latestMovements: const [],
    topItems: const [],
    craftsmanPreviews: const [],
  );
}

ProviderDetailSnapshot _minimalProviderSnapshot() {
  final now = DateTime.utc(2026, 1, 1);
  return ProviderDetailSnapshot(
    provider: AppProvider(
      id: 'p1',
      name: 'Provider',
      phone: '+96890000000',
      type: AppProviderType.craftsman,
      createdAt: now,
      updatedAt: now,
    ),
    clientAgreements: const [],
    voucherHistory: const [],
    totalVoucherMinor: 0,
  );
}

class _StaticDetailNotifier extends ClientDetailNotifier {
  _StaticDetailNotifier(this.snapshot);

  final ClientDetailSnapshot snapshot;

  @override
  Future<ClientDetailSnapshot> build(String arg) async => snapshot;
}

class _StaticProviderDetailNotifier extends ProviderDetailNotifier {
  _StaticProviderDetailNotifier(this.snapshot);

  final ProviderDetailSnapshot snapshot;

  @override
  Future<ProviderDetailSnapshot> build(String arg) async => snapshot;
}

class _FakeCatalogRepository extends ItemsRepository {
  _FakeCatalogRepository({required this.items}) : super(ItemsApi());

  final List<CatalogItem> items;

  @override
  Future<ItemsListPage> listItems({String? q, int page = 1, int perPage = 50}) async {
    return ItemsListPage(items: items, page: 1, perPage: perPage, total: items.length);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const widths = [390.0, 820.0, 1280.0];
  final now = DateTime.utc(2026, 1, 1);

  for (final width in widths) {
    final isMobile = width <= BnoodBreakpoints.mobileMax;
    final isTabletPlus = width > BnoodBreakpoints.mobileMax;

    testWidgets('home layout at $width', (tester) async {
      _setSurface(tester, width);
      await _pumpHome(tester, width);
      if (isMobile) {
        expect(find.byType(BnoodTwoColumn), findsNothing);
      } else {
        expect(find.byType(BnoodTwoColumn), findsOneWidget);
        expect(_hasMaxWidth(tester, BnoodLayout.pageMaxWidth), isTrue);
        expect(find.byKey(HomeScreen.primaryColumnKey), findsOneWidget);
        expect(find.byKey(HomeScreen.providersColumnKey), findsOneWidget);
        expect(
          find.descendant(
            of: find.byKey(HomeScreen.providersColumnKey),
            matching: find.text('Active clients'),
          ),
          findsNothing,
        );
        expect(
          find.descendant(
            of: find.byKey(HomeScreen.providersColumnKey),
            matching: find.text('Craftsmen with recent labor'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byKey(HomeScreen.primaryColumnKey),
            matching: find.text('Active clients'),
          ),
          findsOneWidget,
        );
      }
    });

    testWidgets('menu hub list canvas at $width', (tester) async {
      _setSurface(tester, width);
      await tester.pumpWidget(_wrap(width: width, child: const AppMenuScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(BnoodListCanvas), findsOneWidget);
      if (isTabletPlus) {
        expect(_hasMaxWidth(tester, BnoodLayout.listMaxWidth), isTrue);
      }
    });

    testWidgets('preferences list canvas at $width', (tester) async {
      _setSurface(tester, width);
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final snap = AppSettingsSnapshot(themeMode: ThemeMode.system, locale: const Locale('en'), prefs: prefs);
      await tester.pumpWidget(
        _wrap(
          width: width,
          overrides: [appSettingsBootstrapProvider.overrideWithValue(snap)],
          child: const AppPreferencesScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(BnoodListCanvas), findsOneWidget);
    });

    testWidgets('profile list canvas at $width', (tester) async {
      _setSurface(tester, width);
      await tester.pumpWidget(
        _wrap(
          width: width,
          overrides: [authControllerProvider.overrideWith(() => _AuthStub())],
          child: const UserProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(BnoodListCanvas), findsOneWidget);
    });

    testWidgets('content page list canvas at $width', (tester) async {
      _setSurface(tester, width);
      await tester.pumpWidget(
        _wrap(
          width: width,
          overrides: [
            contentPageProvider('privacy').overrideWith(
              (ref) async => ContentPage(
                slug: 'privacy',
                locale: 'en',
                title: 'Privacy',
                body: '<p>ok</p>',
                format: 'html',
                updatedAt: now,
              ),
            ),
          ],
          child: const ContentPageScreen(slug: 'privacy'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(BnoodListCanvas), findsOneWidget);
    });

    testWidgets('login auth canvas at $width', (tester) async {
      _setSurface(tester, width);
      await tester.pumpWidget(_wrap(width: width, child: const LoginScreen()));
      await tester.pumpAndSettle();
      if (isTabletPlus) {
        expect(_hasFormCanvasWidth(tester), isTrue);
      }
    });

    testWidgets('register auth canvas at $width', (tester) async {
      _setSurface(tester, width);
      await tester.pumpWidget(_wrap(width: width, child: const RegisterScreen()));
      await tester.pumpAndSettle();
      if (isTabletPlus) {
        expect(_hasFormCanvasWidth(tester), isTrue);
      }
    });

    testWidgets('complete profile auth canvas at $width', (tester) async {
      _setSurface(tester, width);
      await tester.pumpWidget(
        _wrap(
          width: width,
          overrides: [authControllerProvider.overrideWith(() => _AuthStub())],
          child: const CompleteProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();
      if (isTabletPlus) {
        expect(_hasFormCanvasWidth(tester), isTrue);
      }
    });

    testWidgets('forgot password auth canvas at $width', (tester) async {
      _setSurface(tester, width);
      await tester.pumpWidget(_wrap(width: width, child: const ForgotPasswordScreen()));
      await tester.pumpAndSettle();
      if (isTabletPlus) {
        expect(_hasFormCanvasWidth(tester), isTrue);
      }
    });

    testWidgets('reset password auth canvas at $width', (tester) async {
      _setSurface(tester, width);
      await tester.pumpWidget(_wrap(width: width, child: const ResetPasswordScreen()));
      await tester.pumpAndSettle();
      if (isTabletPlus) {
        expect(_hasFormCanvasWidth(tester), isTrue);
      }
    });

    testWidgets('register verify auth canvas at $width', (tester) async {
      _setSurface(tester, width);
      await tester.pumpWidget(
        _wrap(width: width, child: const RegisterVerifyScreen()),
      );
      await tester.pumpAndSettle();
      if (isTabletPlus) {
        expect(_hasFormCanvasWidth(tester), isTrue);
      }
    });

    testWidgets('clients list grid at $width', (tester) async {
      _setSurface(tester, width);
      await tester.pumpWidget(
        _wrap(
          width: width,
          overrides: [
            clientsListPageFetcherProvider.overrideWith(
              (ref) => ({required int page, required int pageSize}) async => PagedFetchPage(
                items: [
                  HomeClientBalanceRow(
                    client: Client(id: 'c1', workspaceId: 'w', name: 'A', createdAt: now, updatedAt: now),
                    receivedPiastres: 0,
                    spentPiastres: 0,
                    remainingPiastres: 0,
                  ),
                ],
                hasMore: false,
              ),
            ),
          ],
          child: const ClientsListScreen(),
        ),
      );
      await tester.pumpAndSettle();
      if (isMobile) {
        expect(find.byType(PagedSliverList<int, HomeClientBalanceRow>), findsOneWidget);
      } else {
        expect(find.byType(PagedSliverTwoColumn<int, HomeClientBalanceRow>), findsOneWidget);
        expect(find.byType(IntrinsicHeight), findsWidgets);
      }
    });

    testWidgets('providers directory grid at $width', (tester) async {
      _setSurface(tester, width);
      await tester.pumpWidget(
        _wrap(
          width: width,
          overrides: [
            authControllerProvider.overrideWith(() => _AuthStub()),
            remoteProvidersEnabledProvider.overrideWith((ref) => true),
            providersListPagingProvider.overrideWith(
              (ref) => ({required int page, required int pageSize}) async => PagedFetchPage(
                items: [
                  AppProvider(
                    id: '01',
                    name: 'Supplier',
                    phone: '+96890000000',
                    type: AppProviderType.supplier,
                    createdAt: now,
                    updatedAt: now,
                  ),
                ],
                hasMore: false,
              ),
            ),
          ],
          child: const ProvidersScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      tester.takeException();
      if (isMobile) {
        expect(find.byType(PagedSliverList<int, AppProvider>), findsOneWidget);
      } else {
        expect(find.byType(PagedSliverTwoColumn<int, AppProvider>), findsOneWidget);
        expect(find.byType(IntrinsicHeight), findsWidgets);
      }
    });

    testWidgets('items grid columns at $width', (tester) async {
      _setSurface(tester, width);
      final items = [
        CatalogItem(
          id: '1',
          name: 'One',
          iconKey: 'layers',
          colorKey: 'teal',
          isDefault: false,
          sortOrder: 1,
          createdAt: now,
          updatedAt: now,
        ),
        CatalogItem(
          id: '2',
          name: 'Two',
          iconKey: 'layers',
          colorKey: 'teal',
          isDefault: false,
          sortOrder: 2,
          createdAt: now,
          updatedAt: now,
        ),
      ];
      await tester.pumpWidget(
        _wrap(
          width: width,
          overrides: [
            authControllerProvider.overrideWith(() => _AuthStub()),
            remoteItemsEnabledProvider.overrideWith((ref) => true),
            itemsRepositoryProvider.overrideWithValue(_FakeCatalogRepository(items: items)),
            itemIconsCatalogProvider.overrideWith(
              (ref) async => const ItemIconsCatalog(
                colors: [ItemColorOption(key: 'teal', hex: '#0D9B8A')],
                iconKeys: ['layers'],
              ),
            ),
          ],
          child: const ItemsScreen(),
        ),
      );
      await tester.pumpAndSettle();
      final grid = tester.widget<GridView>(find.byType(GridView));
      final delegate = grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      final expectedColumns = isMobile ? 2 : (width <= BnoodBreakpoints.tabletMax ? 3 : 4);
      expect(delegate.crossAxisCount, expectedColumns);
    });

    testWidgets('client detail two column at $width', (tester) async {
      _setSurface(tester, width);
      await tester.pumpWidget(
        _wrap(
          width: width,
          overrides: [
            clientDetailProvider.overrideWith(() => _StaticDetailNotifier(_minimalClientSnapshot())),
          ],
          child: const ClientDetailScreen(clientId: 'c1'),
        ),
      );
      await tester.pumpAndSettle();
      if (isMobile) {
        expect(find.byType(BnoodTwoColumn), findsNothing);
      } else {
        expect(find.byType(BnoodTwoColumn), findsOneWidget);
      }
    });

    testWidgets('provider detail two column at $width', (tester) async {
      _setSurface(tester, width);
      await tester.pumpWidget(
        _wrap(
          width: width,
          overrides: [
            providerDetailProvider.overrideWith(() => _StaticProviderDetailNotifier(_minimalProviderSnapshot())),
          ],
          child: const ProviderDetailScreen(providerId: 'p1'),
        ),
      );
      await tester.pumpAndSettle();
      if (isMobile) {
        expect(find.byType(BnoodTwoColumn), findsNothing);
      } else {
        expect(find.byType(BnoodTwoColumn), findsOneWidget);
      }
    });

    testWidgets('client statement stacked ListView at $width', (tester) async {
      _setSurface(tester, width);
      final db = openTestDatabase();
      addTearDown(db.close);
      final repo = BnoodRepository(db);
      final client = await repo.createClient(name: 'Stmt Client');
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        _wrap(
          width: width,
          overrides: [repositoryProvider.overrideWithValue(repo)],
          child: ClientStatementScreen(clientId: client.id),
        ),
      );
      await tester.pump();
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        if (find.text('Stmt Client').evaluate().isNotEmpty) break;
      }
      expect(find.byType(BnoodTwoColumn), findsNothing);
      expect(find.text('Stmt Client'), findsOneWidget);
      expect(find.byType(FilterChip), findsNWidgets(5));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('client statement screen mounts at tablet', (tester) async {
    _setSurface(tester, 820);
    await tester.pumpWidget(
      _wrap(
        width: 820,
        child: const ClientStatementScreen(clientId: 'c1'),
      ),
    );
    await tester.pump();
    expect(find.byType(ClientStatementScreen), findsOneWidget);
  });

  for (final width in [768.0, 1024.0]) {
    testWidgets('home has tablet gutters at $width', (tester) async {
      _setSurface(tester, width);
      await _pumpHome(tester, width);
      expect(_hasTabletGutter(tester), isTrue);
    });

    testWidgets('items screen has tablet gutters at $width', (tester) async {
      _setSurface(tester, width);
      final items = [
        CatalogItem(
          id: '1',
          name: 'One',
          iconKey: 'layers',
          colorKey: 'teal',
          isDefault: false,
          sortOrder: 1,
          createdAt: now,
          updatedAt: now,
        ),
      ];
      await tester.pumpWidget(
        _wrap(
          width: width,
          overrides: [
            authControllerProvider.overrideWith(() => _AuthStub()),
            remoteItemsEnabledProvider.overrideWith((ref) => true),
            itemsRepositoryProvider.overrideWithValue(_FakeCatalogRepository(items: items)),
            itemIconsCatalogProvider.overrideWith(
              (ref) async => const ItemIconsCatalog(
                colors: [ItemColorOption(key: 'teal', hex: '#0D9B8A')],
                iconKeys: ['layers'],
              ),
            ),
          ],
          child: const ItemsScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(_hasTabletGutter(tester), isTrue);
    });

    testWidgets('clients list gutter and no overflow at $width', (tester) async {
      _setSurface(tester, width);
      await tester.pumpWidget(
        _wrap(
          width: width,
          overrides: [
            clientsListPageFetcherProvider.overrideWith(
              (ref) => ({required int page, required int pageSize}) async => PagedFetchPage(
                items: [
                  for (var i = 0; i < 4; i++)
                    HomeClientBalanceRow(
                      client: Client(
                        id: 'c$i',
                        workspaceId: 'w',
                        name: 'Client $i',
                        createdAt: now,
                        updatedAt: now,
                      ),
                      receivedPiastres: 100,
                      spentPiastres: 50,
                      remainingPiastres: 50,
                    ),
                ],
                hasMore: false,
              ),
            ),
          ],
          child: const ClientsListScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
      expect(_hasTabletGutter(tester), isTrue);
      expect(find.byType(PagedSliverTwoColumn<int, HomeClientBalanceRow>), findsOneWidget);
    });

    testWidgets('local directory two-column without overflow at $width', (tester) async {
      _setSurface(tester, width);
      await tester.pumpWidget(
        _wrap(
          width: width,
          overrides: [
            directorySuppliersProvider.overrideWith(
              (ref) => Stream.value([
                DirectorySupplierRow(
                  supplier: Supplier(id: 's1', workspaceId: 'w', name: 'Supplier One', createdAt: now, updatedAt: now),
                  paidPiastres: 1000,
                ),
                DirectorySupplierRow(
                  supplier: Supplier(id: 's2', workspaceId: 'w', name: 'Supplier Two', createdAt: now, updatedAt: now),
                  paidPiastres: 2000,
                ),
              ]),
            ),
            directoryCraftsmenProvider.overrideWith((ref) => Stream.value(const [])),
          ],
          child: const DirectoryScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
      expect(find.byType(BnoodColumnGrid), findsWidgets);
      expect(_hasTabletGutter(tester), isTrue);
    });

    testWidgets('client statement screen content at $width', (tester) async {
      _setSurface(tester, width);
      final db = openTestDatabase();
      addTearDown(db.close);
      final repo = BnoodRepository(db);
      final client = await repo.createClient(name: 'iPad Statement');
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        _wrap(
          width: width,
          overrides: [repositoryProvider.overrideWithValue(repo)],
          child: ClientStatementScreen(clientId: client.id),
        ),
      );
      await tester.pump();
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        if (find.text('iPad Statement').evaluate().isNotEmpty) break;
      }
      expect(find.byType(BnoodTwoColumn), findsNothing);
      expect(find.text('iPad Statement'), findsOneWidget);
      expect(find.byType(ListView), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  }
}
