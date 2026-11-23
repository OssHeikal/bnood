import 'package:bnood/features/clients/data/client_api_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ClientApiRecord parses office-scoped ClientResource show payload', () {
    const clientId = '01JCLIENTSHOW';
    const projectId = '01JPROJECTALPHA';
    final record = ClientApiRecord.fromDataJson({
      'id': clientId,
      'name': 'Office Client',
      'phone': '+201012345678',
      'archived_at': null,
      'created_at': '2025-01-01T00:00:00Z',
      'updated_at': '2025-01-02T00:00:00Z',
      'project': {
        'id': projectId,
        'name': 'Main Site',
        'status': 'active',
        'engineer_basis_points': 500,
      },
      'balances': {
        'received': 1000,
        'spent': 400,
        'remaining': 600,
      },
      'craftsmen_count': 2,
      'suppliers_count': 1,
    });

    expect(record.client.id, clientId);
    expect(record.client.name, 'Office Client');
    expect(record.project.id, projectId);
    expect(record.project.name, 'Main Site');
    expect(record.balances?.receivedPiastres, 1000);
    expect(record.balances?.spentPiastres, 400);
    expect(record.balances?.remainingPiastres, 600);
    expect(record.craftsmenCount, 2);
    expect(record.suppliersCount, 1);
  });

  test('ClientApiRecord selects project from projects list when project absent', () {
    const clientId = '01JCLIENTMULTI';
    const secondaryProjectId = '01JPROJECTB';
    final record = ClientApiRecord.fromDataJson({
      'id': clientId,
      'name': 'Multi',
      'phone': null,
      'archived_at': null,
      'created_at': '2025-01-01T00:00:00Z',
      'updated_at': '2025-01-02T00:00:00Z',
      'projects': [
        {
          'id': secondaryProjectId,
          'name': 'Tower B',
          'status': 'active',
        },
      ],
    });

    expect(record.project.id, secondaryProjectId);
    expect(record.project.name, 'Tower B');
  });
}