import '../api/home_api.dart';
import 'app_home_dashboard.dart';
import 'app_home_totals.dart';

class HomeRepository {
  HomeRepository(this._api);

  final HomeApi _api;
  AppHomeDashboard? _cachedDashboard;
  Future<AppHomeDashboard>? _inFlight;

  void invalidateDashboard() {
    _cachedDashboard = null;
    _inFlight = null;
  }

  Future<AppHomeDashboard> getHomeDashboard() {
    final cached = _cachedDashboard;
    if (cached != null) return Future.value(cached);
    final inFlight = _inFlight;
    if (inFlight != null) return inFlight;
    final future = _api.getHomeDashboard().then((dashboard) {
      _cachedDashboard = dashboard;
      _inFlight = null;
      return dashboard;
    });
    _inFlight = future;
    return future;
  }

  Future<AppHomeTotals> getHomeTotals() async => (await getHomeDashboard()).totals;
}
