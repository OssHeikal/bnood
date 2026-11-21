import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'statement share analytics fires once per export generation (retry share)',
    () {
      var exportGeneration = 0;
      int? statementShareTrackedGeneration;
      var fires = 0;

      void onShareSheetClosed() {
        if (statementShareTrackedGeneration == exportGeneration) return;
        statementShareTrackedGeneration = exportGeneration;
        fires++;
      }

      exportGeneration++;
      onShareSheetClosed();
      onShareSheetClosed();
      expect(fires, 1);

      exportGeneration++;
      onShareSheetClosed();
      expect(fires, 2);
    },
  );
}
