import 'package:bnood/core/api/app_config_api.dart';
import 'package:bnood/core/app_gate/app_config_record.dart';

class StubAppConfigApi extends AppConfigApi {
  StubAppConfigApi(this._handler) : super();

  final Future<AppConfigData> Function({
    required String platform,
    required String version,
    required String locale,
  }) _handler;

  @override
  Future<AppConfigData> fetchConfig({
    required String platform,
    required String version,
    required String locale,
  }) =>
      _handler(platform: platform, version: version, locale: locale);
}
