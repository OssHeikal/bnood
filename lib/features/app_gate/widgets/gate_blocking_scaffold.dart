import 'package:flutter/material.dart';
import '../../../core/brand/app_brand_lockup.dart';
import '../../../core/config/extensions/num_extensions.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../core/config/theme/app_size.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../home/home_foundation_scope.dart';

class GateBlockingScaffold extends StatelessWidget {
  const GateBlockingScaffold({
    super.key,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.primaryLoading = false,
  });

  final String title;
  final String message;
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final bool primaryLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    return HomeFoundationScope(
      child: Scaffold(
        backgroundColor: colors.canvas,
        appBar: CustomAppBar(title: title),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSize.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSize.spaceMD),
                Center(
                  child: AppBrandLockup(
                    kind: AppBrandLockupKind.vertical,
                    height: 120,
                  ),
                ),
                AppSize.space2XL.gap,
                Text(message, style: text.body, textAlign: TextAlign.start),
                const Spacer(),
                AppButton.primary(
                  text: primaryLabel,
                  isLoading: primaryLoading,
                  onPressed: primaryLoading ? null : onPrimary,
                ),
                if (secondaryLabel != null && onSecondary != null) ...[
                  AppSize.spaceSM.gap,
                  AppButton.text(
                    text: secondaryLabel!,
                    foregroundColor: colors.primary,
                    onPressed: primaryLoading ? null : onSecondary,
                  ),
                ],
                SizedBox(height: AppSize.spaceMD + MediaQuery.paddingOf(context).bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
