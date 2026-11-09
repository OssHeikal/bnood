import '../api/clients_api.dart';
import '../repositories/bnood_repository.dart';
import 'client_api_record.dart';
import 'client_statement_pdf.dart';
import 'client_statement_record.dart';

class ClientsRepository {
  ClientsRepository(this._api);

  final ClientsApi _api;

  Future<ClientsListPage> listClients({
    required ClientListArchiveFilter status,
    String? q,
    int page = 1,
    int perPage = 50,
  }) =>
      _api.listClients(status: status, q: q, page: page, perPage: perPage);

  Future<ClientApiRecord> getClient(String id) => _api.getClient(id);

  Future<ClientApiRecord> createClient({
    required String name,
    String? phone,
    int? engineerBasisPoints,
    bool confirmDuplicateName = false,
  }) =>
      _api.createClient(
        name: name,
        phone: phone,
        engineerBasisPoints: engineerBasisPoints,
        confirmDuplicateName: confirmDuplicateName,
      );

  Future<ClientApiRecord> updateClient({
    required String id,
    String? name,
    String? phone,
    int? engineerBasisPoints,
    bool confirmDuplicateName = false,
    bool clearPhone = false,
    bool clearEngineerBasisPoints = false,
  }) =>
      _api.updateClient(
        id: id,
        name: name,
        phone: phone,
        engineerBasisPoints: engineerBasisPoints,
        confirmDuplicateName: confirmDuplicateName,
        clearPhone: clearPhone,
        clearEngineerBasisPoints: clearEngineerBasisPoints,
      );

  Future<ClientApiRecord> archiveClient(String id) => _api.archiveClient(id);

  Future<void> deleteClient(String id) => _api.deleteClient(id);

  Future<AppClientStatement> getClientStatement({
    required String clientId,
    required String from,
    required String to,
  }) =>
      _api.getClientStatement(clientId: clientId, from: from, to: to);

  Future<AppClientItemSpend> getClientItemSpend(String clientId) =>
      _api.getClientItemSpend(clientId);

  Future<ClientStatementPdf> downloadClientStatementPdf({
    required String clientId,
    required String from,
    required String to,
  }) =>
      _api.downloadClientStatementPdf(clientId: clientId, from: from, to: to);
}

HomeClientBalanceRow balanceRowFromRecord(ClientApiRecord record) {
  final balances = record.balances;
  return HomeClientBalanceRow(
    client: record.client,
    project: record.project,
    remainingPiastres: balances?.remainingPiastres,
    receivedPiastres: balances?.receivedPiastres,
    spentPiastres: balances?.spentPiastres,
  );
}
