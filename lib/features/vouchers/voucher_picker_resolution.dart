import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clients/client_api_record.dart';
import '../../core/clients/clients_providers.dart';
import '../../core/database/database.dart';
import '../../core/items/items_providers.dart';
import '../../core/providers/app_providers.dart';
import '../../core/providers_api/app_provider_record.dart';
import '../../core/providers_api/providers_riverpod.dart';

typedef ProviderRead = T Function<T>(ProviderListenable<T> provider);

/// Label for [id] in a pre-open picker snapshot, if present.
String? labelFromPickerEntries(List<(String id, String label)> entries, String id) {
  for (final entry in entries) {
    if (entry.$1 == id) return entry.$2;
  }
  return null;
}

String? labelFromProviders(Iterable<AppProvider> providers, String id) {
  for (final p in providers) {
    if (p.id == id) return p.name;
  }
  return null;
}

Future<String> resolveRemoteProviderLabel(
  ProviderRead read,
  String id, {
  Iterable<AppProvider>? cached,
}) async {
  final cachedLabel = cached == null ? null : labelFromProviders(cached, id);
  if (cachedLabel != null) return cachedLabel;
  return (await read(appProvidersRepositoryProvider).getProvider(id)).name;
}

Future<String> resolveLocalSupplierLabel(
  ProviderRead read,
  String id, {
  Iterable<Supplier>? cached,
}) async {
  for (final s in cached ?? const <Supplier>[]) {
    if (s.id == id) return s.name;
  }
  final supplier = await read(repositoryProvider).getSupplier(id);
  if (supplier != null) return supplier.name;
  throw StateError('Supplier not found for id $id');
}

Future<String> resolveLocalCraftsmanLabel(
  ProviderRead read,
  String id, {
  Iterable<CraftsmenData>? cached,
}) async {
  for (final c in cached ?? const <CraftsmenData>[]) {
    if (c.id == id) return c.name;
  }
  final craftsman = await read(repositoryProvider).getCraftsman(id);
  if (craftsman != null) return craftsman.name;
  throw StateError('Craftsman not found for id $id');
}

Future<Client> resolveLocalClient(ProviderRead read, String id, {Iterable<Client>? cached}) async {
  for (final c in cached ?? const <Client>[]) {
    if (c.id == id) return c;
  }
  return read(repositoryProvider).getClient(id);
}

Future<ClientApiRecord> resolveRemoteClient(
  ProviderRead read,
  String id, {
  Iterable<ClientApiRecord>? cached,
}) async {
  for (final record in cached ?? const <ClientApiRecord>[]) {
    if (record.client.id == id) return record;
  }
  return read(clientsRepositoryProvider).getClient(id);
}

Future<String> resolveItemLabel(
  ProviderRead read,
  String id, {
  required bool remote,
  String? cachedLabel,
}) async {
  if (cachedLabel != null) return cachedLabel;
  if (remote) {
    return (await read(itemsRepositoryProvider).getItem(id)).name;
  }
  final item = await read(repositoryProvider).getItem(id);
  if (item != null) return item.name;
  throw StateError('Item not found for id $id');
}
