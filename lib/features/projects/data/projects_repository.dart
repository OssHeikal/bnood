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

  Future<({List<ProjectListRow> items, bool hasMore, int page})> listProjects({
    required ClientListArchiveFilter status,
    String? q,
    int page = 1,
    int perPage = 50,
  }) async {
    if (isOfficeScope()) {
      final result = await officeProjectsApi.listProjects(
        status: status,
        q: q,
        page: page,
        perPage: perPage,
      );
      return (
        items: result.items.map(projectListRowFromOfficeRecord).toList(),
        hasMore: result.hasMore,
        page: result.page,
      );
    }

    final result = await clientsRepository.listClients(
      status: status,
      q: q,
      page: page,
      perPage: perPage,
    );
    return (
      items: result.items.map(projectListRowFromClientRecord).toList(),
      hasMore: result.hasMore,
      page: result.page,
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