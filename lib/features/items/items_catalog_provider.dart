import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database.dart';
import '../../core/providers/app_providers.dart';

final itemsCatalogProvider = StreamProvider.autoDispose<List<Item>>((ref) {
  return ref.watch(repositoryProvider).watchActiveItems();
});
