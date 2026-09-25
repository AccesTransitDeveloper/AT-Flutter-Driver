import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Result of a permission request
enum PermissionResult {
  /// Permission was granted
  granted,

  /// Permission was denied (can ask again)
  denied,

  /// Permission was permanently denied (must go to settings)
  permanentlyDenied,

  /// Permission is restricted (iOS only - parental controls, etc.)
  restricted,

  /// Permission status is limited (iOS 14+ photo library)
  limited,
}

/// Manager for handling app permissions across Android and iOS
class PermissionManager {
  const PermissionManager._();

  static const PermissionManager instance = PermissionManager._();

  // ============ Location Permissions ============

  /// Check if location permission is granted
  Future<bool> isLocationGranted() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  /// Check current location permission status
  Future<PermissionResult> getLocationStatus() async {
    final status = await Permission.location.status;
    return _mapStatus(status);
  }

  /// Request location permission
  Future<PermissionResult> requestLocation() async {
    final status = await Permission.location.request();
    return _mapStatus(status);
  }

  /// Request location permission with "when in use" access
  Future<PermissionResult> requestLocationWhenInUse() async {
    final status = await Permission.locationWhenInUse.request();
    return _mapStatus(status);
  }

  /// Request "always" location permission (background location)
  /// Note: On Android, you must first have "when in use" permission
  Future<PermissionResult> requestLocationAlways() async {
    final status = await Permission.locationAlways.request();
    return _mapStatus(status);
  }

  // ============ Camera Permission ============

  /// Check if camera permission is granted
  Future<bool> isCameraGranted() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// Request camera permission
  Future<PermissionResult> requestCamera() async {
    final status = await Permission.camera.request();
    return _mapStatus(status);
  }

  // ============ Microphone Permission ============

  /// Check if microphone permission is granted
  Future<bool> isMicrophoneGranted() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  /// Request microphone permission
  Future<PermissionResult> requestMicrophone() async {
    final status = await Permission.microphone.request();
    return _mapStatus(status);
  }

  // ============ Photos/Storage Permission ============

  /// Check if photos permission is granted
  Future<bool> isPhotosGranted() async {
    if (Platform.isIOS) {
      final status = await Permission.photos.status;
      return status.isGranted || status.isLimited;
    } else {
      // Android 13+ uses photos permission, older uses storage
      final status = await Permission.photos.status;
      if (status.isGranted) return true;

      final storageStatus = await Permission.storage.status;
      return storageStatus.isGranted;
    }
  }

  /// Request photos permission
  Future<PermissionResult> requestPhotos() async {
    if (Platform.isIOS) {
      final status = await Permission.photos.request();
      return _mapStatus(status);
    } else {
      // Try photos first (Android 13+), fall back to storage
      var status = await Permission.photos.request();
      if (status.isGranted) return PermissionResult.granted;

      status = await Permission.storage.request();
      return _mapStatus(status);
    }
  }

  // ============ Notification Permission ============

  /// Check if notification permission is granted
  Future<bool> isNotificationGranted() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  /// Request notification permission
  Future<PermissionResult> requestNotification() async {
    final status = await Permission.notification.request();
    return _mapStatus(status);
  }

  // ============ Contacts Permission ============

  /// Check if contacts permission is granted
  Future<bool> isContactsGranted() async {
    final status = await Permission.contacts.status;
    return status.isGranted;
  }

  /// Request contacts permission
  Future<PermissionResult> requestContacts() async {
    final status = await Permission.contacts.request();
    return _mapStatus(status);
  }

  // ============ Generic Methods ============

  /// Request multiple permissions at once
  Future<Map<Permission, PermissionResult>> requestMultiple(
    List<Permission> permissions,
  ) async {
    final statuses = await permissions.request();
    return statuses.map((key, value) => MapEntry(key, _mapStatus(value)));
  }

  /// Check if a specific permission is granted
  Future<bool> isGranted(Permission permission) async {
    final status = await permission.status;
    return status.isGranted;
  }

  /// Request a specific permission
  Future<PermissionResult> request(Permission permission) async {
    final status = await permission.request();
    return _mapStatus(status);
  }

  /// Open app settings
  /// Useful when permission is permanently denied
  Future<bool> openSettings() async {
    return await openAppSettings();
  }

  /// Check if location services are enabled on the device
  Future<bool> isLocationServiceEnabled() async {
    return await Permission.location.serviceStatus.isEnabled;
  }

  // ============ Helper Methods ============

  /// Map permission_handler status to our PermissionResult
  PermissionResult _mapStatus(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return PermissionResult.granted;
      case PermissionStatus.denied:
        return PermissionResult.denied;
      case PermissionStatus.permanentlyDenied:
        return PermissionResult.permanentlyDenied;
      case PermissionStatus.restricted:
        return PermissionResult.restricted;
      case PermissionStatus.limited:
        return PermissionResult.limited;
      case PermissionStatus.provisional:
        return PermissionResult.granted;
    }
  }

  /// Log permission result for debugging
  void logResult(String permissionName, PermissionResult result) {
    debugPrint('Permission [$permissionName]: ${result.name}');
  }
}
