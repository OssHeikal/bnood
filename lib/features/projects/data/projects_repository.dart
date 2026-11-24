import 'package:bnood/core/account/account_context_providers.dart';
import 'package:bnood/core/data/storage/session_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../clients/data/client_list_archive_filter.dart';
import '../../clients/data/clients_providers.dart';
import '../../clients/data/clients_repository.dart';
import 'office_projects_api.dart';
import 'project_list_row.dart';

class ProjectsRepository {
  ProjectsRepository({
    required this.clientsRepository,
    required this.officeProjectsApi,
    required this.isOfficeScope,
  });

  final ClientsRepository clientsRepository;
  final OfficeProjectsApi officeProjectsApi;
  final bool Function() isOfficeScope;

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
    if (isOfficeScope()) {
      final result = await officeProjectsApi.listProjects(
        status: status,
        q: q,
        page: page,
        perPage: perPage,
        sort: sort,
        order: order,
      );
      return (
        items: result.items.map(projectListRowFromOfficeRecord).toList(),
        hasMore: result.hasMore,
        page: result.page,
        total: result.total,
      );
    }

    final result = await clientsRepository.listClients(
      status: status,
      q: q,
      page: page,
      perPage: perPage,
    );
    final items = result.items.map(projectListRowFromClientRecord).toList();
    if (sort == 'updated_at') {
      items.sort((a, b) {
        final left = a.lastActivityAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final right = b.lastActivityAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final cmp = left.compareTo(right);
        return order == 'desc' ? -cmp : cmp;
      });
    }
    return (
      items: items,
      hasMore: result.hasMore,
      page: result.page,
      total: result.total,
    );
  }
}

final officeProjectsApiProvider = Provider<OfficeProjectsApi>((ref) {
  final store = ref.watch(sessionStoreProvider);
  final api = OfficeProjectsApi(sessionStore: store);
  ref.onDispose(api.close);
  return api;
});

final projectsRepositoryProvider = Provider<ProjectsRepository>((ref) {
  final ctx = ref.watch(accountContextProvider);
  return ProjectsRepository(
    clientsRepository: ref.watch(clientsRepositoryProvider),
    officeProjectsApi: ref.watch(officeProjectsApiProvider),
    isOfficeScope: () => !ctx.isPersonal,
  );
});