import 'package:flutter/material.dart';

import '../config/extensions/num_extensions.dart';
import '../config/theme/app_colors.dart';
import '../config/theme/app_size.dart';
import 'sheet_drag_handle.dart';

/// Drag handle + title header matching directory/provider create sheets.
class SheetFormHeader extends StatelessWidget {
  const SheetFormHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSize.screenPadding,
        AppSize.spaceSM,
        AppSize.screenPadding,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetDragHandle(),
          AppSize.spaceMD.gap,
          Text(title, style: context.text.title),
        ],
      ),
    );
  }
}

/// Drag handle only (title lives in the scroll body).
class SheetDragHeader extends StatelessWidget {
  const SheetDragHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(
        AppSize.screenPadding,
        AppSize.spaceSM,
        AppSize.screenPadding,
        0,
      ),
      child: SheetDragHandle(),
    );
  }
}