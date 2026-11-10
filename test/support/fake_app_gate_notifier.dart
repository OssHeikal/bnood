import 'package:bnood/core/app_gate/app_config_record.dart';
import 'package:bnood/features/app_gate/app_gate_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FakeAppGateNotifier extends AppGateNotifier {
  FakeAppGateNotifier(this._data);

  final AppConfigData _data;

  @override
  Future<AppConfigData> build() => Future.value(_data);

  @override
  Future<AppConfigData> fetchConfig({bool failOpen = true}) async {
    state = AsyncData(_data);
    return _data;
  }
}
