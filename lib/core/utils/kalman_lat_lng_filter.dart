import 'dart:math' as math;

/// Kalman filter for smoothing GPS latitude/longitude readings.
/// Ported from Kotlin: KalmanLatLongFilter.kt
class KalmanLatLngFilter {
  final double _qMetersPerSecond;
  static const double _minAccuracy = 1.0;

  int _timeStampMilliseconds = 0;
  double _lat = 0.0;
  double _lng = 0.0;
  double _variance = -1.0; // Negative means uninitialized

  KalmanLatLngFilter({required double qMetersPerSecond})
      : _qMetersPerSecond = qMetersPerSecond;

  double get latitude => _lat;
  double get longitude => _lng;
  double get accuracy => math.sqrt(_variance);

  /// Process a new GPS measurement through the Kalman filter.
  /// Returns the smoothed (latitude, longitude).
  ({double latitude, double longitude}) process({
    required double latitude,
    required double longitude,
    required double accuracy,
    required int timeStampMilliseconds,
  }) {
    var acc = accuracy < _minAccuracy ? _minAccuracy : accuracy;

    if (_variance < 0) {
      // Uninitialized — use first reading as-is
      _timeStampMilliseconds = timeStampMilliseconds;
      _lat = latitude;
      _lng = longitude;
      _variance = acc * acc;
    } else {
      final timeInc = timeStampMilliseconds - _timeStampMilliseconds;
      if (timeInc > 0) {
        // Increase uncertainty over time
        _variance +=
            timeInc * _qMetersPerSecond * _qMetersPerSecond / 1000;
        _timeStampMilliseconds = timeStampMilliseconds;
      }

      // Kalman gain
      final k = _variance / (_variance + acc * acc);

      // Apply gain
      _lat += k * (latitude - _lat);
      _lng += k * (longitude - _lng);

      // Update covariance
      _variance = (1 - k) * _variance;
    }

    return (latitude: _lat, longitude: _lng);
  }
}
