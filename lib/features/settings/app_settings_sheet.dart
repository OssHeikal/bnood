import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/widgets/bnood_modal_sheet.dart';
import '../../core/widgets/bounded_sheet_navigator.dart';
import '../../core/widgets/sheet_drag_handle.dart';
import 'app_settings_body.dart';

Future<void> showAppSettingsSheet(BuildContext context) {
  return BnoodModalSheet.show<void>(
    context: context,
    builder: (_) => const AppSettingsSheet(),
  );
}

class AppSettingsSheet extends ConsumerWidget {
  const AppSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final colors = brightness == Brightness.dark ? AppColors.dark : AppColors.light;
    final text = AppText.fromColors(colors);
    final bottom = MediaQuery.viewPaddingOf(context).bottom;
    final maxHeight = SheetContentBounds.viewportCap(MediaQuery.of(context));

    return Theme(
      data: Theme.of(context).copyWith(extensions: [colors, text]),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottom),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: const SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: AppSize.spaceMD),
                  SheetDragHandle(),
                  SizedBox(height: AppSize.spaceLG),
                  AppSettingsBody(),
                  SizedBox(height: AppSize.spaceLG),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
