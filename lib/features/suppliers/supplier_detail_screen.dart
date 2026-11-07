import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/resources/gen/assets.gen.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_fallback.dart';
import '../../core/widgets/foundation_app_bar_title.dart';
import '../../core/widgets/skeleton/async_value_body.dart';
import '../../app/widgets/shell_nav_icon.dart';
import '../home/home_foundation_scope.dart';
import 'supplier_detail_provider.dart';
import 'supplier_detail_snapshot.dart';
import 'widgets/supplier_detail_history_section.dart';
import 'widgets/supplier_detail_loading_skeleton.dart';
import 'widgets/supplier_detail_profile.dart';
import 'widgets/supplier_detail_spend_stat.dart';

class SupplierDetailScreen extends ConsumerWidget {
  const SupplierDetailScreen({super.key, required this.supplierId});

  final String supplierId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final detail = ref.watch(supplierDetailProvider(supplierId));
    final supplier = detail.valueOrNull?.supplier;
    final supplierName = supplier?.name;
    final phone = supplier?.phone?.trim();
    final hasPhone = phone != null && phone.isNotEmpty;

    return HomeFoundationScope(
      child: Builder(
        builder: (context) {
          final colors = context.colors;
          return Scaffold(
            backgroundColor: colors.canvas,
            appBar: AppBar(
              backgroundColor: colors.canvas,
              surfaceTintColor: Colors.transparent,
              scrolledUnderElevation: 0,
              elevation: 0,
              centerTitle: false,
              title: FoundationAppBarTitle(
                title: supplierName ?? l10n.suppliers,
                subtitle: hasPhone ? phone : null,
                subtitleLtr: true,
              ),
              actions: [
                if (detail.valueOrNull != null)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: AppSize.spaceXS),
                    child: Tooltip(
                      message: l10n.statement,
                      child: IconButton(
                        key: const Key('supplier_detail_statement'),
                        onPressed: () => context.push('/suppliers/$supplierId/statement'),
                        icon: ShellNavIcon(
                          asset: Assets.icons.documentAttachmentOutline,
                          color: colors.onSurface,
                          size: AppSize.icon,
                          semanticsLabel: l10n.statement,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            body: ListView(
              padding: EdgeInsets.fromLTRB(
                AppSize.screenPadding,
                AppSize.spaceSM,
                AppSize.screenPadding,
                AppSize.spaceMD + MediaQuery.paddingOf(context).bottom,
              ),
              children: [
                AsyncValueBody(
                  value: detail,
                  loadingPlaceholder: const SupplierDetailLoadingSkeleton(),
                  error: (error, _) {
                    if (error is SupplierDetailNotFound) {
                      return AppCard(
                        child: AppFallback.section(
                          icon: Icons.person_off_outlined,
                          title: l10n.supplierDetailNotFoundTitle,
                        ),
                      );
                    }
                    return AppCard(
                      child: AppFallback.section(
                        icon: Icons.error_outline,
                        title: l10n.homeLoadErrorTitle,
                        description: error.toString(),
                        actions: [
                          AppFallbackAction(
                            label: l10n.retry,
                            onPressed: () =>
                                ref.read(supplierDetailProvider(supplierId).notifier).refreshSilently(),
                            role: AppFallbackActionRole.tertiary,
                          ),
                        ],
                      ),
                    );
                  },
                  data: (data) => _SupplierDetailBody(data: data, localeCode: localeCode),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SupplierDetailBody extends StatelessWidget {
  const _SupplierDetailBody({
    required this.data,
    required this.localeCode,
  });

  final SupplierDetailSnapshot data;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    final profile = SupplierDetailProfile(supplier: data.supplier);
    final hasProfile = data.supplier.notes?.trim().isNotEmpty == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasProfile) ...[
          profile,
          AppSize.spaceLG.gap,
        ],
        SupplierDetailSpendStat(
          totalPaidPiastres: data.totalPaidPiastres,
          localeCode: localeCode,
        ),
        AppSize.spaceXL.gap,
        SupplierDetailHistorySection(
          history: data.history,
          localeCode: localeCode,
        ),
      ],
    );
  }
}
