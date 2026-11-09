import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/items_api.dart';
import '../storage/session_store.dart';
import '../../features/auth/auth_controller.dart';
import 'item_api_record.dart';
import 'items_repository.dart';

final itemsApiProvider = Provider<ItemsApi>((ref) {
  final store = ref.watch(sessionStoreProvider);
  final api = ItemsApi(sessionStore: store);
  ref.onDispose(api.close);
  return api;
});

final itemsRepositoryProvider = Provider<ItemsRepository>((ref) {
  return ItemsRepository(ref.watch(itemsApiProvider));
});

/// Whether catalog CRUD should use the online API (not Drift).
final remoteItemsEnabledProvider = Provider<bool>((ref) {
  final auth = ref.watch(authControllerProvider);
  final user = auth.user;
  if (user == null || !auth.isAuthenticated) return false;
  return user.hasCompleteName;
});

final itemIconsCatalogProvider = FutureProvider.autoDispose<ItemIconsCatalog>((ref) {
  if (!ref.watch(remoteItemsEnabledProvider)) {
    return Future.error(StateError('Items API requires signed-in session'));
  }
  return ref.watch(itemsRepositoryProvider).fetchIconsCatalog();
});
