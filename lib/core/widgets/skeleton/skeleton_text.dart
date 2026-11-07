import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import 'skeleton_box.dart';

enum SkeletonTextRole { supporting, body, label, title, titleLarge }

class SkeletonText extends StatelessWidget {
  const SkeletonText({
    super.key,
    this.role = SkeletonTextRole.body,
    this.width,
    this.onPage = false,
  });

  static const double boneShare = 0.66;

  final SkeletonTextRole role;
  final double? width;
  final bool onPage;

  TextStyle _style(AppText text) {
    return switch (role) {
      SkeletonTextRole.supporting => text.supporting,
      SkeletonTextRole.body => text.body,
      SkeletonTextRole.label => text.label,
      SkeletonTextRole.title => text.title,
      SkeletonTextRole.titleLarge => text.titleLarge,
    };
  }

  @override
  Widget build(BuildContext context) {
    final style = _style(context.text);
    final fontSize = style.fontSize ?? 14;
    final lineHeightFactor = style.height ?? 1.22;
    final scaledSize = MediaQuery.textScalerOf(context).scale(fontSize);
    final lineHeight = scaledSize * lineHeightFactor;
    return SizedBox(
      width: width,
      height: lineHeight,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: SkeletonBox.pill(
          height: scaledSize * boneShare,
          width: width,
          onPage: onPage,
        ),
      ),
    );
  }
}
