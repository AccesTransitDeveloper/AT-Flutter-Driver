import 'package:flutter/material.dart';

import '../../core/localization/app_strings.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text.dart';

class DatePickerBottomSheet extends StatefulWidget {
  final DateTime? initialDate;
  final int maxDays;

  const DatePickerBottomSheet({
    super.key,
    this.initialDate,
    this.maxDays = 30,
  });

  static Future<DateTime?> show({
    required BuildContext context,
    DateTime? initialDate,
    int maxDays = 30,
  }) {
    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DatePickerBottomSheet(
        initialDate: initialDate,
        maxDays: maxDays,
      ),
    );
  }

  @override
  State<DatePickerBottomSheet> createState() =>
      _DatePickerBottomSheetState();
}

class _DatePickerBottomSheetState extends State<DatePickerBottomSheet> {
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;

  late final DateTime _minDate;
  late final DateTime _maxDate;
  late final List<int> _years;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _minDate = DateTime(now.year, now.month, now.day);
    _maxDate = _minDate.add(Duration(days: widget.maxDays));

    final yearCount = _maxDate.year - _minDate.year + 1;
    _years = List.generate(yearCount, (i) => _minDate.year + i);

    // Clamp initial date to valid range
    DateTime initial = widget.initialDate ?? now.add(const Duration(hours: 1));
    if (initial.isBefore(_minDate)) initial = _minDate;
    if (initial.isAfter(_maxDate)) initial = _maxDate;

    _selectedYear = initial.year;
    _selectedMonth = initial.month;
    _selectedDay = initial.day;
  }

  // Months valid for the currently selected year
  List<int> get _availableMonths {
    final first = _selectedYear == _minDate.year ? _minDate.month : 1;
    final last = _selectedYear == _maxDate.year ? _maxDate.month : 12;
    return List.generate(last - first + 1, (i) => first + i);
  }

  // Days valid for the currently selected year+month
  List<int> get _availableDays {
    final daysInMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
    final first = (_selectedYear == _minDate.year &&
            _selectedMonth == _minDate.month)
        ? _minDate.day
        : 1;
    final last = (_selectedYear == _maxDate.year &&
            _selectedMonth == _maxDate.month)
        ? _maxDate.day
        : daysInMonth;
    return List.generate(last - first + 1, (i) => first + i);
  }

  DateTime get _selectedDate =>
      DateTime(_selectedYear, _selectedMonth, _selectedDay);

  bool get _isInvalidDate =>
      _selectedDate.isBefore(_minDate) || _selectedDate.isAfter(_maxDate);

  void _clampMonthAndDay() {
    final months = _availableMonths;
    if (!months.contains(_selectedMonth)) {
      _selectedMonth = months.first;
    }
    final days = _availableDays;
    if (!days.contains(_selectedDay)) {
      _selectedDay = days.first;
    }
  }

  String _getMonthName(int month) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return names[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final months = _availableMonths;
    final days = _availableDays;

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
            // Header
            Padding(
              padding: const EdgeInsets.all(AppDimens.padding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppTextButton(
                    text: getString(appStr.buttonCancel, 'button_cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  AppText.title(
                    getString(appStr.headingSelectDate, 'heading_select_date'),
                    fontWeight: FontWeight.w600,
                  ),
                  AppTextButton(
                    text: getString(appStr.buttonDone, 'button_done'),
                    textColor: _isInvalidDate ? colors.colorTextHint : null,
                    onPressed: _isInvalidDate
                        ? null
                        : () => Navigator.pop(context, _selectedDate),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: colors.colorBackgroundGray),

            // Wheels
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  // Day
                  Expanded(
                    child: ListWheelScrollView.useDelegate(
                      key: ValueKey('day-$_selectedYear-$_selectedMonth'),
                      itemExtent: 40,
                      perspective: 0.005,
                      diameterRatio: 1.5,
                      physics: const FixedExtentScrollPhysics(),
                      controller: FixedExtentScrollController(
                        initialItem: days.indexOf(_selectedDay).clamp(0, days.length - 1),
                      ),
                      onSelectedItemChanged: (index) {
                        setState(() => _selectedDay = days[index]);
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: days.length,
                        builder: (ctx, index) {
                          final isSelected = days[index] == _selectedDay;
                          return Center(
                            child: AppText.body(
                              days[index].toString().padLeft(2, '0'),
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Month
                  Expanded(
                    child: ListWheelScrollView.useDelegate(
                      key: ValueKey('month-$_selectedYear'),
                      itemExtent: 40,
                      perspective: 0.005,
                      diameterRatio: 1.5,
                      physics: const FixedExtentScrollPhysics(),
                      controller: FixedExtentScrollController(
                        initialItem: months.indexOf(_selectedMonth).clamp(0, months.length - 1),
                      ),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedMonth = months[index];
                          _clampMonthAndDay();
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: months.length,
                        builder: (ctx, index) {
                          final isSelected = months[index] == _selectedMonth;
                          return Center(
                            child: AppText.body(
                              _getMonthName(months[index]),
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Year
                  Expanded(
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 40,
                      perspective: 0.005,
                      diameterRatio: 1.5,
                      physics: const FixedExtentScrollPhysics(),
                      controller: FixedExtentScrollController(
                        initialItem: _years.indexOf(_selectedYear).clamp(0, _years.length - 1),
                      ),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedYear = _years[index];
                          _clampMonthAndDay();
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: _years.length,
                        builder: (ctx, index) {
                          final isSelected = _years[index] == _selectedYear;
                          return Center(
                            child: AppText.body(
                              _years[index].toString(),
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.padding),
          ],
        ),
      ),
    );
  }
}
