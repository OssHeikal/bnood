import 'package:flutter/material.dart';

import 'bnood_layout.dart';

/// Centers child and caps width; on phone only applies [padding] (no max width cap).
class BnoodMaxWidth extends StatelessWidget {
  const BnoodMaxWidth({
    super.key,
    required this.child,
    this.maxWidth = BnoodLayout.pageMaxWidth,
    this.padding,
    this.alignment = AlignmentDirectional.topCenter,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsDirectional? padding;
  final AlignmentDirectional alignment;

  @override
  Widget build(BuildContext context) {
    final pad = padding ?? context.pagePadding;
    Widget content = child;
    if (!context.isBnoodMobile) {
      content = Align(
        alignment: alignment,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: content,
        ),
      );
    }
    if (pad == EdgeInsetsDirectional.zero) {
      return content;
    }
    return Padding(padding: pad, child: content);
  }
}
