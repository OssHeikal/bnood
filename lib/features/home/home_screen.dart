import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/providers/dashboard_providers.dart';
import '../../core/resources/gen/assets.gen.dart';
import '../../core/widgets/app_amount.dart';
import '../../core/widgets/app_fallback.dart';
import '../../core/widgets/app_pressable.dart';
import '../../app/widgets/shell_nav_icon.dart';
import '../settings/app_settings_sheet.dart';
import 'home_foundation_scope.dart';
import '../../core/widgets/app_card.dart';
import 'widgets/home_person_card.dart';
import '../../core/widgets/skeleton/async_value_body.dart';
import 'widgets/home_loading_skeleton.dart';
import 'widgets/home_section_header.dart';
import 'widgets/home_stat_grid.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;

    return HomeFoundationScope(
      child: Builder(
        builder: (context) {
          final colors = context.colors;
          final text = context.text;
          final totals = ref.watch(homeTotalsProvider);
          final clients = ref.watch(homeClientBalancesProvider);
          final suppliers = ref.watch(homeSupplierSpendsProvider);

          final topInset = MediaQuery.paddingOf(context).top;

          return Scaffold(
            backgroundColor: colors.canvas,
            body: ListView(
              padding: EdgeInsets.fromLTRB(
                AppSize.screenPadding,
                topInset + AppSize.spaceMD,
                AppSize.screenPadding,
                AppSize.spaceMD,
              ),
              children: [
                _HomeTopBar(
                  title: l10n.appTitle,
                  subtitle: l10n.homeSubtitle,
                  onSettings: () => showAppSettingsSheet(context),
                ),
                AppSize.spaceMD.gap,
                Text(l10n.homeTotalsCaption, style: text.caption.copyWith(color: colors.onSurfaceMuted)),
                AppSize.spaceMD.gap,
                AsyncValueBody(
                  value: totals,
                  loadingPlaceholder: const HomeStatGridSkeleton(),
                  error: (e, _) => AppFallback(
                    isError: true,
                    icon: Icons.error_outline,
                    title: l10n.homeLoadErrorTitle,
                    description: e.toString(),
                    actionLabel: l10n.retry,
                    onAction: () => ref.read(homeTotalsProvider.notifier).refreshSilently(),
                  ),
                  data: (t) => HomeStatGrid(totals: t, localeCode: localeCode),
                ),
                AppSize.spaceXL.gap,
                HomeSectionHeader(
                  title: l10n.activeClients,
                  seeAllLabel: l10n.seeAll,
                  onSeeAll: () => context.go('/clients'),
                ),
                AppSize.spaceSM.gap,
                AsyncValueBody(
                  value: clients,
                  loadingPlaceholder: const HomePersonListSkeleton(),
                  error: (e, _) => AppFallback(
                    isError: true,
                    icon: Icons.error_outline,
                    title: l10n.homeLoadErrorTitle,
                    description: e.toString(),
                    actionLabel: l10n.retry,
                    onAction: () => ref.read(homeClientBalancesProvider.notifier).refreshSilently(),
                  ),
                  data: (rows) {
                    if (rows.isEmpty) {
                      return AppCard(
                        child: AppFallback.section(
                          icon: Icons.people_outline,
                          title: l10n.homeNoActiveClientsTitle,
                          description: l10n.homeNoActiveClientsDescription,
                          actions: [
                            AppFallbackAction(
                              label: l10n.seeAll,
                              onPressed: () => context.go('/clients'),
                              role: AppFallbackActionRole.tertiary,
                            ),
                          ],
                        ),
                      );
                    }
                    return Column(
                      children: [
                        for (var i = 0; i < rows.length; i++) ...[
                          if (i > 0) AppSize.spaceMD.gap,
                          HomePersonCard(
                            name: rows[i].client.name,
                            receivedPiastres: rows[i].receivedPiastres,
                            spentPiastres: rows[i].spentPiastres,
                            amountPiastres: rows[i].remainingPiastres,
                            accentKey: homeAccentKeyFor(rows[i].client.id),
                            localeCode: localeCode,
                            onTap: () => context.push('/clients/${rows[i].client.id}'),
                          ),
                        ],
                      ],
                    );
                  },
                ),
                AppSize.spaceXL.gap,
                HomeSectionHeader(
                  title: l10n.homeSupplierSpendSection,
                  seeAllLabel: l10n.seeAll,
                  onSeeAll: () => context.go('/directory'),
                ),
                AppSize.spaceSM.gap,
                AsyncValueBody(
                  value: suppliers,
                  loadingPlaceholder: const HomePersonListSkeleton(count: 1),
                  error: (e, _) => AppFallback(
                    isError: true,
                    icon: Icons.error_outline,
                    title: l10n.homeLoadErrorTitle,
                    actionLabel: l10n.retry,
                    onAction: () => ref.read(homeSupplierSpendsProvider.notifier).refreshSilently(),
                  ),
                  data: (rows) {
                    if (rows.isEmpty) {
                      final colors = context.colors;
                      return AppCard(
                        child: AppFallback.section(
                          leading: ShellNavIcon(
                            asset: Assets.icons.materialsPackageOutline,
                            color: colors.muted,
                            size: AppSize.icon,
                          ),
                          title: l10n.homeNoSupplierSpendTitle,
                          description: l10n.homeNoSupplierSpendDescription,
                        ),
                      );
                    }
                    return Column(
                      children: [
                        for (var i = 0; i < rows.length; i++) ...[
                          if (i > 0) AppSize.spaceMD.gap,
                          HomePersonCard(
                            name: rows[i].supplier.name,
                            meta: l10n.homeSupplierSpendMeta,
                            amountPiastres: rows[i].spentPiastres,
                            amountRole: AppAmountRole.spend,
                            accentKey: homeAccentKeyFor(rows[i].supplier.id),
                            localeCode: localeCode,
                            onTap: () => context.push('/suppliers/${rows[i].supplier.id}'),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HomeTopBar extends StatelessWidget {
  const _HomeTopBar({required this.title, required this.subtitle, required this.onSettings});

  final String title;
  final String subtitle;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: text.pageTitle),
              const SizedBox(height: 2),
              Text(subtitle, style: text.supporting.copyWith(color: colors.onSurfaceMuted)),
            ],
          ),
        ),
        AppPressable(
          onPressed: onSettings,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppSize.radiusSM),
              boxShadow: [colors.buttonShadow],
            ),
            child: SizedBox(
              width: AppSize.hitMin,
              height: AppSize.hitMin,
              child: Center(
                child: ShellNavIcon(asset: Assets.icons.settingsOutline, color: colors.onSurface),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
