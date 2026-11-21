import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';

import '../../../../core/config/extensions/num_extensions.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/config/theme/app_size.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_pressable.dart';
import '../../../../core/widgets/app_modal_sheet.dart';
import '../../../../core/widgets/sheet_drag_handle.dart';
import 'package:bnood/features/home/presentation/widgets/home_foundation_scope.dart';

enum VoucherReceiptSource { camera, gallery }

Future<VoucherReceiptSource?> showVoucherReceiptSourceSheet(
  BuildContext context,
) {
  return AppModalSheet.show<VoucherReceiptSource>(
    context: context,
    body: const HomeFoundationScope(child: VoucherReceiptSourceSheet()),
  );
}

class VoucherReceiptSourceSheet extends StatelessWidget {
  const VoucherReceiptSourceSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final text = context.text;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSize.screenPadding,
        AppSize.spaceSM,
        AppSize.screenPadding,
        0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetDragHandle(),
          AppSize.spaceMD.gap,
          Text(
            l10n.voucherAttachSourceTitle,
            style: text.title,
            textAlign: TextAlign.start,
          ),
          AppSize.spaceLG.gap,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ReceiptSourceTile(
                  icon: Icons.photo_camera_outlined,
                  label: l10n.voucherAttachCamera,
                  subtitle: l10n.voucherAttachCameraSubtitle,
                  colors: colors,
                  text: text,
                  onTap: () =>
                      Navigator.of(context).pop(VoucherReceiptSource.camera),
                ),
              ),
              AppSize.spaceMD.gap,
              Expanded(
                child: _ReceiptSourceTile(
                  icon: Icons.photo_library_outlined,
                  label: l10n.voucherAttachGallery,
                  subtitle: l10n.voucherAttachGallerySubtitle,
                  colors: colors,
                  text: text,
                  onTap: () =>
                      Navigator.of(context).pop(VoucherReceiptSource.gallery),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReceiptSourceTile extends StatelessWidget {
  const _ReceiptSourceTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.colors,
    required this.text,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final AppColors colors;
  final AppText text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: AppPressable(
        onPressed: onTap,
        child: AppCard(
          padding: const EdgeInsets.all(AppSize.spaceMD),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Container(
                  width: AppSize.hitMin,
                  height: AppSize.hitMin,
                  decoration: BoxDecoration(
                    color: colors.primaryTint,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    color: colors.primaryDark,
                    size: AppSize.icon,
                  ),
                ),
              ),
              AppSize.spaceMD.gap,
              Text(
                label,
                style: text.bodyEmphasis.copyWith(color: colors.onSurface),
                textAlign: TextAlign.start,
              ),
              AppSize.spaceXS.gap,
              Text(
                subtitle,
                style: text.caption.copyWith(color: colors.onSurfaceMuted),
                textAlign: TextAlign.start,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
