import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Manages Firebase Cloud Messaging topic subscriptions for mass notifications.
///
/// Topics format: DRIVER_{PLATFORM}_{locationId}_{businessType}
/// Example: DRIVER_ANDROID_64f1234abc_1
class FirebaseTopicManager {
  static FirebaseTopicManager? _instance;
  static FirebaseTopicManager get instance =>
      _instance ??= FirebaseTopicManager._();

  FirebaseTopicManager._();

  final _messaging = FirebaseMessaging.instance;

  String? _subscribedCityTopic;
  String? _subscribedCountryTopic;
  String? _subscribedCityOnlyTopic;
  String? _subscribedCountryOnlyTopic;

  String get _platform => Platform.isIOS ? 'IOS' : 'ANDROID';

  /// Subscribe to city/country-only topics after login (without business type).
  /// Matches Kotlin: DRIVER_{PLATFORM}_{locationId}
  Future<void> subscribeToLoginTopics({
    required String? cityId,
    required String? countryId,
  }) async {
    try {
      if (cityId != null && cityId.isNotEmpty) {
        _subscribedCityOnlyTopic = 'DRIVER_${_platform}_$cityId';
        await _messaging.subscribeToTopic(_subscribedCityOnlyTopic!);
        debugPrint(
            'FirebaseTopicManager: subscribed to $_subscribedCityOnlyTopic');
      }

      if (countryId != null && countryId.isNotEmpty) {
        _subscribedCountryOnlyTopic = 'DRIVER_${_platform}_$countryId';
        await _messaging.subscribeToTopic(_subscribedCountryOnlyTopic!);
        debugPrint(
            'FirebaseTopicManager: subscribed to $_subscribedCountryOnlyTopic');
      }
    } catch (e) {
      debugPrint('FirebaseTopicManager: login subscribe error -> $e');
    }
  }

  /// Subscribe to topics for mass notifications when driver goes online
  Future<void> subscribeToTopics({
    required String? cityId,
    required String? countryId,
    required int businessType,
  }) async {
    try {
      if (cityId != null && cityId.isNotEmpty) {
        _subscribedCityTopic =
            'DRIVER_${_platform}_${cityId}_$businessType';
        await _messaging.subscribeToTopic(_subscribedCityTopic!);
        debugPrint(
            'FirebaseTopicManager: subscribed to $_subscribedCityTopic');
      }

      if (countryId != null && countryId.isNotEmpty) {
        _subscribedCountryTopic =
            'DRIVER_${_platform}_${countryId}_$businessType';
        await _messaging.subscribeToTopic(_subscribedCountryTopic!);
        debugPrint(
            'FirebaseTopicManager: subscribed to $_subscribedCountryTopic');
      }
    } catch (e) {
      debugPrint('FirebaseTopicManager: subscribe error -> $e');
    }
  }

  /// Unsubscribe from all topics (online + login topics)
  Future<void> unsubscribeFromTopics() async {
    try {
      if (_subscribedCityTopic != null) {
        await _messaging.unsubscribeFromTopic(_subscribedCityTopic!);
        debugPrint(
            'FirebaseTopicManager: unsubscribed from $_subscribedCityTopic');
        _subscribedCityTopic = null;
      }

      if (_subscribedCountryTopic != null) {
        await _messaging.unsubscribeFromTopic(_subscribedCountryTopic!);
        debugPrint(
            'FirebaseTopicManager: unsubscribed from $_subscribedCountryTopic');
        _subscribedCountryTopic = null;
      }

      if (_subscribedCityOnlyTopic != null) {
        await _messaging.unsubscribeFromTopic(_subscribedCityOnlyTopic!);
        debugPrint(
            'FirebaseTopicManager: unsubscribed from $_subscribedCityOnlyTopic');
        _subscribedCityOnlyTopic = null;
      }

      if (_subscribedCountryOnlyTopic != null) {
        await _messaging.unsubscribeFromTopic(_subscribedCountryOnlyTopic!);
        debugPrint(
            'FirebaseTopicManager: unsubscribed from $_subscribedCountryOnlyTopic');
        _subscribedCountryOnlyTopic = null;
      }
    } catch (e) {
      debugPrint('FirebaseTopicManager: unsubscribe error -> $e');
    }
  }
}
