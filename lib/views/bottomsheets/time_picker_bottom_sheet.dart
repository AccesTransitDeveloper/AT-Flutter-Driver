import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/snackbar_utils.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text.dart';

class TimePickerBottomSheet extends StatefulWidget {
  final DateTime selectedDate;
  final int bufferMinutes;

  const TimePickerBottomSheet({
    super.key,
    required this.selectedDate,
    this.bufferMinutes = 30,
  });

  /// Shows the time picker and returns selected [TimeOfDay] or null.
  static Future<TimeOfDay?> show({
    required BuildContext context,
    required DateTime selectedDate,
    int bufferMinutes = 30,
  }) {
    return showModalBottomSheet<TimeOfDay>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TimePickerBottomSheet(
        selectedDate: selectedDate,
        bufferMinutes: bufferMinutes,
      ),
    );
  }

  @override
  State<TimePickerBottomSheet> createState() => _TimePickerBottomSheetState();
}

class _TimePickerBottomSheetState extends State<TimePickerBottomSheet> {
  late TimeOfDay _pickerTime;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final withBuffer = now.add(Duration(minutes: widget.bufferMinutes));
    _pickerTime = TimeOfDay(hour: withBuffer.hour, minute: withBuffer.minute);
  }

  bool get _isInPast {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
    );
    // Only validate for today
    if (selected.isAfter(today)) return false;

    final selectedDt = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      _pickerTime.hour,
      _pickerTime.minute,
    );
    final minAllowed = now.add(Duration(minutes: widget.bufferMinutes));
    return selectedDt.isBefore(minAllowed);
  }

  void _onDone() {
    if (_isInPast) {
      context.showErrorSnackBar(
        'Please select a time at least ${widget.bufferMinutes} minutes from now',
      );
      return;
    }
    Navigator.pop(context, _pickerTime);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.colorBackground,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimens.paddingL),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: AppDimens.paddingM),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.colorBackgroundGray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppDimens.paddingM),

            // Title
            AppText.title(
              'Select Time',
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: AppDimens.paddingM),
            Divider(height: 1, color: colors.colorBackgroundGray),

            // Wheel pickers: Hour | Minute | AM/PM
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  // Hour (1–12)
                  Expanded(
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 40,
                      perspective: 0.005,
                      diameterRatio: 1.5,
                      physics: const FixedExtentScrollPhysics(),
                      controller: FixedExtentScrollController(
                        initialItem: (_pickerTime.hourOfPeriod == 0
                                ? 12
                                : _pickerTime.hourOfPeriod) -
                            1,
                      ),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          final hour12 = index + 1;
                          final isPM = _pickerTime.period == DayPeriod.pm;
                          int hour24;
                          if (isPM) {
                            hour24 = hour12 == 12 ? 12 : hour12 + 12;
                          } else {
                            hour24 = hour12 == 12 ? 0 : hour12;
                          }
                          _pickerTime = TimeOfDay(
                              hour: hour24, minute: _pickerTime.minute);
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 12,
                        builder: (ctx, index) {
                          final hour = index + 1;
                          final currentHour12 =
                              _pickerTime.hourOfPeriod == 0
                                  ? 12
                                  : _pickerTime.hourOfPeriod;
                          final isSelected = currentHour12 == hour;
                          return Center(
                            child: AppText.body(
                              hour.toString().padLeft(2, '0'),
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? colors.colorText
                                  : colors.colorTextHint,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Separator
                  AppText.title(':', fontWeight: FontWeight.w600),

                  // Minute (0–59)
                  Expanded(
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 40,
                      perspective: 0.005,
                      diameterRatio: 1.5,
                      physics: const FixedExtentScrollPhysics(),
                      controller: FixedExtentScrollController(
                        initialItem: _pickerTime.minute,
                      ),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _pickerTime = TimeOfDay(
                              hour: _pickerTime.hour, minute: index);
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 60,
                        builder: (ctx, index) {
                          final isSelected = _pickerTime.minute == index;
                          return Center(
                            child: AppText.body(
                              index.toString().padLeft(2, '0'),
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? colors.colorText
                                  : colors.colorTextHint,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // AM / PM
                  Expanded(
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 40,
                      perspective: 0.005,
                      diameterRatio: 1.5,
                      physics: const FixedExtentScrollPhysics(),
                      controller: FixedExtentScrollController(
                        initialItem:
                            _pickerTime.period == DayPeriod.am ? 0 : 1,
                      ),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          final isPM = index == 1;
                          int newHour;
                          if (isPM && _pickerTime.hour < 12) {
                            newHour = _pickerTime.hour + 12;
                          } else if (!isPM && _pickerTime.hour >= 12) {
                            newHour = _pickerTime.hour - 12;
                          } else {
                            newHour = _pickerTime.hour;
                          }
                          _pickerTime = TimeOfDay(
                              hour: newHour, minute: _pickerTime.minute);
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 2,
                        builder: (ctx, index) {
                          final label = index == 0 ? 'AM' : 'PM';
                          final isSelected = (index == 0 &&
                                  _pickerTime.period == DayPeriod.am) ||
                              (index == 1 &&
                                  _pickerTime.period == DayPeriod.pm);
                          return Center(
                            child: AppText.body(
                              label,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? colors.colorText
                                  : colors.colorTextHint,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Buttons
            Padding(
              padding: const EdgeInsets.all(AppDimens.padding),
              child: Row(
                children: [
                  Expanded(
                    child: AppFilledButton(
                      text: 'Done',
                      onPressed: _onDone,
                    ),
                  ),
                  const SizedBox(width: AppDimens.paddingM),
                  Expanded(
                    child: AppOutlinedButton(
                      text: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
