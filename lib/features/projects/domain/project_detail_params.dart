/// Stable key for project detail (ledger) providers and routes.
typedef ProjectDetailParams = ({String clientId, String projectId});

String projectDetailProviderKey(ProjectDetailParams params) =>
    '${params.clientId}:${params.projectId}';

ProjectDetailParams projectDetailParamsForClientRecord({
  required String clientId,
  required String projectId,
}) {
  return (clientId: clientId, projectId: projectId);
}