import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Embeds Google's turn-by-turn Navigation SDK, via the platform view
/// registered as `InAppNavigationView`/`InAppNavigationViewFactory` on each
/// platform (Kotlin: android/app/.../InAppNavigationView.kt,
/// Swift: ios/Runner/InAppNavigationView.swift). Mirrors native's
/// `NavigationMapView` (Android) / `startGoogleNavigation` (iOS): guidance to
/// [latitude]/[longitude] starts as soon as the view is created.
///
/// Only ever mounted when the map provider is Google — see
/// [TripViewModel.isInAppNavigationAvailable] — so Android/iOS are the only
/// platforms that matter here.
class InAppNavigationView extends StatefulWidget {
  final double latitude;
  final double longitude;

  const InAppNavigationView({
    required this.latitude,
    required this.longitude,
    super.key,
  });

  @override
  State<InAppNavigationView> createState() => _InAppNavigationViewState();
}

class _InAppNavigationViewState extends State<InAppNavigationView> {
  static const String _viewType = 'com.accessible.provider/in_app_navigation';

  MethodChannel? _channel;

  @override
  void didUpdateWidget(covariant InAppNavigationView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The booking's next stop can change while guidance is running (a
    // multi-stop trip advancing to its next leg) — retarget in place rather
    // than tearing down and recreating the native navigator.
    if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude) {
      _channel?.invokeMethod('setDestination', {
        'latitude': widget.latitude,
        'longitude': widget.longitude,
      });
    }
  }

  void _onPlatformViewCreated(int id) {
    _channel = MethodChannel('${_viewType}_$id');
  }

  @override
  Widget build(BuildContext context) {
    final creationParams = <String, dynamic>{
      'latitude': widget.latitude,
      'longitude': widget.longitude,
    };

    if (Platform.isAndroid) {
      return AndroidView(
        viewType: _viewType,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    }
    if (Platform.isIOS) {
      return UiKitView(
        viewType: _viewType,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    }
    // Unreachable in practice — gated to mapType == google before this is
    // ever mounted, and the SDK only ships for Android/iOS.
    return const SizedBox.shrink();
  }
}
