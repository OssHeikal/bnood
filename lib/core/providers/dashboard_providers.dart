import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/bnood_repository.dart';
import 'app_providers.dart';

final homeTotalsProvider = FutureProvider<HomeTotals>((ref) {
  return ref.watch(repositoryProvider).homeTotals();
});

final activeClientsProvider = FutureProvider((ref) {
  return ref.watch(repositoryProvider).watchActiveClients();
});
