import 'package:intl/intl.dart' as intl;

import '../constants/app_constants.dart';

/// Utility class for date formatting throughout the app
class AppDateUtils {
  static const List<String> _monthsShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  static const List<String> _monthsFull = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  /// Parse date string from API
  static DateTime? parse(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Format date using specified DateFormat enum
  static String format(DateTime? date, DateFormat format) {
    if (date == null) return '';

    switch (format) {
      case DateFormat.dateOnlyFormat:
        return _formatDateOnly(date);
      case DateFormat.dateFormatWithSpace:
        return _formatDateWithSpace(date);
      case DateFormat.dateMonthWithSpace:
        return _formatDateMonthWithSpace(date);
      case DateFormat.dateTimeFormat:
        return _formatDateTime(date);
      case DateFormat.dayMonthTimeYearFormat:
        return _formatDayMonthTimeYear(date);
      case DateFormat.hourMinuteFormat:
        return _formatHourMinute(date);
      case DateFormat.dateMonthHourMinuteFormat:
        return _formatDateMonthHourMinute(date);
      case DateFormat.weekdayAndTime:
        return _formatWeekdayAndTime(date);
      case DateFormat.apiFormat:
      case DateFormat.apiDateFormat:
        return date.toIso8601String();
    }
  }

  /// Format date string from API using specified DateFormat enum
  /// Converts UTC to local time before formatting
  static String formatString(String? dateString, DateFormat format) {
    final date = convertUtcToLocal(dateString ?? '');
    return AppDateUtils.format(date, format);
  }

  static int _get12Hour(int hour) {
    if (hour == 0) return 12;
    if (hour > 12) return hour - 12;
    return hour;
  }

  static String _getPeriod(int hour) => hour >= 12 ? 'PM' : 'AM';

  /// dd-MM-yyyy
  static String _formatDateOnly(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day-$month-${date.year}';
  }

  /// dd MMM yyyy
  static String _formatDateWithSpace(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    return '$day ${_monthsShort[date.month - 1]} ${date.year}';
  }

  /// dd MMM
  static String _formatDateMonthWithSpace(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    return '$day ${_monthsShort[date.month - 1]}';
  }

  /// dd-MM-yyyy hh:mm a
  static String _formatDateTime(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = _get12Hour(date.hour).toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day-$month-${date.year} $hour:$minute ${_getPeriod(date.hour)}';
  }

  /// d MMM yyyy, hh:mm a
  static String _formatDayMonthTimeYear(DateTime date) {
    final hour = _get12Hour(date.hour).toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${_monthsShort[date.month - 1]} ${date.year}, $hour:$minute ${_getPeriod(date.hour)}';
  }

  /// hh:mm a
  static String _formatHourMinute(DateTime date) {
    final hour = _get12Hour(date.hour).toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${_getPeriod(date.hour)}';
  }

  /// dd MMMM, hh:mm a
  static String _formatDateMonthHourMinute(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final hour = _get12Hour(date.hour).toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day ${_monthsFull[date.month - 1]}, $hour:$minute ${_getPeriod(date.hour)}';
  }

  /// EEE hh:mm a
  static String _formatWeekdayAndTime(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final hour = _get12Hour(date.hour).toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${weekdays[date.weekday - 1]} $hour:$minute ${_getPeriod(date.hour)}';
  }

  /// Format date to yyyy-MM-dd (for API submission)
  static String toApiDateString(DateTime? date) {
    if (date == null) return '';
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  static const String _mmmDdYyyy = 'MMM dd yyyy';

  static String? dateFormationForSubmit(String? dateString) {
    if (dateString == null) return null;
    try {
      final inputFormat = intl.DateFormat(_mmmDdYyyy);
      var date = inputFormat.parse(dateString);
      date = addTimeToDate(date, 23, 59, 59);
      return convertLocalToUtc(date);
    } catch (e) {
      return null;
    }
  }

  static DateTime? convertUtcToLocal(String utcDateTime) {
    try {
      return DateTime.parse(utcDateTime).toUtc().toLocal();
    } catch (e) {
      return null;
    }
  }

  static String convertLocalToUtc(DateTime localDateTime) {
    try {
      return localDateTime.toUtc().toIso8601String();
    } catch (e) {
      return '';
    }
  }

  static DateTime addTimeToDate(DateTime date, int hours, int minutes, int seconds) {
    return date.add(Duration(hours: hours, minutes: minutes, seconds: seconds));
  }
}
