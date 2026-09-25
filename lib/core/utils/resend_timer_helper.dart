import 'dart:async';

/// Helper class for managing OTP resend timer
class ResendTimerHelper {
  Timer? _timer;
  final void Function(int seconds) onTick;
  final void Function()? onComplete;

  ResendTimerHelper({
    required this.onTick,
    this.onComplete,
  });

  /// Start the countdown timer
  void start(int seconds) {
    cancel();
    var remaining = seconds;
    onTick(remaining);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remaining--;
      if (remaining > 0) {
        onTick(remaining);
      } else {
        timer.cancel();
        onTick(0);
        onComplete?.call();
      }
    });
  }

  /// Cancel the timer
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Format seconds to MM:SS format
  static String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Dispose the timer
  void dispose() {
    cancel();
  }
}
