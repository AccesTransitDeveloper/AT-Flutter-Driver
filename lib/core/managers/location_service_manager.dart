import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manages the native platform location service (foreground service on Android,
/// background location on iOS) via MethodChannel/EventChannel.
class LocationServiceManager {
  static const _methodChannel = MethodChannel('com.accessible.provider/location_service');
  static const _eventChannel = EventChannel('com.accessible.provider/location_updates');

  static LocationServiceManager? _instance;
  static LocationServiceManager get instance =>
      _instance ??= LocationServiceManager._();

  LocationServiceManager._();

  StreamSubscription<dynamic>? _eventSubscription;

  /// GPS location updates — consumed by DriverLocationProvider for UI map pin.
  final _locationController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get locationStream => _locationController.stream;

  /// Ack events from server — forwarded from Kotlin via EventChannel.
  /// The event map contains `"data"` key with the full JSON string of
  /// SocketDriverLiveLocationResponse.
  final _ackController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get ackStream => _ackController.stream;

  /// Start the native location service.
  /// [serverUrl] is saved natively so the service can use it after app kill.
  Future<bool> startService({required String serverUrl}) async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('startService', {
            'serverUrl': serverUrl,
          }) ??
          false;
      if (result) {
        _startListeningEvents();
      }
      debugPrint('LocationServiceManager: startService -> $result');
      return result;
    } on PlatformException catch (e) {
      debugPrint('LocationServiceManager: startService error -> ${e.message}');
      return false;
    }
  }

  /// Stop the native location service.
  Future<bool> stopService() async {
    try {
      _stopListeningEvents();
      final result =
          await _methodChannel.invokeMethod<bool>('stopService') ?? false;
      debugPrint('LocationServiceManager: stopService -> $result');
      return result;
    } on PlatformException catch (e) {
      debugPrint('LocationServiceManager: stopService error -> ${e.message}');
      return false;
    }
  }

  /// Check if the native location service is currently running.
  Future<bool> isRunning() async {
    try {
      return await _methodChannel.invokeMethod<bool>('isRunning') ?? false;
    } on PlatformException catch (e) {
      debugPrint('LocationServiceManager: isRunning error -> ${e.message}');
      return false;
    }
  }

  /// Notify the native service whether the driver has an active booking.
  /// When true, locations are buffered in SQLite and flushed on ack.
  Future<void> setHasBooking(bool value) async {
    try {
      await _methodChannel.invokeMethod('setHasBooking', {'value': value});
      debugPrint('LocationServiceManager: setHasBooking -> $value');
    } on PlatformException catch (e) {
      debugPrint('LocationServiceManager: setHasBooking error -> ${e.message}');
    }
  }

  void _startListeningEvents() {
    _eventSubscription?.cancel();
    _eventSubscription = _eventChannel.receiveBroadcastStream().listen(
      (data) {
        if (data is! Map) return;
        final event = Map<String, dynamic>.from(data);
        final type = event['type'] as String?;

        if (type == 'ack') {
          debugPrint('LocationServiceManager: ack received');
          _ackController.add(event);
        } else {
          // 'location' type or legacy events without type field
          debugPrint(
              'LocationServiceManager: location -> ${event['latitude']}, ${event['longitude']}');
          _locationController.add(event);
        }
      },
      onError: (error) {
        debugPrint('LocationServiceManager: stream error -> $error');
      },
    );
  }

  void _stopListeningEvents() {
    _eventSubscription?.cancel();
    _eventSubscription = null;
  }

  void dispose() {
    _stopListeningEvents();
    _locationController.close();
    _ackController.close();
  }
}

final locationServiceManagerProvider = Provider<LocationServiceManager>((ref) {
  return LocationServiceManager.instance;
});
