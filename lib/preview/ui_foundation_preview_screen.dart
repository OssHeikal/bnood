import 'package:flutter/material.dart';

import '../core/config/extensions/num_extensions.dart';
import '../core/config/theme/app_size.dart';
import '../core/config/theme/app_colors.dart';
import '../core/config/theme/app_theme.dart';
import '../core/l10n/field_placeholders.dart';
import '../core/widgets/app_amount.dart';
import '../core/widgets/app_card.dart';
import '../core/widgets/app_fallback.dart';
import '../core/widgets/app_decision.dart';
import '../core/widgets/toast/app_tone.dart';
import '../core/widgets/custom_text_field.dart';
import '../core/widgets/foundation_toaster.dart';
import '../core/widgets/buttons/app_button.dart';
import '../core/widgets/custom_app_bar.dart';
import '../core/widgets/sheet/app_sheet.dart';

/// In-memory demo only — no database.
class UiFoundationPreviewScreen extends StatefulWidget {
  const UiFoundationPreviewScreen({super.key});

  @override
  State<UiFoundationPreviewScreen> createState() => _UiFoundationPreviewScreenState();
}

class _UiFoundationPreviewScreenState extends State<UiFoundationPreviewScreen> {
  ThemeMode _mode = ThemeMode.light;
  Locale _locale = const Locale('ar');
  double _textScale = 1;
  bool _loading = false;
  final _search = TextEditingController();
  final _amount = TextEditingController(text: '1,250.50');

