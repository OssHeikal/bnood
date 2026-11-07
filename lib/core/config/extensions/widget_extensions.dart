import 'package:flutter/widgets.dart';

extension WidgetInsets on Widget {
  Widget paddingAll(double value) {
    return Padding(padding: EdgeInsets.all(value), child: this);
  }

  Widget paddingSymmetric({double vertical = 0, double horizontal = 0}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: vertical, horizontal: horizontal),
      child: this,
    );
  }

  Widget paddingVertical(double value) => paddingSymmetric(vertical: value);

  Widget paddingHorizontal(double value) => paddingSymmetric(horizontal: value);

  Widget paddingTop(double value) {
    return Padding(padding: EdgeInsets.only(top: value), child: this);
  }

  Widget paddingBottom(double value) {
    return Padding(padding: EdgeInsets.only(bottom: value), child: this);
  }

  Widget paddingStart(double value) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: value),
      child: this,
    );
  }

  Widget paddingEnd(double value) {
    return Padding(
      padding: EdgeInsetsDirectional.only(end: value),
      child: this,
    );
  }

  Widget paddingDirectionalOnly({
    double start = 0,
    double top = 0,
    double end = 0,
    double bottom = 0,
  }) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: start,
        top: top,
        end: end,
        bottom: bottom,
      ),
      child: this,
    );
  }

  Widget setHero(String tag) => Hero(tag: tag, child: this);
}
