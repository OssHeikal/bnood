import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/config/theme/app_colors.dart';
import '../../../../core/services/config/theme/app_size.dart';
import '../../../../core/ui/widgets/app_modal_sheet.dart';
import '../../../../core/ui/widgets/bounded_sheet_navigator.dart';
import '../../../../core/ui/widgets/sheet_drag_handle.dart';
import 'package:bnood/features/settings/presentation/widgets/app_menu_body.dart';

Future<void> showAppSettingsSheet(BuildContext context) {
  return AppModalSheet.show<void>(
    context: context,
    body: const AppSettingsSheet(),
  );
}

class AppSettingsSheet extends ConsumerWidget {
  const AppSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final colors = brightness == Brightness.dark
        ? AppColors.dark
        : AppColors.light;
    final text = AppText.fromColors(colors);
    final maxHeight = SheetContentBounds.viewportCap(MediaQuery.of(context));

    return Theme(
      data: Theme.of(context).copyWith(extensions: [colors, text]),
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
              AppMenuBody(),
              SizedBox(height: AppSize.spaceLG),
            ],
          ),
        ),
      ),
    );
  }
}
