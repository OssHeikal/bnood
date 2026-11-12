import 'dart:async';

import 'package:bnood/core/providers/dashboard_providers.dart';
import 'package:bnood/core/repositories/bnood_repository.dart';
import 'package:bnood/core/shared/pagination/pagination.dart';
import 'package:bnood/features/clients/clients_list_paging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StubHomeTotalsNotifier extends HomeTotalsNotifier {
  StubHomeTotalsNotifier(this.value);

  final HomeTotals value;

  @override
  Future<HomeTotals> fetch() async => value;
}

class PendingHomeTotalsNotifier extends HomeTotalsNotifier {
  PendingHomeTotalsNotifier(this._future);

  final Future<HomeTotals> _future;

  @override
  Future<HomeTotals> fetch() => _future;
}

class SequencedHomeTotalsNotifier extends HomeTotalsNotifier {
  SequencedHomeTotalsNotifier(this._values);

  final List<HomeTotals> _values;
  var _index = 0;

  @override
  Future<HomeTotals> fetch() async {
    final value = _values[_index.clamp(0, _values.length - 1)];
    if (_index < _values.length - 1) {
      _index++;
    }
    return value;
  }
}

class ThrowingHomeTotalsNotifier extends HomeTotalsNotifier {
  ThrowingHomeTotalsNotifier({required this.first, required this.failNext});

  final HomeTotals first;
  final bool failNext;
  var _calls = 0;

  @override
  Future<HomeTotals> fetch() async {
    _calls++;
    if (_calls == 1) return first;
    if (failNext) throw Exception('refresh failed');
    return first;
  }
}

class StubHomeClientBalancesNotifier extends HomeClientBalancesNotifier {
  StubHomeClientBalancesNotifier(this.rows);

  final List<HomeClientBalanceRow> rows;

  @override
  Future<List<HomeClientBalanceRow>> fetch() async => rows;
}

class StubHomeSupplierSpendsNotifier extends HomeSupplierSpendsNotifier {
  StubHomeSupplierSpendsNotifier(this.rows);

  final List<HomeSupplierSpendRow> rows;

  @override
  Future<List<HomeSupplierSpendRow>> fetch() async => rows;
}

Override homeTotalsOverride(HomeTotals totals) =>
    homeTotalsProvider.overrideWith(() => StubHomeTotalsNotifier(totals));

Override homeClientBalancesOverride(List<HomeClientBalanceRow> rows) =>
    homeClientBalancesProvider.overrideWith(() => StubHomeClientBalancesNotifier(rows));

class StubClientsListNotifier extends ClientsListNotifier {
  StubClientsListNotifier(this.rows);

  final List<HomeClientBalanceRow> rows;

  @override
  Future<ClientsListSnapshot> fetch() async => ClientsListSnapshot(
        rows: rows,
        page: 1,
        total: rows.length,
        hasMore: false,
      );
}

Override clientsListBalancesOverride(List<HomeClientBalanceRow> rows) => clientsListPageFetcherProvider.overrideWith(
      (ref) => ({required int page, required int pageSize}) async {
        if (page > 1) return const PagedFetchPage(items: [], hasMore: false);
        return PagedFetchPage(items: rows, hasMore: false);
      },
    );

Override homeSupplierSpendsOverride(List<HomeSupplierSpendRow> rows) =>
    homeSupplierSpendsProvider.overrideWith(() => StubHomeSupplierSpendsNotifier(rows));

Override emptyHomeSupplierSpendsOverride() => homeSupplierSpendsOverride(const []);

class StubHomeCraftsmenNotifier extends HomeCraftsmenNotifier {
  StubHomeCraftsmenNotifier(this.rows);

  final List<HomeCraftsmanActivityRow> rows;

  @override
  Future<List<HomeCraftsmanActivityRow>> fetch() async => rows;
}

Override emptyHomeCraftsmenOverride() =>
    homeCraftsmenProvider.overrideWith(() => StubHomeCraftsmenNotifier(const []));

Override homeCraftsmenOverride(List<HomeCraftsmanActivityRow> rows) =>
    homeCraftsmenProvider.overrideWith(() => StubHomeCraftsmenNotifier(rows));

class StubHomeSuppliersNotifier extends HomeSuppliersNotifier {
  StubHomeSuppliersNotifier(this.rows);

  final List<HomeCraftsmanActivityRow> rows;

  @override
  Future<List<HomeCraftsmanActivityRow>> fetch() async => rows;
}

Override emptyHomeSuppliersOverride() =>
    homeSuppliersProvider.overrideWith(() => StubHomeSuppliersNotifier(const []));

