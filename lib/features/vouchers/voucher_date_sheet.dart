import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bnood/l10n/app_localizations.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../core/config/extensions/num_extensions.dart';
import '../../core/layout/bnood_form_route_canvas.dart';
import '../../core/config/extensions/text_style_extensions.dart';
import '../../core/config/theme/app_colors.dart';
import '../../core/config/theme/app_size.dart';
import '../../core/formatting/display_digits.dart';
import '../../core/widgets/app_chevron.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/overlay_form_presentation.dart';
import '../../core/widgets/sheet_drag_handle.dart';
import '../home/home_foundation_scope.dart';

/// Opens the app calendar date sheet; returns the confirmed day or null.
Future<DateTime?> showVoucherDateSheet(
  BuildContext context, {
  required DateTime initial,
  required DateTime firstDate,
  required DateTime lastDate,
  OverlayFormPresentation presentation = OverlayFormPresentation.inSheet,
  bool fullscreenDialog = true,
}) {
  return Navigator.of(context).push<DateTime>(
    MaterialPageRoute(
      fullscreenDialog: fullscreenDialog,
      builder: (_) => VoucherDateSheetPage(
        initial: initial,
        firstDate: firstDate,
        lastDate: lastDate,
        presentation: presentation,
      ),
    ),
  );
}

/// Staged voucher date picker: swipe months, header wheels, confirm commits.
class VoucherDateSheetPage extends StatefulWidget {
  const VoucherDateSheetPage({
    super.key,
    required this.initial,
    required this.firstDate,
    required this.lastDate,
    this.presentation = OverlayFormPresentation.inSheet,
  });

  final DateTime initial;
  final DateTime firstDate;
  final DateTime lastDate;
  final OverlayFormPresentation presentation;

  @override
  State<VoucherDateSheetPage> createState() => _VoucherDateSheetPageState();
}

class _VoucherDateSheetPageState extends State<VoucherDateSheetPage> {
  late DateTime _staged;
  late DateTime _visibleMonth;
  var _showWheels = false;
  late int _wheelMonth;
  late int _wheelYear;

  @override
  void initState() {
    super.initState();
    _staged = _clampDay(widget.initial);
    _visibleMonth = DateTime(_staged.year, _staged.month);
    _wheelMonth = _staged.month;
    _wheelYear = _staged.year;
  }

