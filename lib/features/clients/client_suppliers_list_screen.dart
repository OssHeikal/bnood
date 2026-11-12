import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_fallback.dart';
import '../../core/widgets/app_pressable.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/skeleton/async_value_body.dart';
import '../home/home_foundation_scope.dart';
import 'client_suppliers_list_provider.dart';
import 'craftsman_assignments_sheet.dart';
import 'widgets/client_detail_craftsman_row.dart';
import 'widgets/client_linked_provider_list_skeleton.dart';

class ClientSuppliersListScreen extends ConsumerWidget {
  const ClientSuppliersListScreen({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final list = ref.watch(clientSuppliersListProvider(clientId));

    return HomeFoundationScope(
      child: Builder(
        builder: (context) {
          final colors = context.colors;
          final snapshot = list.valueOrNull;
          final canAssign = snapshot?.projectId != null;
          return Scaffold(
            backgroundColor: colors.canvas,
            appBar: CustomAppBar(
              title: l10n.suppliers,
              subtitle: snapshot?.clientName,
              actions: canAssign
                  ? [
                      AppPressable(
                        onPressed: () => _openAssignments(context, ref, clientId, snapshot!),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSize.spaceSM),
                          child: Text(
                            l10n.assignSuppliers,
                            style: context.text.caption.copyWith(
                              color: colors.primaryDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ]
                  : null,
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
                  value: list,
                  loadingPlaceholder: const ClientLinkedProviderListSkeleton(),
                  error: (e, _) => AppCard(
                    child: AppFallback.section(
                      icon: Icons.error_outline,
                      title: l10n.homeLoadErrorTitle,
                      description: e.toString(),
                      actions: [
                        AppFallbackAction(
                          label: l10n.retry,
                          onPressed: () =>
                              ref.read(clientSuppliersListProvider(clientId).notifier).refreshSilently(),
                          role: AppFallbackActionRole.tertiary,
                        ),
                      ],
                    ),
                  ),
                  data: (data) => _ClientSuppliersListBody(
                    clientId: clientId,
                    data: data,
                    localeCode: localeCode,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

Future<void> _openAssignments(
  BuildContext context,
  WidgetRef ref,
  String clientId,
  ClientSuppliersListSnapshot data,
) async {
  final projectId = data.projectId;
  if (projectId == null) return;
  await showSupplierAssignmentsSheet(
    context: context,
    projectId: projectId,
    clientId: clientId,
  );
  if (context.mounted) {
    await ref.read(clientSuppliersListProvider(clientId).notifier).refreshSilently();
  }
}

class _ClientSuppliersListBody extends ConsumerWidget {
  const _ClientSuppliersListBody({
    required this.clientId,
    required this.data,
    required this.localeCode,
  });

  final String clientId;
  final ClientSuppliersListSnapshot data;
  final String localeCode;

  Future<void> _openAssignments(BuildContext context, WidgetRef ref) async {
    final projectId = data.projectId;
    if (projectId == null) return;
    await showSupplierAssignmentsSheet(
      context: context,
      projectId: projectId,
      clientId: clientId,
    );
    if (context.mounted) {
      await ref.read(clientSuppliersListProvider(clientId).notifier).refreshSilently();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (data.rows.isEmpty)
          AppCard(
            child: AppFallback.section(
              leading: const Icon(Icons.local_shipping_outlined),
              title: l10n.clientDetailNoSuppliers,
              description: l10n.clientDetailSuppliersEmptyDescription,
              actions: data.projectId == null
                  ? const []
                  : [
                      AppFallbackAction(
                        label: l10n.assignSuppliers,
                        onPressed: () => _openAssignments(context, ref),
                        role: AppFallbackActionRole.tertiary,
                      ),
                    ],
            ),
          )
        else
          for (var i = 0; i < data.rows.length; i++) ...[
            if (i > 0) AppSize.spaceMD.gap,
            ClientDetailCraftsmanRow(preview: data.rows[i], localeCode: localeCode),
          ],
      ],
    );
  }
}
