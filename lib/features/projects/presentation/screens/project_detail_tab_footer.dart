import 'package:flutter/material.dart';

import '../../../../core/services/config/extensions/num_extensions.dart';
import '../../../../core/services/config/theme/app_size.dart';
import '../../../../core/ui/widgets/buttons/app_button.dart';

/// Footer actions for phone project-detail tabs.
///
/// Assign/add uses filled [AppButton.primary]; see-all always uses [AppButton.text].
class ProjectDetailTabFooter extends StatelessWidget {
  const ProjectDetailTabFooter({
    super.key,
    this.filledActionLabel,
    this.onFilledAction,
    this.filledEnabled = true,
    required this.seeAllLabel,
    required this.onSeeAll,
    this.seeAllEnabled = true,
    this.seeAllKey,
  });

  /// Primary filled CTA (craftsmen/suppliers assign only).
  final String? filledActionLabel;
  final VoidCallback? onFilledAction;
  final bool filledEnabled;

  final String seeAllLabel;
  final VoidCallback onSeeAll;
  final bool seeAllEnabled;
  final Key? seeAllKey;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    if (filledActionLabel != null && onFilledAction != null) {
      children.add(
        AppButton.primary(
          text: filledActionLabel!,
          onPressed: filledEnabled ? onFilledAction : null,
          isExpanded: true,
        ),
      );
    }

    if (children.isNotEmpty) {
      children.add(AppSize.spaceMD.gap);
    }

    children.add(
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: AppButton.text(
          key: seeAllKey ?? const Key('project_detail_tab_see_all'),
          text: seeAllLabel,
          onPressed: seeAllEnabled ? onSeeAll : null,
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}