import '../api/agreements_api.dart';
import 'app_agreement_record.dart';

class AgreementsRepository {
  AgreementsRepository(this._api);

  final AgreementsApi _api;

  Future<AgreementsListPage> listClientAgreements({
    required String clientId,
    int page = 1,
    int perPage = 50,
  }) =>
      _api.listClientAgreements(clientId: clientId, page: page, perPage: perPage);

  Future<AgreementsListPage> listProviderAgreements({
    required String providerId,
    int page = 1,
    int perPage = 50,
  }) =>
      _api.listProviderAgreements(providerId: providerId, page: page, perPage: perPage);

  Future<List<AppAgreement>> listAllClientAgreements(String clientId) =>
      _listAll((page) => listClientAgreements(clientId: clientId, page: page));

  Future<List<AppAgreement>> listAllProviderAgreements(String providerId) =>
      _listAll((page) => listProviderAgreements(providerId: providerId, page: page));

  Future<AppAgreement> getAgreement(String id) => _api.getAgreement(id);

  Future<AppAgreement> createAgreement({
    required String clientId,
    required String providerId,
    int? amountPiastres,
    bool omitAmount = false,
  }) =>
      _api.createAgreement(
        clientId: clientId,
        providerId: providerId,
        amountPiastres: amountPiastres,
        omitAmount: omitAmount,
      );

  Future<AppAgreement> patchAgreement({
    required String id,
    required int? amountPiastres,
  }) =>
      _api.patchAgreement(id: id, amountPiastres: amountPiastres);

  Future<void> deleteAgreement(String id) => _api.deleteAgreement(id);

  Future<List<AppAgreement>> _listAll(
    Future<AgreementsListPage> Function(int page) fetch,
  ) async {
    final all = <AppAgreement>[];
    var page = 1;
    while (true) {
      final result = await fetch(page);
      all.addAll(result.items);
      if (!result.hasMore) break;
      page++;
    }
    return all;
  }
}