  DateTime _clampDay(DateTime value) {
    final day = DateTime(value.year, value.month, value.day);
    if (day.isBefore(widget.firstDate)) return _dateOnly(widget.firstDate);
    if (day.isAfter(widget.lastDate)) return _dateOnly(widget.lastDate);
    return day;
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  void _shiftMonth(int delta) {
    final next = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    final start = DateTime(widget.firstDate.year, widget.firstDate.month);
    final end = DateTime(widget.lastDate.year, widget.lastDate.month);
    if (next.isBefore(start) || next.isAfter(end)) return;
    setState(() => _visibleMonth = next);
  }

  void _selectDay(DateTime day) {
    if (day.isBefore(_dateOnly(widget.firstDate)) || day.isAfter(_dateOnly(widget.lastDate))) {
      return;
    }
    setState(() => _staged = day);
  }

  void _openWheels() {
    setState(() {
      _showWheels = true;
      _wheelMonth = _visibleMonth.month;
      _wheelYear = _visibleMonth.year;
    });
  }

  void _applyWheels() {
    final monthStart = DateTime(_wheelYear, _wheelMonth);
    final start = DateTime(widget.firstDate.year, widget.firstDate.month);
    final end = DateTime(widget.lastDate.year, widget.lastDate.month);
    if (monthStart.isBefore(start) || monthStart.isAfter(end)) return;
    setState(() {
      _visibleMonth = monthStart;
      _showWheels = false;
      final lastDay = DateTime(_wheelYear, _wheelMonth + 1, 0).day;
      final day = _staged.day.clamp(1, lastDay);
      _staged = _clampDay(DateTime(_wheelYear, _wheelMonth, day));
    });
  }

  void _cancelWheels() {
    setState(() => _showWheels = false);
  }

  void _confirm() => Navigator.pop(context, _staged);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final localeTag = locale.languageCode == 'ar' ? 'ar_EG' : 'en_US';
    // final colors = context.colors;
    final today = _dateOnly(DateTime.now());

    final calendarBody = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CalendarHeader(
          visibleMonth: _visibleMonth,
          localeTag: localeTag,
          onPrev: () => _shiftMonth(-1),
          onNext: () => _shiftMonth(1),
          onTitleTap: _openWheels,
        ),
        AppSize.spaceMD.gap,
        _MonthGrid(
          month: _visibleMonth,
          localeTag: localeTag,
          selected: _staged,
          today: today,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          onSelect: _selectDay,
          onSwipe: _shiftMonth,
        ),
      ],
    );

    final confirmButton = AppButton.primary(
      key: const ValueKey('voucher-date-confirm'),
      text: l10n.save,
      onPressed: _confirm,
    );

    final wheels = _showWheels
        ? _MonthYearWheelsOverlay(
            firstDate: widget.firstDate,
            lastDate: widget.lastDate,
            month: _wheelMonth,
            year: _wheelYear,
            localeTag: localeTag,
            onMonthChanged: (m) => setState(() => _wheelMonth = m),
            onYearChanged: (y) => setState(() => _wheelYear = y),
            onCancel: _cancelWheels,
            onApply: _applyWheels,
          )
        : null;

    if (widget.presentation == OverlayFormPresentation.fullScreen) {
      return BnoodFormRouteCanvas(
        child: HomeFoundationScope(
          child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: CustomAppBar(title: l10n.date),
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSize.screenPadding,
                      AppSize.spaceMD,
                      AppSize.screenPadding,
                      AppSize.spaceMD,
                    ),
                    child: calendarBody,
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSize.screenPadding,
                      AppSize.spaceMD,
                      AppSize.screenPadding,
                      AppSize.spaceMD,
                    ),
                    child: confirmButton,
                  ),
                ),
              ],
            ),
            if (wheels != null) wheels,
          ],
        ),
          ),
        ),
      );
    }

    return Material(
      child: SafeArea(
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSize.screenPadding,
                    AppSize.spaceSM,
                    AppSize.screenPadding,
                    AppSize.spaceMD,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SheetDragHandle(),
                      AppSize.spaceMD.gap,
                      Row(
                        children: [
                          BackButton(onPressed: () => Navigator.maybePop(context)),
                          Expanded(child: Text(l10n.date, style: context.text.title)),
                        ],
                      ),
                      AppSize.spaceMD.gap,
                      calendarBody,
                      AppSize.spaceLG.gap,
                      confirmButton,
                    ],
                  ),
                );
              },
            ),
            if (wheels != null) wheels,
          ],
        ),
      ),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    required this.visibleMonth,
    required this.localeTag,
    required this.onPrev,
    required this.onNext,
    required this.onTitleTap,
  });

  final DateTime visibleMonth;
  final String localeTag;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onTitleTap;

  @override
  Widget build(BuildContext context) {
    final titleRaw = DateFormat.yMMMM(localeTag).format(visibleMonth);
    final title = DisplayDigits.toWesternDigits(titleRaw);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        children: [
          IconButton(onPressed: onPrev, icon: const AppChevron.left()),
          Expanded(
            child: InkWell(
              key: const ValueKey('voucher-calendar-title'),
              onTap: onTitleTap,
              borderRadius: BorderRadius.circular(AppSize.radiusMD),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSize.spaceSM),
                child: Text(title, textAlign: TextAlign.center, style: context.text.body.semiBold),
              ),
            ),
          ),
          IconButton(onPressed: onNext, icon: const AppChevron.right()),
        ],
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.localeTag,
    required this.selected,
    required this.today,
    required this.firstDate,
    required this.lastDate,
    required this.onSelect,
    required this.onSwipe,
  });

  final DateTime month;
  final String localeTag;
  final DateTime selected;
  final DateTime today;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onSelect;
  final ValueChanged<int> onSwipe;

  @override
  Widget build(BuildContext context) {
    final weekdayLabels = _weekdayLabels(context, localeTag);
    final cells = _buildCells(context, month, firstDate, lastDate);

    final colors = context.colors;
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        final v = details.primaryVelocity ?? 0;
        if (v > 200) {
          onSwipe(-1);
        } else if (v < -200) {
          onSwipe(1);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              for (final label in weekdayLabels)
                Expanded(
                  child: Center(child: Text(label, style: context.text.caption.setColor(colors.onSurfaceMuted))),
                ),
            ],
          ),
          AppSize.spaceSM.gap,
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: cells.length,
            itemBuilder: (context, index) {
              final cell = cells[index];
              if (cell == null) return const SizedBox.shrink();
              final isSelected = _sameDay(cell, selected);
              final isToday = _sameDay(cell, today);
              final enabled =
                  !cell.isBefore(DateTime(firstDate.year, firstDate.month, firstDate.day)) &&
                  !cell.isAfter(DateTime(lastDate.year, lastDate.month, lastDate.day));
              final dayLabel = DisplayDigits.toWesternDigits('${cell.day}');
              Color? fill;
              Color fg = colors.onSurface;
              BoxBorder? border;
              if (!enabled) {
                fg = colors.onSurfaceMuted.withValues(alpha: 0.45);
              } else if (isSelected) {
                fill = colors.primary;
                fg = Colors.white;
              } else if (isToday) {
                border = Border.all(color: colors.primary, width: 1.5);
              }
              return Material(
                key: ValueKey('voucher-day-${cell.year}-${cell.month}-${cell.day}'),
                color: fill ?? Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: enabled ? () => onSelect(cell) : null,
                  borderRadius: BorderRadius.circular(8),
                  child: DecoratedBox(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: border),
                    child: Center(child: Text(dayLabel, style: context.text.body.semiBold.setColor(fg))),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  List<String> _weekdayLabels(BuildContext context, String localeTag) {
    final mat = MaterialLocalizations.of(context);
    final first = mat.firstDayOfWeekIndex;
    final labels = mat.narrowWeekdays;
    final ordered = [...labels.sublist(first), ...labels.sublist(0, first)];
    return ordered.map(DisplayDigits.toWesternDigits).toList();
  }

  List<DateTime?> _buildCells(BuildContext context, DateTime month, DateTime first, DateTime last) {
    final firstOfMonth = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstDayIndex = MaterialLocalizations.of(context).firstDayOfWeekIndex;
    final dayIndex = firstOfMonth.weekday % 7;
    final leading = (dayIndex - firstDayIndex + 7) % 7;
    final cells = <DateTime?>[];
    for (var i = 0; i < leading; i++) {
      cells.add(null);
    }
    for (var d = 1; d <= daysInMonth; d++) {
      cells.add(DateTime(month.year, month.month, d));
    }
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    return cells;
  }
}

class _MonthYearWheelsOverlay extends StatelessWidget {
  const _MonthYearWheelsOverlay({
    required this.firstDate,
    required this.lastDate,
    required this.month,
    required this.year,
    required this.localeTag,
    required this.onMonthChanged,
    required this.onYearChanged,
    required this.onCancel,
    required this.onApply,
  });

  final DateTime firstDate;
  final DateTime lastDate;
  final int month;
  final int year;
  final String localeTag;
  final ValueChanged<int> onMonthChanged;
  final ValueChanged<int> onYearChanged;
  final VoidCallback onCancel;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final years = List<int>.generate(lastDate.year - firstDate.year + 1, (i) => firstDate.year + i);
    final months = List<int>.generate(12, (i) => i + 1);
    final monthLabels = months
        .map((m) => DisplayDigits.toWesternDigits(DateFormat.MMMM(localeTag).format(DateTime(2024, m))))
        .toList();

    return Positioned.fill(
      child: Material(
        color: colors.onSurface.withValues(alpha: 0.35),
        child: SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(AppSize.screenPadding),
              child: Material(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppSize.cardRadius),
                child: Padding(
                  padding: const EdgeInsets.all(AppSize.spaceMD),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 180,
                        child: Row(
                          children: [
                            Expanded(
                              child: CupertinoPicker(
                                scrollController: FixedExtentScrollController(initialItem: month - 1),
                                itemExtent: 36,
                                onSelectedItemChanged: (i) => onMonthChanged(months[i]),
                                children: [
                                  for (final label in monthLabels) Center(child: Text(label, style: context.text.body)),
                                ],
                              ),
                            ),
                            Expanded(
                              child: CupertinoPicker(
                                scrollController: FixedExtentScrollController(
                                  initialItem: years.indexOf(year).clamp(0, years.length - 1),
                                ),
                                itemExtent: 36,
                                onSelectedItemChanged: (i) => onYearChanged(years[i]),
                                children: [
                                  for (final y in years)
                                    Center(child: Text(DisplayDigits.toWesternDigits('$y'), style: context.text.body)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppSize.spaceMD.gap,
                      Row(
                        children: [
                          Expanded(
                            child: AppButton.secondary(text: l10n.cancel, onPressed: onCancel),
                          ),
                          AppSize.spaceSM.gap,
                          Expanded(
                            child: AppButton.primary(text: l10n.save, onPressed: onApply),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
