import 'package:bnood/core/account/account_context_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bnood/features/projects/data/project_list_row.dart';
import 'package:bnood/features/projects/data/projects_repository.dart';
import '../../../../core/shared/pagination/pagination.dart';
import 'projects_list_providers.dart';

const projectsListPageSize = 50;

final projectsListPageFetcherProvider =
    Provider<PagedFetchCallback<ProjectListRow>>((ref) {
      ref.watch(accountContextProvider);
      return ({required int page, required int pageSize}) async {
        final repo = ref.read(projectsRepositoryProvider);
        final filter = ref.read(projectsListFilterProvider);
        final q = ref.read(projectsListSearchQueryProvider);
        final result = await repo.listProjects(
          status: filter,
          q: q,
          page: page,
          perPage: pageSize,
        );
        return PagedFetchPage(
          items: result.items,
          hasMore: result.hasMore,
        );
      };
    });