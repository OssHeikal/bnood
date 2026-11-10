import 'package:bnood/core/app_gate/app_config_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveEffectiveStatus', () {
    test('maintenance flag wins over api ok', () {
      expect(
        AppConfigData.resolveEffectiveStatus(maintenanceEnabled: true, apiStatus: 'ok'),
        AppGateStatus.maintenance,
      );
    });

    test('api maintenance when flag off', () {
      expect(
        AppConfigData.resolveEffectiveStatus(maintenanceEnabled: false, apiStatus: 'maintenance'),
        AppGateStatus.maintenance,
      );
    });

    test('priority force over optional', () {
      expect(
        AppConfigData.resolveEffectiveStatus(maintenanceEnabled: false, apiStatus: 'force_update'),
        AppGateStatus.forceUpdate,
      );
      expect(
        AppConfigData.resolveEffectiveStatus(maintenanceEnabled: false, apiStatus: 'optional_update'),
        AppGateStatus.optionalUpdate,
      );
    });
  });

  group('compareSemanticVersions', () {
    test('orders numeric segments', () {
      expect(compareSemanticVersions('1.0.0', '1.0.1'), lessThan(0));
      expect(compareSemanticVersions('2.0.0', '1.9.9'), greaterThan(0));
      expect(compareSemanticVersions('1.2.3', '1.2.3'), 0);
    });

    test('ignores build metadata', () {
      expect(compareSemanticVersions('1.0.0+4', '1.0.0+99'), 0);
    });
  });
}
