import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bnood/features/clients/data/client_list_archive_filter.dart';

final projectsListFilterProvider = StateProvider<ClientListArchiveFilter>(
  (ref) => ClientListArchiveFilter.active,
);

final projectsListSearchQueryProvider = StateProvider<String>((ref) => '');