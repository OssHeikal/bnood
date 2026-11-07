import 'package:flutter/material.dart';

import '../config/theme/app_colors.dart';
import '../formatting/display_digits.dart';
import '../utils/extensions/bidi_isolate.dart';

/// Foundation screen app bar title (w500); optional subtitle for supporting lines.
class FoundationAppBarTitle extends StatelessWidget {
  const FoundationAppBarTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.subtitleLtr = false,
  });

  final String title;
  final String? subtitle;
  /// When true, subtitle **glyph order** stays LTR (phones, IDs) via [LtrIsolate].
  /// Layout still follows locale logical start (same edge as [title]); do not set
  /// [Text.textDirection] to LTR on the whole line.
  final bool subtitleLtr;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final colors = context.colors;
    final sub = subtitle?.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: text.appBarTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (sub != null && sub.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            subtitleLtr ? LtrIsolate.isolate(DisplayDigits.toWesternDigits(sub)) : sub,
            style: text.caption.copyWith(color: colors.onSurfaceMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}
