import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_shape.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/providers/app_providers.dart';
import '../../core/resources/gen/assets.gen.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_fallback.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/app_decision.dart';
import '../../core/widgets/custom_bottom_sheet.dart';
import '../../core/widgets/toast/app_tone.dart';
import '../../core/widgets/skeleton/async_value_body.dart';
import '../../app/widgets/shell_nav_icon.dart';
import '../home/home_foundation_scope.dart';
import 'widgets/directory_list_loading_skeleton.dart';
import '../vouchers/inline_create_routes.dart';
import 'directory_providers.dart';
import 'widgets/directory_person_card.dart';

class DirectoryScreen extends ConsumerStatefulWidget {
  const DirectoryScreen({super.key, this.initialTabIndex = 0});

  final int initialTabIndex;

  @override
  ConsumerState<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends ConsumerState<DirectoryScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTabIndex.clamp(0, 1));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _addSupplier(BuildContext context) async {
    await CustomBottomSheet.show<String?>(
      context: context,
      builder: (_) => const InlineCreateSupplierPage(padForSystemChrome: false),
      nestedNavigator: false,
      showDragHandle: false,
    );
  }

  Future<void> _addCraftsman(BuildContext context) async {
    await CustomBottomSheet.show<String?>(
      context: context,
      builder: (_) => const InlineCreateCraftsmanPage(padForSystemChrome: false),
      nestedNavigator: false,
      showDragHandle: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;

    return HomeFoundationScope(
      child: Builder(
        builder: (context) {
          final colors = context.colors;
          final text = context.text;
          return Scaffold(
            backgroundColor: colors.canvas,
            appBar: CustomAppBar(
              title: l10n.directoryTitle,
              actions: [
                ListenableBuilder(
                  listenable: _tabController,
                  builder: (context, _) {
                    final suppliersTab = _tabController.index == 0;
                    final label = suppliersTab ? l10n.directoryAddSupplier : l10n.directoryAddCraftsman;
                    return CustomAppBarAction(
                      key: Key(suppliersTab ? 'directory_add_supplier' : 'directory_add_craftsman'),
                      tooltip: label,
                      tone: CustomAppBarActionTone.tint,
                      onPressed: () => suppliersTab ? _addSupplier(context) : _addCraftsman(context),
                      child: ShellNavIcon(
                        asset: Assets.icons.addOutline,
                        color: colors.primaryOnTint,
                        size: AppSize.icon,
                        semanticsLabel: label,
                      ),
                    );
                  },
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(96),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSize.screenPadding,
                        0,
                        AppSize.screenPadding,
                        AppSize.spaceSM,
                      ),
                      child: _DirectorySegmentedTabs(controller: _tabController),
                    ),
                    ListenableBuilder(
                      listenable: _tabController,
                      builder: (context, _) {
                        final hint = _tabController.index == 0
                            ? l10n.directorySuppliersHint
                            : l10n.directoryCraftsmenHint;
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSize.screenPadding,
                            0,
                            AppSize.screenPadding,
                            AppSize.spaceMD,
                          ),
                          child: Text(hint, style: text.caption.copyWith(color: colors.onSurfaceMuted)),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                _DirectorySupplierTab(localeCode: localeCode),
                _DirectoryCraftsmenTab(localeCode: localeCode),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DirectorySegmentedTabs extends StatelessWidget {
  const _DirectorySegmentedTabs({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final text = context.text;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Row(
          children: [
            Expanded(
              child: _TabChip(
                key: const Key('directory_tab_suppliers'),
                label: l10n.suppliers,
                selected: controller.index == 0,
                onTap: () => controller.animateTo(0, duration: Duration.zero),
                colors: colors,
                text: text,
              ),
            ),
            AppSize.spaceSM.gap,
            Expanded(
              child: _TabChip(
                key: const Key('directory_tab_craftsmen'),
                label: l10n.craftsmen,
                selected: controller.index == 1,
                onTap: () => controller.animateTo(1, duration: Duration.zero),
                colors: colors,
                text: text,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.colors,
    required this.text,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final AppColors colors;
  final AppText text;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? colors.primary : colors.surface,
      shape: AppShape.superellipse(radius: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 40,
          child: Center(
            child: Text(
              label,
              style: text.bodyEmphasis.copyWith(
                color: selected ? colors.onPrimary : colors.onSurfaceMuted,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DirectorySupplierTab extends ConsumerWidget {
  const _DirectorySupplierTab({required this.localeCode});

  final String localeCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final rows = ref.watch(directorySuppliersProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSize.screenPadding, 0, AppSize.screenPadding, AppSize.spaceMD),
      children: [
        AsyncValueBody(
          value: rows,
          loadingPlaceholder: const DirectoryListLoadingSkeleton(count: 3),
          error: (e, _) => AppCard(
            child: AppFallback.section(
              icon: Icons.error_outline,
              title: l10n.homeLoadErrorTitle,
              description: e.toString(),
              actions: [
                AppFallbackAction(
                  label: l10n.retry,
                  onPressed: () => ref.invalidate(directorySuppliersProvider),
                  role: AppFallbackActionRole.tertiary,
                ),
              ],
            ),
          ),
          data: (list) {
            if (list.isEmpty) {
              return AppCard(
                child: AppFallback.section(
                  leading: ShellNavIcon(
                    asset: Assets.icons.materialsPackageOutline,
                    color: context.colors.muted,
                    size: AppSize.icon,
                  ),
                  title: l10n.directoryEmptySuppliersTitle,
                  description: l10n.directoryEmptySuppliersDescription,
                  actions: [
                    AppFallbackAction(
                      label: l10n.directoryAddSupplier,
                      onPressed: () => CustomBottomSheet.show<String?>(
                        context: context,
                        builder: (_) => const InlineCreateSupplierPage(padForSystemChrome: false),
                        nestedNavigator: false,
                        showDragHandle: false,
                      ),
                      role: AppFallbackActionRole.primary,
                    ),
                  ],
                ),
              );
            }
            return Column(
              children: [
                for (var i = 0; i < list.length; i++) ...[
                  if (i > 0) AppSize.spaceMD.gap,
                  DirectoryPersonCard(
                    name: list[i].supplier.name,
                    paidPiastres: list[i].paidPiastres,
                    accentKey: directoryAccentKeyFor(list[i].supplier.id),
                    localeCode: localeCode,
                    onOpenDetail: () => context.push('/suppliers/${list[i].supplier.id}'),
                    onArchive: () => _confirmArchiveSupplier(
                      context,
                      ref,
                      supplierId: list[i].supplier.id,
                      name: list[i].supplier.name,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _DirectoryCraftsmenTab extends ConsumerWidget {
  const _DirectoryCraftsmenTab({required this.localeCode});

  final String localeCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final rows = ref.watch(directoryCraftsmenProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSize.screenPadding, 0, AppSize.screenPadding, AppSize.spaceMD),
      children: [
        AsyncValueBody(
          value: rows,
          loadingPlaceholder: const DirectoryListLoadingSkeleton(count: 3),
          error: (e, _) => AppCard(
            child: AppFallback.section(
              icon: Icons.error_outline,
              title: l10n.homeLoadErrorTitle,
              description: e.toString(),
              actions: [
                AppFallbackAction(
                  label: l10n.retry,
                  onPressed: () => ref.invalidate(directoryCraftsmenProvider),
                  role: AppFallbackActionRole.tertiary,
                ),
              ],
            ),
          ),
          data: (list) {
            if (list.isEmpty) {
              return AppCard(
                child: AppFallback.section(
                  leading: ShellNavIcon(
                    asset: Assets.icons.directoryOutline,
                    color: context.colors.muted,
                    size: AppSize.icon,
                  ),
                  title: l10n.directoryEmptyCraftsmenTitle,
                  description: l10n.directoryEmptyCraftsmenDescription,
                  actions: [
                    AppFallbackAction(
                      label: l10n.directoryAddCraftsman,
                      onPressed: () => CustomBottomSheet.show<String?>(
                        context: context,
                        builder: (_) => const InlineCreateCraftsmanPage(padForSystemChrome: false),
                        nestedNavigator: false,
                        showDragHandle: false,
                      ),
                      role: AppFallbackActionRole.primary,
                    ),
                  ],
                ),
              );
            }
            return Column(
              children: [
                for (var i = 0; i < list.length; i++) ...[
                  if (i > 0) AppSize.spaceMD.gap,
                  DirectoryPersonCard(
                    name: list[i].craftsman.name,
                    paidPiastres: list[i].paidPiastres,
                    paidInTrailing: true,
                    accentKey: directoryAccentKeyFor(list[i].craftsman.id),
                    localeCode: localeCode,
                    onOpenDetail: () => context.push('/craftsmen/${list[i].craftsman.id}'),
                    onArchive: () => _confirmArchiveCraftsman(
                      context,
                      ref,
                      craftsmanId: list[i].craftsman.id,
                      name: list[i].craftsman.name,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

Future<void> _confirmArchiveSupplier(
  BuildContext context,
  WidgetRef ref, {
  required String supplierId,
  required String name,
}) async {
  final l10n = AppLocalizations.of(context);
  final answer = await AppDecision.show(
    context,
    title: l10n.archiveSupplierTitle,
    description: l10n.archiveSupplierDescription(name),
    confirmLabel: l10n.archive,
    cancelLabel: l10n.cancel,
    tone: AppTone.danger,
    iconWidget: AppDecision.archiveDangerIcon(context),
  );
  if (answer != OverlayAnswer.confirmed) return;
  await ref.read(repositoryProvider).archiveSupplier(supplierId);
}

Future<void> _confirmArchiveCraftsman(
  BuildContext context,
  WidgetRef ref, {
  required String craftsmanId,
  required String name,
}) async {
  final l10n = AppLocalizations.of(context);
  final answer = await AppDecision.show(
    context,
    title: l10n.archiveCraftsmanTitle,
    description: l10n.archiveCraftsmanDescription(name),
    confirmLabel: l10n.archive,
    cancelLabel: l10n.cancel,
    tone: AppTone.danger,
    iconWidget: AppDecision.archiveDangerIcon(context),
  );
  if (answer != OverlayAnswer.confirmed) return;
  await ref.read(repositoryProvider).archiveCraftsman(craftsmanId);
}
