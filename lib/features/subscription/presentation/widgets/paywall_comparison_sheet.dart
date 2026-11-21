import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../core/config/theme/app_size.dart';
import 'package:bnood/features/subscription/data/paywall_v3_models.dart';
import '../../../../core/widgets/app_modal_sheet.dart';
import '../../../../core/widgets/sheet_drag_handle.dart';
import 'package:bnood/features/subscription/presentation/widgets/paywall_theme.dart';
import 'package:bnood/features/subscription/presentation/widgets/paywall_comparison_table.dart';

class PaywallComparisonSheet {
  const PaywallComparisonSheet._();

  static Future<void> show(
    BuildContext context, {
    required AppPaywallComparisonTable table,
    required String selectedPackageSlug,
  }) {
    final l10n = AppLocalizations.of(context);
    final theme = PaywallTheme.of(context);
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return AppModalSheet.show<void>(
      context: context,
      scrollable: true,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSize.spaceSM),
          const SheetDragHandle(),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSize.screenPadding,
              AppSize.spaceMD,
              AppSize.screenPadding,
              AppSize.spaceMD,
            ),
            child: Text(
              l10n.paywallComparePlans,
              style: theme.headline.copyWith(fontSize: 18, height: 1.25),
              textAlign: TextAlign.start,
            ),
          ),
          PaywallComparisonTable(
            table: table,
            selectedPackageSlug: selectedPackageSlug,
            comfortableSheetLayout: true,
          ),
          SizedBox(height: AppSize.spaceLG + bottomPad),
        ],
      ),
    );
  }
}
