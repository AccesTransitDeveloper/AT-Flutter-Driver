import '../localization/app_strings.dart';

/// Formatting for the invoice's duration fields.
///
/// The API reports `actual.time`, `waitingTime`, `stopWaitingTime` and
/// `trafficTime` in **seconds** — native reads them as such throughout
/// (`InvoiceViewModel.kt`: `TimeUtil.formattedTime(seconds = actual.time...)`,
/// which then calls `TimeUnit.SECONDS.toMinutes`). Both Flutter call sites had
/// been treating the raw number as minutes, so every duration was shown 60×
/// too long — a two-minute trip read as "1 hr 59 mins".
class TimeUtil {
  const TimeUtil._();

  /// Whole minutes in [seconds], truncated the way `TimeUnit.SECONDS.toMinutes`
  /// does — 119 seconds is 1 minute, not 2.
  static int minutesFromSeconds(num seconds) => seconds ~/ 60;

  /// "45 mins" below the hour, "2 hr 5 mins" above it. Empty for nothing.
  static String formatSeconds(num? seconds) {
    final mins = minutesFromSeconds(seconds ?? 0);
    if (mins <= 0) return '';

    final minUnit =
        getString(appStr.descriptionMinutesUnit, 'description_minutes_unit');
    if (mins < 60) return '$mins $minUnit';

    final hrUnit =
        getString(appStr.descriptionHoursUnit, 'description_hours_unit');
    final hours = mins ~/ 60;
    final remaining = mins % 60;
    return remaining > 0
        ? '$hours $hrUnit $remaining $minUnit'
        : '$hours $hrUnit';
  }

  /// Compact form for the in-trip strip: "45min" / "2h 5min".
  static String? formatSecondsCompact(num? seconds) {
    final mins = minutesFromSeconds(seconds ?? 0);
    if (mins <= 0) return null;
    return mins >= 60 ? '${mins ~/ 60}h ${mins % 60}min' : '${mins}min';
  }
}
