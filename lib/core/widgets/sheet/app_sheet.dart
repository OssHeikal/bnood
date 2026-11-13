import 'package:flutter/material.dart';

import '../../config/extensions/num_extensions.dart';
import '../../config/theme/app_size.dart';
import '../../config/theme/app_colors.dart';
import '../app_decision.dart';
import '../buttons/app_button.dart';
import '../custom_list_tile.dart';
import '../grouped_list_divider.dart';
import '../sheet_drag_handle.dart';
import '../bnood_modal_sheet.dart';
import '../bounded_sheet_navigator.dart';
import '../toast/app_tone.dart';

class SheetChoice<T> {
  const SheetChoice({required this.value, required this.label, this.leading, this.enabled = true});

  final T value;
  final String label;
  final Widget? leading;
  final bool enabled;
}

class SheetAction {
  const SheetAction({
    required this.label,
    required this.onPressed,
    this.destructive = false,
    this.destructiveTitle,
    this.destructiveDescription,
    this.destructiveConfirmLabel,
    this.destructiveCancelLabel,
  });

  final String label;
  final VoidCallback onPressed;
  final bool destructive;
  final String? destructiveTitle;
  final String? destructiveDescription;
  final String? destructiveConfirmLabel;
  final String? destructiveCancelLabel;
}

abstract final class AppSheet {
  static Future<void> actions(BuildContext context, {required String title, required List<SheetAction> actions}) {
    return BnoodModalSheet.show<void>(
      context: context,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSize.cardRadius)),
      ),
      builder: (sheetContext) => _ActionSheetBody(title: title, actions: actions, hostContext: context),
    );
  }

  static Future<T?> choices<T>(BuildContext context, {required String title, required List<SheetChoice<T>> choices}) {
    return BnoodModalSheet.show<T>(
      context: context,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSize.cardRadius)),
      ),
      builder: (sheetContext) => _ChoiceSheetBody(title: title, choices: choices),
    );
  }
}

class _ChoiceSheetBody<T> extends StatelessWidget {
  const _ChoiceSheetBody({required this.title, required this.choices});

  final String title;
  final List<SheetChoice<T>> choices;

  @override
  Widget build(BuildContext context) {
    final maxListHeight = SheetContentBounds.viewportCap(MediaQuery.of(context)) * 0.7;
    final colors = context.colors;

    return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSize.spaceMD.gap,
            const SheetDragHandle(),
            AppSize.spaceLG.gap,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSize.spaceLG),
              child: Text(title, style: context.text.title),
            ),
            AppSize.spaceMD.gap,
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxListHeight),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: choices.length,
                separatorBuilder: (context, index) =>
                    GroupedListDivider.build(context, kind: GroupedListDividerKind.leadingIcon),
                itemBuilder: (context, index) {
                  final choice = choices[index];
                  return Material(
                    color: colors.surface,
                    child: CustomListTile(
                      leading: choice.leading,
                      title: choice.label,
                      enabled: choice.enabled,
                      onTap: choice.enabled ? () => Navigator.of(context).pop(choice.value) : null,
                    ),
                  );
                },
              ),
            ),
          ],
    );
  }
}

class _ActionSheetBody extends StatelessWidget {
  const _ActionSheetBody({required this.title, required this.actions, required this.hostContext});

  final String title;
  final List<SheetAction> actions;
  final BuildContext hostContext;

  Future<void> _onAction(BuildContext context, SheetAction action) async {
    if (action.destructive) {
      Navigator.of(context).pop();
      if (!hostContext.mounted) {
        return;
      }
      final answer = await AppDecision.show(
        hostContext,
        title: action.destructiveTitle ?? title,
        description: action.destructiveDescription,
        confirmLabel: action.destructiveConfirmLabel ?? action.label,
        cancelLabel: action.destructiveCancelLabel,
        tone: AppTone.danger,
      );
      if (answer == OverlayAnswer.confirmed) {
        action.onPressed();
      }
      return;
    }
    Navigator.of(context).pop();
    action.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSize.screenPadding,
        AppSize.spaceMD,
        AppSize.screenPadding,
        AppSize.screenPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetDragHandle(),
          AppSize.spaceLG.gap,
          Text(title, style: context.text.title),
          AppSize.spaceLG.gap,
          for (final action in actions) ...[
            if (action.destructive)
              AppButton.destructive(text: action.label, isExpanded: true, onPressed: () => _onAction(context, action))
            else
              AppButton.primary(text: action.label, isExpanded: true, onPressed: () => _onAction(context, action)),
            AppSize.gap.gap,
          ],
        ],
      ),
    );
  }
}
