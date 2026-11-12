import 'package:bnood/core/api/providers_api.dart';
import 'package:bnood/core/database/connection.dart';
import 'package:bnood/core/providers/app_providers.dart';
import 'package:bnood/core/providers_api/app_provider_record.dart';
import 'package:bnood/core/providers_api/providers_repository.dart';
import 'package:bnood/core/providers_api/providers_riverpod.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:bnood/features/vouchers/voucher_picker_resolution.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubProvidersRepository extends ProvidersRepository {
  _StubProvidersRepository(this._byId) : super(ProvidersApi());

  final Map<String, AppProvider> _byId;

  @override
  Future<AppProvider> getProvider(String id) async {
    final provider = _byId[id];
    if (provider == null) throw StateError('missing');
    return provider;
  }
}

void main() {
  test('resolveRemoteProviderLabel fetches supplier missing from stale cache', () async {
    final now = DateTime.utc(2026, 11, 9);
    const createdId = 'new-supplier';
    final created = AppProvider(
      id: createdId,
      name: 'New Supplier',
      phone: null,
      type: AppProviderType.supplier,
      createdAt: now,
      updatedAt: now,
    );
    final fake = _StubProvidersRepository({createdId: created});
    final container = ProviderContainer(
      overrides: [appProvidersRepositoryProvider.overrideWithValue(fake)],
    );
    addTearDown(container.dispose);

    final label = await resolveRemoteProviderLabel(
      container.read,
      createdId,
      cached: const [],
    );
    expect(label, 'New Supplier');
  });

  test('resolveLocalSupplierLabel loads supplier created after picker opened', () async {
    final db = openTestDatabase();
    addTearDown(db.close);
    final repo = BnoodRepository(db);
    final supplier = await repo.createSupplier(name: 'After Create');
    final container = ProviderContainer(
      overrides: [repositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);

    final label = await resolveLocalSupplierLabel(
      container.read,
      supplier.id,
      cached: const [],
    );
    expect(label, 'After Create');
  });

  test('labelFromPickerEntries returns null for unknown id', () {
    expect(labelFromPickerEntries(const [('a', 'Alpha')], 'b'), isNull);
    expect(labelFromPickerEntries(const [('a', 'Alpha')], 'a'), 'Alpha');
  });
}
