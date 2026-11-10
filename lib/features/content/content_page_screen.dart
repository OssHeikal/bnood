import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:bnood/l10n/app_localizations.dart';

import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/utils/safe_external_url.dart';
import '../../core/widgets/app_fallback.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/skeleton/skeleton.dart';
import '../../core/widgets/skeleton/skeleton_box.dart';
import '../../core/widgets/skeleton/skeleton_text.dart' show SkeletonText, SkeletonTextRole;
import '../../features/home/home_foundation_scope.dart';
import 'content_page_provider.dart';

class ContentPageScreen extends ConsumerWidget {
  const ContentPageScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final pageAsync = ref.watch(contentPageProvider(slug));
    final title = pageAsync.maybeWhen(data: (p) => p.title, orElse: () => l10n.contentPageLoadingTitle);
    return HomeFoundationScope(
      child: Scaffold(
        appBar: CustomAppBar(title: title.isEmpty ? l10n.contentPageLoadingTitle : title),
        body: pageAsync.when(
          loading: () => const _ContentPageLoadingBody(),
          error: (e, _) {
            if (e is ContentPageNotFoundException) {
              return AppFallback.section(
                title: l10n.contentPageNotFoundTitle,
                description: l10n.contentPageNotFoundDescription,
              );
            }
            return AppFallback.section(
              title: l10n.contentPageErrorTitle,
              description: l10n.contentPageErrorDescription,
              actions: [
                AppFallbackAction(
                  label: l10n.retry,
                  onPressed: () => ref.invalidate(contentPageProvider(slug)),
                  role: AppFallbackActionRole.primary,
                ),
              ],
            );
          },
          data: (page) => SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSize.screenPadding),
              child: HtmlWidget(
                page.body,
                onTapUrl: (url) async {
                  if (!isAllowedExternalUrlString(url)) return false;
                  await launchAllowedUrl(url);
                  return true;
                },
                textStyle: context.text.body,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ContentPageLoadingBody extends StatelessWidget {
  const _ContentPageLoadingBody();

  @override
  Widget build(BuildContext context) {
    return const Skeleton(
      child: Padding(
        padding: EdgeInsets.all(AppSize.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SkeletonText(role: SkeletonTextRole.title, width: 220),
            SizedBox(height: AppSize.spaceLG),
            SkeletonBox(height: 200, radius: AppSize.radiusSM),
            SizedBox(height: AppSize.spaceMD),
            SkeletonText(role: SkeletonTextRole.body, width: 320),
            SizedBox(height: AppSize.spaceSM),
            SkeletonText(role: SkeletonTextRole.body, width: 300),
            SizedBox(height: AppSize.spaceSM),
            SkeletonText(role: SkeletonTextRole.body, width: 280),
          ],
        ),
      ),
    );
  }
}
