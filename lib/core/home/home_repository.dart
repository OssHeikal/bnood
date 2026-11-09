import '../api/home_api.dart';
import 'app_home_totals.dart';

class HomeRepository {
  HomeRepository(this._api);

  final HomeApi _api;

  Future<AppHomeTotals> getHomeTotals() => _api.getHomeTotals();
}
