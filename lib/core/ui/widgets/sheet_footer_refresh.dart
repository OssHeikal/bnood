import 'package:flutter/foundation.dart';

/// Notifies the [AppModalSheet] footer slot to rebuild when form state changes.
class SheetFooterRefresh extends ChangeNotifier {
  void bump() => notifyListeners();
}
