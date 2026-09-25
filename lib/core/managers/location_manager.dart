import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'permission_manager.dart';

/// Location data model
class LocationData {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? altitude;
  final double? speed;
  final double? heading;
  final DateTime timestamp;

  const LocationData({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    this.speed,
    this.heading,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'LocationData(lat: $latitude, lng: $longitude, accuracy: $accuracy)';
  }
}

/// Result of a location request
sealed class LocationResult {
  const LocationResult();
}

/// Location was successfully retrieved
class LocationSuccess extends LocationResult {
  final LocationData location;
  const LocationSuccess(this.location);
}

/// Location permission was denied
class LocationPermissionDenied extends LocationResult {
  final PermissionResult permissionResult;
  const LocationPermissionDenied(this.permissionResult);
}

/// Location services are disabled on device
class LocationServiceDisabled extends LocationResult {
  const LocationServiceDisabled();
}

/// An error occurred while getting location
class LocationError extends LocationResult {
  final String message;
  const LocationError(this.message);
}

/// Manager for handling location services
class LocationManager {
  const LocationManager._();

  static const LocationManager instance = LocationManager._();

  final PermissionManager _permissionManager = PermissionManager.instance;

  /// Get current location
  /// Handles permission checking and location service status
  /// Uses a default timeout of 10 seconds to prevent ANR
  Future<LocationResult> getCurrentLocation({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    // Check if location services are enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled');
      return const LocationServiceDisabled();
    }

    // Check/request permission
    final permissionResult = await _permissionManager.requestLocation();
    if (permissionResult != PermissionResult.granted) {
      debugPrint('Location permission not granted: $permissionResult');
      return LocationPermissionDenied(permissionResult);
    }

    // Try last known position first (instant, prevents ANR)
    try {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        debugPrint('Using last known location: ${lastKnown.latitude}, ${lastKnown.longitude}');
        return LocationSuccess(_positionToLocationData(lastKnown));
      }
    } catch (e) {
      debugPrint('Last known position failed: $e');
    }

    // Fall back to current position with timeout
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: accuracy,
          timeLimit: timeout,
        ),
      );

      final locationData = _positionToLocationData(position);
      debugPrint('Location retrieved: $locationData');
      return LocationSuccess(locationData);
    } catch (e) {
      debugPrint('Error getting location: $e');
      return LocationError(e.toString());
    }
  }

  /// Get last known location (faster, but may be stale)
  Future<LocationResult> getLastKnownLocation() async {
    // Check permission first
    final isGranted = await _permissionManager.isLocationGranted();
    if (!isGranted) {
      final permissionResult = await _permissionManager.getLocationStatus();
      return LocationPermissionDenied(permissionResult);
    }

    try {
      final position = await Geolocator.getLastKnownPosition();
      if (position == null) {
        return const LocationError('No last known location available');
      }

      return LocationSuccess(_positionToLocationData(position));
    } catch (e) {
      return LocationError(e.toString());
    }
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Open location settings (device settings)
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings (for permissions)
  Future<bool> openAppSettings() async {
    return await _permissionManager.openSettings();
  }

  /// Calculate distance between two points in meters
  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  /// Convert Position to LocationData
  LocationData _positionToLocationData(Position position) {
    return LocationData(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      altitude: position.altitude,
      speed: position.speed,
      heading: position.heading,
      timestamp: position.timestamp,
    );
  }
}
