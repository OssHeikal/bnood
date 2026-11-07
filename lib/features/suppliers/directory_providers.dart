import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../core/repositories/bnood_repository.dart';

final directorySuppliersProvider =
    StreamProvider.autoDispose<List<DirectorySupplierRow>>((ref) {
  return ref.watch(repositoryProvider).watchDirectorySupplierRows();
});

final directoryCraftsmenProvider =
    StreamProvider.autoDispose<List<DirectoryCraftsmanRow>>((ref) {
  return ref.watch(repositoryProvider).watchDirectoryCraftsmanRows();
});
