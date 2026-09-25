import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../../core/localization/app_strings.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text.dart';

/// Weekly date range picker bottom sheet.
/// Mirrors Kotlin's DateRangePickerBottomSheet with LaunchedEffect week snap:
/// tapping any day auto-selects the full Monday–Sunday week of that day.
class WeekPickerBottomSheet extends StatefulWidget {
  final void Function(DateTime monday, DateTime sunday) onWeekSelected;

  const WeekPickerBottomSheet({super.key, required this.onWeekSelected});

  static Future<void> show(
    BuildContext context,
    void Function(DateTime monday, DateTime sunday) onWeekSelected,
  ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          WeekPickerBottomSheet(onWeekSelected: onWeekSelected),
    );
  }

  @override
  State<WeekPickerBottomSheet> createState() => _WeekPickerBottomSheetState();
}

class _WeekPickerBottomSheetState extends State<WeekPickerBottomSheet> {
  late DateTime _focusedMonth;
  DateTime? _selectedMonday;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
  }

  DateTime _mondayOf(DateTime date) =>
      date.subtract(Duration(days: date.weekday - 1));

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // First Monday before/on day 1 of focused month
    final firstOfMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final calendarStart = _mondayOf(firstOfMonth);
    final days =
        List.generate(42, (i) => calendarStart.add(Duration(days: i)));

    final monthLabel =
        intl.DateFormat('MMMM yyyy').format(_focusedMonth);

    final canGoPrev = DateTime(_focusedMonth.year, _focusedMonth.month - 1)
        .isAfter(DateTime(2019, 12));
    final canGoNext = DateTime(_focusedMonth.year, _focusedMonth.month)
            .isBefore(DateTime(now.year, now.month));

    // Effective end: cap at today
    final selectedSunday =
        _selectedMonday?.add(const Duration(days: 6));
    final effectiveEnd = selectedSunday != null && selectedSunday.isAfter(today)
        ? today
        : selectedSunday;

    return Container(
      decoration: BoxDecoration(
        color: colors.colorBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppDimens.paddingL),
          topRight: Radius.circular(AppDimens.paddingL),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: AppDimens.paddingM),
              decoration: BoxDecoration(
                color: colors.colorBackgroundGray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Month navigation
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppDimens.paddingS),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: canGoPrev
                        ? () => setState(() {
                              _focusedMonth = DateTime(
                                  _focusedMonth.year,
                                  _focusedMonth.month - 1);
                            })
                        : null,
                    icon: Icon(
                      Icons.chevron_left,
                      color: canGoPrev
                          ? colors.colorText
                          : colors.colorTextHint,
                    ),
                  ),
                  AppText(
                    monthLabel,
                    fontSize: AppTypos.textM,
                    fontWeight: FontWeight.w600,
                  ),
                  IconButton(
                    onPressed: canGoNext
                        ? () => setState(() {
                              _focusedMonth = DateTime(
                                  _focusedMonth.year,
                                  _focusedMonth.month + 1);
                            })
                        : null,
                    icon: Icon(
                      Icons.chevron_right,
                      color: canGoNext
                          ? colors.colorText
                          : colors.colorTextHint,
                    ),
                  ),
                ],
              ),
            ),

            // Day-of-week headers (Mon–Sun)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppDimens.padding),
              child: Row(
                children: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']
                    .map(
                      (d) => Expanded(
                        child: Center(
                          child: AppText.caption(
                            d,
                            color: colors.colorTextHint,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

            const SizedBox(height: AppDimens.paddingXS),

            // Calendar grid — 6 rows of 7 days
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppDimens.padding),
              child: Column(
                children: List.generate(6, (row) {
                  final weekDays =
                      days.sublist(row * 7, row * 7 + 7);
                  return _buildWeekRow(
                    context,
                    colors,
                    weekDays,
                    today,
                    effectiveEnd,
                  );
                }),
              ),
            ),

            const SizedBox(height: AppDimens.paddingM),

            // Select / Cancel buttons
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppDimens.padding),
              child: Row(
                children: [
                  Expanded(
                    child: AppFilledButton(
                      text: getString(appStr.buttonSelectDateRange,
                          'button_select_date_range'),
                      enabled: _selectedMonday != null && effectiveEnd != null,
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onWeekSelected(
                            _selectedMonday!, effectiveEnd!);
                      },
                    ),
                  ),
                  const SizedBox(width: AppDimens.paddingM),
                  Expanded(
                    child: AppOutlinedButton(
                      text: getString(appStr.buttonCancel, 'button_cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                      borderColor: colors.colorPrimary,
                      textColor: colors.colorPrimary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimens.paddingM),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekRow(
    BuildContext context,
    AppColorPalette colors,
    List<DateTime> weekDays,
    DateTime today,
    DateTime? effectiveEnd,
  ) {
    return SizedBox(
      height: 40,
      child: Row(
        children: weekDays.map((day) {
          final isCurrentMonth = day.month == _focusedMonth.month;
          final isFuture = day.isAfter(today);
          final isToday = day == today;

          final isStart = _selectedMonday != null && day == _selectedMonday;
          final isEnd = effectiveEnd != null && day == effectiveEnd;
          final isInRange = _selectedMonday != null &&
              effectiveEnd != null &&
              !day.isBefore(_selectedMonday!) &&
              !day.isAfter(effectiveEnd);

          final canTap = isCurrentMonth && !isFuture;

          // Background decoration for the range bar
          BoxDecoration rangeDeco = const BoxDecoration();
          if (isInRange) {
            if (isStart && isEnd) {
              rangeDeco = BoxDecoration(
                color: colors.colorPrimary,
                borderRadius: BorderRadius.circular(100),
              );
            } else if (isStart) {
              rangeDeco = BoxDecoration(
                color: colors.colorPrimary.withValues(alpha: 0.15),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(100),
                  bottomLeft: Radius.circular(100),
                ),
              );
            } else if (isEnd) {
              rangeDeco = BoxDecoration(
                color: colors.colorPrimary.withValues(alpha: 0.15),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(100),
                  bottomRight: Radius.circular(100),
                ),
              );
            } else {
              rangeDeco = BoxDecoration(
                color: colors.colorPrimary.withValues(alpha: 0.15),
              );
            }
          }

          // Foreground circle for start/end endpoints
          BoxDecoration? endpointDeco;
          if ((isStart || isEnd) && isInRange && !(isStart && isEnd)) {
            endpointDeco = BoxDecoration(
              color: colors.colorPrimary,
              shape: BoxShape.circle,
            );
          }

          Color textColor;
          if (!canTap) {
            textColor = colors.colorTextHint;
          } else if (isStart || isEnd) {
            textColor = colors.colorButtonText;
          } else if (isInRange) {
            textColor = colors.colorPrimary;
          } else {
            textColor = colors.colorText;
          }

          return Expanded(
            child: GestureDetector(
              onTap: canTap
                  ? () => setState(() {
                        _selectedMonday = _mondayOf(day);
                      })
                  : null,
              child: Container(
                decoration: rangeDeco,
                child: Center(
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: endpointDeco ??
                        (isToday && !isInRange
                            ? BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colors.colorText,
                                  width: 1,
                                ),
                              )
                            : null),
                    child: Center(
                      child: AppText.caption(
                        '${day.day}',
                        color: textColor,
                        fontWeight: (isStart || isEnd)
                            ? FontWeight.w700
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
