import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/account/account_scope.dart';
import '../../../../core/account/office_membership.dart';
import '../../../../core/domain/formatting/person_initials.dart';
import '../../../../core/services/config/extensions/num_extensions.dart';
import '../../../../core/services/config/theme/app_colors.dart';
import '../../../../core/services/config/theme/app_shape.dart';
import '../../../../core/services/config/theme/app_size.dart';
import '../../../../core/ui/resources/gen/assets.gen.dart';
import '../../../../core/ui/widgets/app_modal_sheet.dart';
import '../../../../core/ui/widgets/app_pressable.dart';
import '../../../../core/ui/widgets/grouped_list_divider.dart';
import '../../../../core/ui/widgets/sheet_drag_handle.dart';
import '../../../../app/widgets/shell_nav_icon.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/home/presentation/widgets/home_foundation_scope.dart';
import 'package:bnood/l10n/app_localizations.dart';

/// Bottom sheet for picking personal vs office account scope.
class AccountSwitcherSheet extends ConsumerWidget {
  const AccountSwitcherSheet({
    super.key,
    required this.memberships,
    required this.locksOwned,
    required this.currentScope,
  });

  final List<OfficeMembership> memberships;
  final bool locksOwned;
  final AccountScope currentScope;

  static const double _avatarSize = 40;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final text = context.text;
    final homeBottom = AppModalSheetScope.homeIndicatorOf(context);
    final bottomGap = AppSize.spaceLG + homeBottom;

    final user = ref.watch(authControllerProvider.select((s) => s.user));
    final personalName = user?.name?.trim().isNotEmpty == true
        ? user!.name!.trim()
        : (user?.phone.trim() ?? l10n.accountScopePersonal);

    final rows = <_AccountSwitcherRowData>[
      if (!locksOwned)
        _AccountSwitcherRowData(
          scope: const AccountScope.personal(),
          title: personalName,
          subtitle: l10n.accountScopePersonal,
          kind: _AccountSwitcherRowKind.personal,
          imageUrl: user?.logoUrl,
        ),
      for (final office in memberships)
        _AccountSwitcherRowData(
          scope: AccountScope.office(office.id),
          title: office.name.isNotEmpty ? office.name : office.id,
          subtitle: l10n.accountScopeOffice,
          kind: _AccountSwitcherRowKind.office,
          imageUrl: office.logoUrl,
        ),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSize.screenPadding,
        AppSize.spaceSM,
        AppSize.screenPadding,
        bottomGap,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: SheetDragHandle()),
          AppSize.spaceLG.gap,
          Text(
            l10n.accountSwitchTitle,
            style: text.title,
            textAlign: TextAlign.start,
          ),
          AppSize.spaceLG.gap,
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceSunken,
              borderRadius: BorderRadius.circular(AppSize.radiusSM),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  _AccountSwitcherRow(
                    data: rows[i],
                    selected: rows[i].scope == currentScope,
                  ),
                  if (i < rows.length - 1)
                    GroupedListDivider.build(
                      context,
                      kind: GroupedListDividerKind.leadingIcon,
                      color: colors.outlineSubtle,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _AccountSwitcherRowKind { personal, office }

class _AccountSwitcherRowData {
  const _AccountSwitcherRowData({
    required this.scope,
    required this.title,
    required this.subtitle,
    required this.kind,
    this.imageUrl,
  });

  final AccountScope scope;
  final String title;
  final String subtitle;
  final _AccountSwitcherRowKind kind;
  final String? imageUrl;
}

class _AccountSwitcherRow extends StatelessWidget {
  const _AccountSwitcherRow({
    required this.data,
    required this.selected,
  });

  final _AccountSwitcherRowData data;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final leading = _AccountSwitcherLeading(
      title: data.title,
      imageUrl: data.imageUrl,
      kind: data.kind,
      selected: selected,
    );

    return Semantics(
      button: true,
      selected: selected,
      label: data.title,
      child: AppPressable(
        onPressed: () => Navigator.of(context).pop(data.scope),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSize.hitMin),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSize.spaceMD,
              AppSize.spaceMD,
              AppSize.spaceMD,
              AppSize.spaceMD,
            ),
            child: Row(
              children: [
                leading,
                const SizedBox(width: AppSize.spaceMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        data.title,
                        style: text.bodyEmphasis.copyWith(
                          color: selected
                              ? colors.primaryDark
                              : colors.onSurface,
                        ),
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppSize.spaceXS.gap,
                      Text(
                        data.subtitle,
                        style: text.caption.copyWith(
                          color: colors.onSurfaceMuted,
                        ),
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSize.spaceSM),
                SizedBox(
                  width: AppSize.icon,
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: selected
                        ? ShellNavIcon(
                            asset: Assets.icons.checkOutline,
                            color: colors.primary,
                            size: AppSize.iconCompact,
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountSwitcherLeading extends StatelessWidget {
  const _AccountSwitcherLeading({
    required this.title,
    required this.imageUrl,
    required this.kind,
    required this.selected,
  });

  final String title;
  final String? imageUrl;
  final _AccountSwitcherRowKind kind;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
  final url = imageUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return _circle(
        colors,
        child: Image.network(
          url,
          width: AccountSwitcherSheet._avatarSize,
          height: AccountSwitcherSheet._avatarSize,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _glyph(colors),
        ),
      );
    }
    if (kind == _AccountSwitcherRowKind.personal &&
        personInitials(title).isNotEmpty) {
      return _circle(
        colors,
        child: Center(
          child: Text(
            personInitials(title),
            style: context.text.bodyEmphasis.copyWith(
              color: selected ? colors.primary : colors.onSurfaceMuted,
              fontSize: 16,
              height: 1,
            ),
          ),
        ),
      );
    }
    return _glyph(colors);
  }

  Widget _glyph(AppColors colors) {
    final asset = kind == _AccountSwitcherRowKind.personal
        ? Assets.icons.profileCircleOutline
        : Assets.icons.clientsOutline;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSize.radiusSM),
      ),
      child: SizedBox(
        width: AccountSwitcherSheet._avatarSize,
        height: AccountSwitcherSheet._avatarSize,
        child: Center(
          child: ShellNavIcon(
            asset: asset,
            color: colors.primaryDark,
            size: AppSize.icon,
          ),
        ),
      ),
    );
  }

  Widget _circle(AppColors colors, {required Widget child}) {
    return Material(
      color: colors.surfaceSunken,
      shape: AppShape.circle,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: AccountSwitcherSheet._avatarSize,
        height: AccountSwitcherSheet._avatarSize,
        child: child,
      ),
    );
  }
}

Future<AccountScope?> showAccountSwitcherSheetModal(
  BuildContext context, {
  required List<OfficeMembership> memberships,
  required bool locksOwned,
  required AccountScope currentScope,
}) {
  return AppModalSheet.show<AccountScope>(
    context: context,
    scrollable: false,
    body: HomeFoundationScope(
      child: AccountSwitcherSheet(
        memberships: memberships,
        locksOwned: locksOwned,
        currentScope: currentScope,
      ),
    ),
  );
}