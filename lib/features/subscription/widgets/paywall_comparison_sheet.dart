import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../core/config/theme/app_size.dart';
import '../../../core/subscription/paywall_v3_models.dart';
import '../../../core/widgets/custom_bottom_sheet.dart';
import 'paywall_comparison_table.dart';

class PaywallComparisonSheet {
  const PaywallComparisonSheet._();

  static Future<void> show(
    BuildContext context, {
    required AppPaywallComparisonTable table,
    required String selectedPackageSlug,
  }) {
    final l10n = AppLocalizations.of(context);
    return CustomBottomSheet.show<void>(
      context: context,
      title: l10n.paywallComparePlans,
      nestedNavigator: false,
      builder: (_) => SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSize.screenPadding,
          0,
          AppSize.screenPadding,
          AppSize.spaceLG,
        ),
        child: PaywallComparisonTable(
          table: table,
          selectedPackageSlug: selectedPackageSlug,
        ),
      ),
    );
  }
}