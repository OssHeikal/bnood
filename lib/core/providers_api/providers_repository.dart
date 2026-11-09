import '../api/providers_api.dart';
import 'app_provider_record.dart';

class ProvidersRepository {
  ProvidersRepository(this._api);

  final ProvidersApi _api;

  Future<ProvidersListPage> listProviders({
    String? q,
    AppProviderType? type,
    int page = 1,
    int perPage = 50,
  }) =>
      _api.listProviders(q: q, type: type, page: page, perPage: perPage);

  Future<AppProvider> getProvider(String id) => _api.getProvider(id);

  Future<AppProvider> createProvider({
    required String name,
    required AppProviderType type,
    String? phone,
  }) =>
      _api.createProvider(name: name, type: type, phone: phone);

  Future<AppProvider> updateProvider({
    required String id,
    String? name,
    String? phone,
    bool clearPhone = false,
  }) =>
      _api.updateProvider(id: id, name: name, phone: phone, clearPhone: clearPhone);

  Future<void> deleteProvider(String id) => _api.deleteProvider(id);

  Future<List<AppProvider>> listAllSuppliers({String? q}) async {
    final all = <AppProvider>[];
    var page = 1;
    while (true) {
      final result = await listProviders(
        q: q,
        type: AppProviderType.supplier,
        page: page,
        perPage: 50,
      );
      all.addAll(result.items);
      if (!result.hasMore) break;
      page++;
    }
    return all;
  }

  Future<List<AppProvider>> listAllCraftsmen({String? q}) async {
    final all = <AppProvider>[];
    var page = 1;
    while (true) {
      final result = await listProviders(
        q: q,
        type: AppProviderType.craftsman,
        page: page,
        perPage: 50,
      );
      all.addAll(result.items);
      if (!result.hasMore) break;
      page++;
    }
    return all;
  }
}
