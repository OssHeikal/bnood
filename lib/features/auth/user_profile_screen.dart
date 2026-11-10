import 'package:bnood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/extensions/num_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/utils/extensions/bidi_isolate.dart';
import '../../core/widgets/app_chevron.dart';
import '../../core/widgets/app_pressable.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/grouped_list_divider.dart';
import '../home/home_foundation_scope.dart';
import 'auth_controller.dart';
import 'auth_paths.dart';
import 'delete_account_confirm_sheet.dart';
import 'profile_edit_name_sheet.dart';
import '../../core/subscription/subscription_colors.dart';
import '../../core/subscription/subscription_riverpod.dart';
import 'widgets/profile_subscription_card.dart';
import 'widgets/user_identity_avatar.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(authControllerProvider).user;
    final name = user?.name?.trim() ?? '';
    final phone = user?.phone;
    final entitlements = ref.watch(subscriptionEntitlementsProvider);
    final surfaces = ref.watch(subscriptionSurfacesEnabledProvider);
    final premiumAvatar = surfaces && (entitlements?.showPremiumAvatar ?? false);

    return HomeFoundationScope(
      child: Builder(
        builder: (context) {
          final colors = context.colors;
          final text = context.text;

          return Scaffold(
            appBar: CustomAppBar(title: l10n.userProfileTitle),
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(AppSize.screenPadding),
                children: [
                  Align(
                    child: UserIdentityAvatar(
                      displayName: name.isNotEmpty ? name : '?',
                      size: 80,
                      backgroundColor: premiumAvatar ? entitlements!.premiumAvatarColor : null,
                      foregroundColor: premiumAvatar ? SubscriptionColors.onViolet : null,
                    ),
                  ),
                  AppSize.spaceMD.gap,
                  if (name.isNotEmpty)
                    Text(
                      name,
                      style: text.pageTitle,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  AppSize.spaceXS.gap,
                  Text(
                    phone != null && phone.isNotEmpty ? LtrIsolate.isolate(phone) : '—',
                    style: text.body.copyWith(color: colors.onSurfaceMuted),
                    textAlign: TextAlign.center,
                  ),
                  AppSize.spaceXL.gap,
                  const ProfileSubscriptionCard(),
                  AppSize.spaceXL.gap,
                  _ProfileSection(
                    title: l10n.profilePersonalSection,
                    children: [
                      _ProfileActionRow(
                        label: l10n.authDisplayName,
                        value: name.isNotEmpty ? name : '—',
                        actionLabel: l10n.edit,
                        onAction: user == null
                            ? null
                            : () async {
                                await showProfileEditNameSheet(context, initialName: name);
                              },
                      ),
                      _ProfileActionRow(
                        label: l10n.authPhone,
                        value: phone != null && phone.isNotEmpty ? LtrIsolate.isolate(phone) : '—',
                        valueLtr: true,
                      ),
                    ],
                  ),
                  AppSize.spaceXL.gap,
                  _ProfileSection(
                    title: l10n.profileSecuritySection,
                    children: [
                      _ProfileNavRow(
                        label: l10n.authChangePassword,
                        subtitle: l10n.profileChangePasswordHint,
                        onTap: () => context.push(AuthPaths.changePassword),
                      ),
                    ],
                  ),
                  AppSize.spaceXL.gap,
                  _ProfileSection(
                    title: l10n.profileDangerSection,
                    children: [
                      _ProfileNavRow(
                        label: l10n.authDeleteAccount,
                        subtitle: l10n.profileDeleteAccountHint,
                        destructive: true,
                        onTap: () => showDeleteAccountConfirmSheet(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: context.text.groupTitle, textAlign: TextAlign.start),
        AppSize.spaceSM.gap,
        DecoratedBox(
          decoration: BoxDecoration(color: colors.surfaceSunken, borderRadius: BorderRadius.circular(AppSize.radiusSM)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  GroupedListDivider.build(
                    context,
                    kind: GroupedListDividerKind.insetStart,
                    color: colors.outlineSubtle,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileActionRow extends StatelessWidget {
  const _ProfileActionRow({
    required this.label,
    required this.value,
    this.actionLabel,
    this.onAction,
    this.valueLtr = false,
  });

  final String label;
  final String value;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool valueLtr;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final valueWidget = Text(
      valueLtr ? LtrIsolate.isolate(value) : value,
      style: text.bodyEmphasis,
      textAlign: TextAlign.start,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(AppSize.spaceMD, AppSize.spaceMD, AppSize.spaceMD, AppSize.spaceMD),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(label, style: text.caption.copyWith(color: colors.onSurfaceMuted)),
                AppSize.spaceXS.gap,
                valueWidget,
              ],
            ),
          ),
          if (onAction != null && actionLabel != null) ...[
            AppSize.spaceSM.gap,
            AppPressable(
              onPressed: onAction,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSize.spaceXS, vertical: AppSize.spaceXS),
                child: Text(actionLabel!, style: text.bodyEmphasis.copyWith(color: colors.primary)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileNavRow extends StatelessWidget {
  const _ProfileNavRow({required this.label, required this.onTap, this.subtitle, this.destructive = false});

  final String label;
  final String? subtitle;
  final bool destructive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final titleStyle = destructive ? text.bodyEmphasis.copyWith(color: colors.error) : text.bodyEmphasis;

    return AppPressable(
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSize.spaceMD,
          AppSize.spaceMD,
          AppSize.spaceSM,
          AppSize.spaceMD,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(label, style: titleStyle, textAlign: TextAlign.start),
                  if (subtitle != null) ...[
                    AppSize.spaceXS.gap,
                    Text(
                      subtitle!,
                      style: text.caption.copyWith(color: colors.onSurfaceMuted),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ],
              ),
            ),
            if (!destructive) const AppChevron.forward(),
          ],
        ),
      ),
    );
  }
}
