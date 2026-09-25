import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../models/responses/socket/socket_driver_live_location_response.dart';
import '../managers/location_service_manager.dart';
import '../preferences/shared_preference_manager.dart';

/// A filtered GPS location update — used for UI map pin movement.
class DriverLocation {
  final double latitude;
  final double longitude;
  final double speed;
  final double bearing;
  final int time;

  const DriverLocation({
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.bearing,
    required this.time,
  });
}

/// Provides filtered driver location for UI (map pin) and ack responses for
/// zone queue updates.
///
/// Server communication is handled entirely by the native LocationService
/// (Kotlin/Swift) — this class is UI-only.
///
/// GPS (Geolocator) lifecycle is independent of online/offline state.
/// Call [startGps] / [stopGps] from screen ViewModels.
/// Call [startAckListening] / [stopAckListening] when going online/offline.
class DriverLocationProvider {
  static DriverLocationProvider? _instance;
  static DriverLocationProvider get instance =>
      _instance ??= DriverLocationProvider._();

  DriverLocationProvider._();

  final _filteredController = StreamController<DriverLocation>.broadcast();
  final _ackController =
      StreamController<SocketDriverLiveLocationResponse>.broadcast();

  StreamSubscription<Position>? _geolocatorSubscription;
  StreamSubscription<Map<String, dynamic>>? _ackSubscription;
  SharedPreferenceManager? _sharedPref;

  DriverLocation? _lastLocation;

  /// Global location notifier — screens observe this for immediate updates.
  /// Seeded from SharedPrefs on cold restart.
  final ValueNotifier<DriverLocation?> locationNotifier = ValueNotifier(null);

  /// Filtered location stream — GPS updates for map pin.
  /// Replays the last known location to new subscribers immediately.
  Stream<DriverLocation> get locationStream async* {
    final last = _lastLocation;
    if (last != null) yield last;
    yield* _filteredController.stream;
  }

  /// Ack stream from server — zone queue number, distanceList, etc.
  Stream<SocketDriverLiveLocationResponse> get ackStream =>
      _ackController.stream;

  DriverLocation? get lastLocation => _lastLocation;

  // ── GPS (Geolocator) ─────────────────────────────────────────────

  /// Start listening to GPS for UI map pin movement.
  ///
  /// Call from screen ViewModels (Home, Trip) regardless of online/offline.
  /// Safe to call multiple times — cancels any previous subscription first.
  void startGps(SharedPreferenceManager sharedPref) {
    _sharedPref = sharedPref;

    // Seed map pin from SharedPrefs immediately (cold restart UX)
    if (_lastLocation == null) {
      final saved = sharedPref.getLastDriverLocation();
      if (saved != null) {
        final seeded = DriverLocation(
          latitude: saved.latitude,
          longitude: saved.longitude,
          speed: 0,
          bearing: 0,
          time: DateTime.now().millisecondsSinceEpoch,
        );
        _lastLocation = seeded;
        locationNotifier.value = seeded;
      }
    }

    _geolocatorSubscription?.cancel();
    _geolocatorSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // emit only when moved >5m
      ),
    ).listen(
      _onGeolocatorPosition,
      onError: (e) =>
          debugPrint('DriverLocationProvider: geolocator error -> $e'),
    );
  }

  /// Stop GPS updates. Call from the screen ViewModel that owns GPS lifecycle.
  void stopGps() {
    _geolocatorSubscription?.cancel();
    _geolocatorSubscription = null;
  }

  // ── Ack (server responses) ────────────────────────────────────────

  /// Start listening to ack events from the native location service.
  ///
  /// Call when driver goes online.
  void startAckListening(LocationServiceManager manager) {
    _ackSubscription?.cancel();
    _ackSubscription = manager.ackStream.listen(_onAckEvent);
  }

  /// Stop listening to ack events. Call when driver goes offline.
  void stopAckListening() {
    _ackSubscription?.cancel();
    _ackSubscription = null;
  }

  // ── State reset ───────────────────────────────────────────────────

  /// Reset last location on offline/online cycle.
  void reset() {
    _lastLocation = null;
    locationNotifier.value = null;
  }

  // ── Internal ─────────────────────────────────────────────────────

  void _onGeolocatorPosition(Position position) {
    // Geolocator reports -1 for speed/heading when they are unavailable;
    // Android's Location (what native sends) reports 0. Passing -1 through
    // gave the server a payload it never sees from the native apps.
    final location = DriverLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      speed: position.speed < 0 ? 0 : position.speed,
      bearing: position.heading < 0 ? 0 : position.heading,
      time: position.timestamp.millisecondsSinceEpoch,
    );

    _lastLocation = location;
    locationNotifier.value = location;
    _filteredController.add(location);

    _sharedPref?.setLastDriverLocation(location.latitude, location.longitude);
  }

  void _onAckEvent(Map<String, dynamic> event) {
    try {
      final jsonStr = event['data'] as String?;
      if (jsonStr == null || jsonStr.isEmpty) return;
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      final response = SocketDriverLiveLocationResponse.fromJson(json);
      _ackController.add(response);
    } catch (e) {
      debugPrint('DriverLocationProvider: ack parse error -> $e');
    }
  }

  void dispose() {
    _geolocatorSubscription?.cancel();
    _ackSubscription?.cancel();
    _filteredController.close();
    _ackController.close();
  }
}

final driverLocationProvider = Provider<DriverLocationProvider>((ref) {
  return DriverLocationProvider.instance;
});
