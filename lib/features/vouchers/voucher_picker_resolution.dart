import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clients/client_api_record.dart';
import '../../core/clients/clients_providers.dart';
import '../../core/items/items_providers.dart';
import '../../core/providers_api/app_provider_record.dart';
import '../../core/providers_api/providers_riverpod.dart';

typedef ProviderRead = T Function<T>(ProviderListenable<T> provider);

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
  String? cachedLabel,
}) async {
  if (cachedLabel != null) return cachedLabel;
  return (await read(itemsRepositoryProvider).getItem(id)).name;
}