  @override
  void dispose() {
    _search.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _mode == ThemeMode.dark ? AppFoundationTheme.dark() : AppFoundationTheme.light(),
      child: Localizations.override(
        context: context,
        locale: _locale,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(_textScale)),
          child: Builder(
            builder: (context) => Scaffold(
              appBar: CustomAppBar(
                title: _locale.languageCode == 'ar' ? 'معاينة واجهة' : 'UI foundation',
              ),
              body: ListView(
                padding: const EdgeInsets.all(AppSize.spaceLG),
                children: [
                  _controls(context),
                  AppSize.spaceLG.gap,
                  _section(context, 'Typography', _typography(context)),
                  _section(context, 'Amounts', _amounts(context)),
                  _section(context, 'Cards', _cards(context)),
                  _section(context, 'Fallback', _fallback(context)),
                  _section(context, 'Buttons', _buttons(context)),
                  _section(context, 'Fields', _fields(context)),
                  _section(context, 'Overlays', _overlays(context)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _controls(BuildContext context) {
    return Wrap(
      spacing: AppSize.spaceSM,
      runSpacing: AppSize.spaceSM,
      children: [
        ChoiceChip(
          label: const Text('AR'),
          selected: _locale.languageCode == 'ar',
          onSelected: (_) => setState(() => _locale = const Locale('ar')),
        ),
        ChoiceChip(
          label: const Text('EN'),
          selected: _locale.languageCode == 'en',
          onSelected: (_) => setState(() => _locale = const Locale('en')),
        ),
        ChoiceChip(
          label: const Text('Light'),
          selected: _mode == ThemeMode.light,
          onSelected: (_) => setState(() => _mode = ThemeMode.light),
        ),
        ChoiceChip(
          label: const Text('Dark'),
          selected: _mode == ThemeMode.dark,
          onSelected: (_) => setState(() => _mode = ThemeMode.dark),
        ),
        ChoiceChip(
          label: const Text('Text 1.2x'),
          selected: _textScale > 1.05,
          onSelected: (v) => setState(() => _textScale = v ? 1.2 : 1),
        ),
      ],
    );
  }

  Widget _section(BuildContext context, String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: context.text.sectionTitle),
        AppSize.spaceMD.gap,
        child,
        AppSize.space2XL.gap,
      ],
    );
  }

  Widget _typography(BuildContext context) {
    final t = context.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('رصيد رئيسي', style: t.balance),
        Text('عنوان صفحة', style: t.pageTitle),
        Text('قسم', style: t.sectionTitle),
        Text('نص عادي', style: t.body),
        Text('نص ثانوي', style: t.supporting),
      ],
    );
  }

  Widget _amounts(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        AppAmount(piastres: 1_200_000, role: AppAmountRole.remaining, size: AppAmountSize.balance),
        AppAmount(piastres: 500_000, role: AppAmountRole.receive),
        AppAmount(piastres: 300_000, role: AppAmountRole.spend),
        AppAmount(piastres: 0, role: AppAmountRole.neutral),
        AppAmount(piastres: -150_000, role: AppAmountRole.spend, showSign: true),
      ],
    );
  }

  Widget _cards(BuildContext context) {
    return Column(
      children: [
        AppCard.statReceive(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('وارد', style: context.text.label),
              const AppAmount(piastres: 2_000_000, role: AppAmountRole.receive),
            ],
          ),
        ),
        AppSize.spaceMD.gap,
        AppCard(child: Text('بطاقة عادية', style: context.text.body)),
      ],
    );
  }

  Widget _fallback(BuildContext context) {
    return AppFallback(
      title: 'لا يوجد عملاء بعد',
      description: 'بيانات تجريبية — لا تُحفظ',
      actions: [
        AppFallbackAction(
          label: _locale.languageCode == 'ar' ? 'إضافة عميل' : 'Add client',
          onPressed: () {},
        ),
        AppFallbackAction(
          label: _locale.languageCode == 'ar' ? 'استيراد' : 'Import',
          role: AppFallbackActionRole.secondary,
          onPressed: () {},
        ),
        AppFallbackAction(
          label: _locale.languageCode == 'ar' ? 'تخطي' : 'Skip',
          role: AppFallbackActionRole.tertiary,
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buttons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton.primary(
          text: _locale.languageCode == 'ar' ? 'أساسي' : 'Primary',
          onPressed: () {},
          isLoading: _loading,
        ),
        AppSize.spaceSM.gap,
        AppButton.secondary(text: 'Secondary', onPressed: () {}, isExpanded: true),
        AppSize.spaceSM.gap,
        AppButton.primary(
          text: _locale.languageCode == 'ar' ? 'تبديل تحميل' : 'Toggle loading',
          onPressed: () => setState(() => _loading = !_loading),
        ),
        AppSize.spaceSM.gap,
        AppButton.destructive(text: 'Disabled', onPressed: null),
        AppSize.spaceSM.gap,
        AppButton.text(text: _locale.languageCode == 'ar' ? 'نص / ثالثي' : 'Text / tertiary', onPressed: () {}),
        AppSize.spaceSM.gap,
        AppButton.destructive(
          text: _locale.languageCode == 'ar' ? 'حذف' : 'Delete',
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _fields(BuildContext context) {
    return Column(
      children: [
        CustomTextField.search(controller: _search, placeholder: FieldPlaceholders.search),
        AppSize.spaceMD.gap,
        CustomTextField(
          label: _locale.languageCode == 'ar' ? 'مبلغ' : 'Amount',
          type: AppInputType.currency,
          controller: _amount,
        ),
      ],
    );
  }

  Widget _overlays(BuildContext context) {
    return Wrap(
      spacing: AppSize.spaceSM,
      children: [
        AppButton.outlined(
          text: 'Toast',
          onPressed: () => FoundationToaster.success('تم الحفظ (تجريبي)'),
          isExpanded: false,
        ),
        AppButton.outlined(
          text: 'Sheet',
          onPressed: () => AppSheet.actions(
            context,
            title: 'خيارات',
            actions: [
              SheetAction(label: 'إلغاء', onPressed: () => Navigator.pop(context)),
            ],
          ),
          isExpanded: false,
        ),
        AppButton.outlined(
          text: 'Decision',
          onPressed: () => AppDecision.show(
            context,
            title: 'تأكيد',
            description: 'بيانات تجريبية',
            confirmLabel: 'نعم',
            cancelLabel: 'لا',
          ),
          isExpanded: false,
        ),
        AppButton.outlined(
          text: 'Decision async',
          onPressed: () => AppDecision.show(
            context,
            title: 'حذف العميل',
            description: 'هل أنت متأكد؟',
            confirmLabel: 'حذف',
            cancelLabel: 'إلغاء',
            tone: AppTone.danger,
            onConfirm: () async {},
          ),
          isExpanded: false,
        ),
      ],
    );
  }
}
