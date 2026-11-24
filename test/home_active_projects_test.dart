import 'package:bnood/features/clients/data/client_list_archive_filter.dart';
import 'package:bnood/features/clients/data/clients_api.dart';
import 'package:bnood/features/clients/data/clients_repository.dart';
import 'package:bnood/features/home/data/app_home_dashboard.dart';
import 'package:bnood/features/home/data/app_home_totals.dart';
import 'package:bnood/features/home/data/home_api.dart';
import 'package:bnood/features/home/data/home_repository.dart';
import 'package:bnood/features/home/data/home_riverpod.dart';
import 'package:bnood/features/home/data/home_row_models.dart';
import 'package:bnood/features/home/data/home_section_counts.dart';
import 'package:bnood/features/home/presentation/providers/home_dashboard_providers.dart';
import 'package:bnood/features/home/presentation/screens/home_screen.dart';
import 'package:bnood/features/projects/data/office_projects_api.dart';
import 'package:bnood/features/projects/data/project_list_row.dart';
import 'package:bnood/features/projects/data/projects_repository.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_session_store.dart';
import 'support/home_notifier_stubs.dart';

ProjectListRow _projectRow(int index) {
  return ProjectListRow(
    projectId: 'p$index',
    projectName: 'Project $index',
    clientId: 'c$index',
    clientName: 'Client $index',
    receivedPiastres: 0,
    spentPiastres: 0,
    remainingPiastres: 0,
  );
}

void main() {
  test('home active projects preview keeps three rows and total count', () async {
    final items = List.generate(5, _projectRow);
  final container = ProviderContainer(
    overrides: [
      projectsRepositoryProvider.overrideWithValue(
        _FakeProjectsRepository(items: items, total: 12),
      ),
    ],
  );
    addTearDown(container.dispose);

    final preview = await container.read(homeActiveProjectsProvider.future);

    expect(preview, hasLength(3));
    expect(preview.map((row) => row.projectId), ['p0', 'p1', 'p2']);
    expect(container.read(homeSectionCountsProvider).projectsCount, 12);
    expect(_FakeProjectsRepository.lastSort, 'updated_at');
    expect(_FakeProjectsRepository.lastOrder, 'desc');
    expect(
      _FakeProjectsRepository.lastStatus,
      ClientListArchiveFilter.active,
    );
  });

  test('home dashboard craftsmen load keeps projects see-all total', () async {
    final items = List.generate(7, _projectRow);
    final container = ProviderContainer(
      overrides: [
        projectsRepositoryProvider.overrideWithValue(
          _FakeProjectsRepository(items: items, total: 7),
        ),
        homeRepositoryProvider.overrideWithValue(
          _StubHomeDashboardRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final preview = await container.read(homeActiveProjectsProvider.future);
    expect(preview, hasLength(3));
    expect(container.read(homeSectionCountsProvider).projectsCount, 7);

    await container.read(homeCraftsmenProvider.future);
    final counts = container.read(homeSectionCountsProvider);

    expect(counts.projectsCount, 7);
    expect(counts.craftsmenCount, 30);
    expect(counts.suppliersCount, 20);
  });

  testWidgets('home shows active project rows with client subtitle', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final rows = List.generate(3, (index) {
      if (index == 0) {
        return const ProjectListRow(
          projectId: 'p1',
          projectName: 'Tower A',
          clientId: 'c1',
          clientName: 'Nile Co',
          receivedPiastres: 100_000,
          spentPiastres: 40_000,
          remainingPiastres: 60_000,
        );
      }
      return _projectRow(index);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeTotalsOverride(
            const HomeTotals(receivedPiastres: 100_000, spentPiastres: 40_000),
          ),
          homeSectionCountsProvider.overrideWith(
            (ref) => const HomeSectionCounts(projectsCount: 9),
          ),
          homeActiveProjectsOverride(rows),
          emptyHomeSupplierSpendsOverride(),
          emptyHomeCraftsmenOverride(),
          emptyHomeSuppliersOverride(),
        ],
        child: MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('مشاريع نشطة'), findsOneWidget);
    expect(find.text('Tower A'), findsOneWidget);
    expect(find.text('Nile Co'), findsOneWidget);
    expect(find.text('Project 1'), findsOneWidget);
    expect(find.text('Project 2'), findsOneWidget);
    expect(find.text('عرض الكل (9)'), findsOneWidget);
    expect(find.text('عملاء نشطون'), findsNothing);
  });
}

class _StubHomeDashboardRepository extends HomeRepository {
  _StubHomeDashboardRepository()
      : super(HomeApi(sessionStore: FakeSessionStore(token: 'tok')));

  @override
  Future<AppHomeDashboard> getHomeDashboard() async {
    return const AppHomeDashboard(
      totals: AppHomeTotals(
        receivedMinor: 0,
        spentMinor: 0,
        remainingMinor: 0,
      ),
      clients: [],
      craftsmen: [AppHomeCraftsmanPreview(id: 'craftsman', name: 'Worker')],
      suppliers: [],
      clientsCount: 6,
      craftsmenCount: 30,
      suppliersCount: 20,
    );
  }
}

class _FakeProjectsRepository extends ProjectsRepository {
  _FakeProjectsRepository({required this.items, required this.total})
      : super(
          clientsRepository: ClientsRepository(ClientsApi()),
          officeProjectsApi: OfficeProjectsApi(
            sessionStore: FakeSessionStore(token: 'tok'),
          ),
          isOfficeScope: () => true,
        );

  final List<ProjectListRow> items;
  final int total;

  static String? lastSort;
  static String? lastOrder;
  static ClientListArchiveFilter? lastStatus;

  @override
  Future<({
    List<ProjectListRow> items,
    bool hasMore,
    int page,
    int total,
  })> listProjects({
    required ClientListArchiveFilter status,
    String? q,
    int page = 1,
    int perPage = 50,
    String sort = 'name',
    String order = 'asc',
  }) async {
    lastSort = sort;
    lastOrder = order;
    lastStatus = status;
    return (
      items: items,
      hasMore: false,
      page: page,
      total: total,
    );
  }
}