import 'package:flutter/widgets.dart';

extension NumGap on num {
  SizedBox get gap => SizedBox(width: toDouble(), height: toDouble());
}
