import 'dart:async';

import 'package:flutter/material.dart';

/// A widget that detects multiple rapid taps before triggering a callback.
///
/// Matches the Kotlin `detectTapGesture` behavior:
/// counts taps, resets after [tapTimeoutMillis] of no taps,
/// fires [onMultiTap] when [requiredTaps] is reached.
class MultiTapDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback onMultiTap;
  final int requiredTaps;
  final int tapTimeoutMillis;

  const MultiTapDetector({
    super.key,
    required this.child,
    required this.onMultiTap,
    this.requiredTaps = 5,
    this.tapTimeoutMillis = 500,
  });

  @override
  State<MultiTapDetector> createState() => _MultiTapDetectorState();
}

class _MultiTapDetectorState extends State<MultiTapDetector> {
  int _tapCount = 0;
  Timer? _resetTimer;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  void _onTap() {
    _tapCount++;
    _resetTimer?.cancel();

    if (_tapCount >= widget.requiredTaps) {
      _tapCount = 0;
      widget.onMultiTap();
      return;
    }

    _resetTimer = Timer(
      Duration(milliseconds: widget.tapTimeoutMillis),
      () => _tapCount = 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      child: widget.child,
    );
  }
}
