import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../constants/app_constants.dart';
import 'permission_manager.dart';

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message: ${message.messageId}');

  // On iOS, if the message has a notification payload, iOS already displayed it.
  if (Platform.isIOS && message.notification != null) {
    return;
  }

  await NotificationManager.instance.showNotificationFromMessage(message);
}

/// Notification channel IDs
class NotificationChannels {
  static const String regularChannelId = 'regular_notification_channel';
  static const String regularChannelName = 'Regular Notifications';
  static const String regularChannelDesc = 'Regular app notifications';

  static const String liveChannelId = 'live_notification_channel_id';
  static const String liveChannelName = 'Live Booking';
  static const String liveChannelDesc = 'Live booking status updates';

  static const String highPriorityChannelId = 'high_priority_channel';
  static const String highPriorityChannelName = 'Important Notifications';
  static const String highPriorityChannelDesc =
      'Important notifications that require immediate attention';
}

/// Notification Manager for handling FCM push notifications
class NotificationManager {
  NotificationManager._();
  static final NotificationManager instance = NotificationManager._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final AudioPlayer _audioPlayer = AudioPlayer();

  String? _fcmToken;
  String? _apnsToken;

  /// Callback to persist token to SharedPreferences
  void Function(String token)? _onTokenChanged;

  /// Set callback for token persistence (call after SharedPreferences is ready)
  void setOnTokenChanged(void Function(String token) callback) {
    _onTokenChanged = callback;
    // Persist current token if already available
    if (_fcmToken != null) {
      _onTokenChanged?.call(_fcmToken!);
    }
  }

  /// Stream controller for pending notification navigation
  final _pendingNotificationController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Stream of notification data that should trigger navigation
  Stream<Map<String, dynamic>> get pendingNotificationStream =>
      _pendingNotificationController.stream;

  /// Get current FCM token
  String? get fcmToken => _fcmToken;

  /// Get current APNS token (iOS only)
  String? get apnsToken => _apnsToken;

  /// Initialize notification manager
  Future<void> init() async {
    await _initLocalNotifications();
    await _createNotificationChannels();
    await _requestPermission();
    await _getToken();

    // Listen to token refresh
    _messaging.onTokenRefresh.listen((token) {
      debugPrint('FCM Token refreshed: $token');
      _fcmToken = token;
      _onTokenChanged?.call(token);
    });

    // iOS: Display notifications natively in foreground
    if (Platform.isIOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check if app was opened from terminated state via notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  /// Initialize local notifications plugin
  Future<void> _initLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@drawable/ic_stat_notification');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    if (!Platform.isAndroid) return;

    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    const regularChannel = AndroidNotificationChannel(
      NotificationChannels.regularChannelId,
      NotificationChannels.regularChannelName,
      description: NotificationChannels.regularChannelDesc,
      importance: Importance.defaultImportance,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    const liveChannel = AndroidNotificationChannel(
      NotificationChannels.liveChannelId,
      NotificationChannels.liveChannelName,
      description: NotificationChannels.liveChannelDesc,
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
      showBadge: false,
    );

    const highPriorityChannel = AndroidNotificationChannel(
      NotificationChannels.highPriorityChannelId,
      NotificationChannels.highPriorityChannelName,
      description: NotificationChannels.highPriorityChannelDesc,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await androidPlugin.createNotificationChannel(regularChannel);
    await androidPlugin.createNotificationChannel(liveChannel);
    await androidPlugin.createNotificationChannel(highPriorityChannel);
  }

  bool _isPermissionGranted = false;

  /// Check if notification permission is granted
  bool get isPermissionGranted => _isPermissionGranted;

  /// Request notification permission
  Future<void> _requestPermission() async {
    if (Platform.isIOS) {
      debugPrint('🔔 [iOS] Requesting notification permission...');
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('🔔 [iOS] Permission status: ${settings.authorizationStatus}');
      debugPrint('🔔 [iOS] Alert: ${settings.alert}');
      debugPrint('🔔 [iOS] Badge: ${settings.badge}');
      debugPrint('🔔 [iOS] Sound: ${settings.sound}');

      _isPermissionGranted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;

      debugPrint('🔔 [iOS] Permission granted: $_isPermissionGranted');
    } else {
      final result = await PermissionManager.instance.requestNotification();
      _isPermissionGranted = result == PermissionResult.granted;
    }
  }

  /// Get FCM token
  Future<String?> _getToken() async {
    try {
      debugPrint('🔔 [getToken] Starting token retrieval...');

      if (Platform.isIOS) {
        debugPrint('🔔 [iOS] Permission granted: $_isPermissionGranted');

        if (!_isPermissionGranted) {
          debugPrint('🔔 [iOS] Skipping token - notification permission not granted');
          return null;
        }

        // On iOS, APNS token may not be ready immediately after permission grant.
        // Wait briefly and retry.
        String? apnsToken = await _messaging.getAPNSToken();
        if (apnsToken == null) {
          debugPrint('🔔 [iOS] APNS not ready yet, waiting 3 seconds...');
          await Future.delayed(const Duration(seconds: 3));
          apnsToken = await _messaging.getAPNSToken();
        }

        if (apnsToken != null) {
          _apnsToken = apnsToken;
          debugPrint('🔔 [iOS] APNS Token: $_apnsToken');
        } else {
          debugPrint('🔔 [iOS] APNS still not available after retry');
        }
      }

      _fcmToken = await _messaging.getToken();
      debugPrint('🔔 FCM Token: $_fcmToken');
      if (_fcmToken != null) {
        _onTokenChanged?.call(_fcmToken!);
      }
      return _fcmToken;
    } catch (e, stackTrace) {
      debugPrint('🔔 ❌ Error getting FCM token: $e');
      debugPrint('🔔 ❌ Stack trace: $stackTrace');
      return null;
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message: ${message.data}');

    // Entity status only. The full action goes through the pending-notification
    // stream, which main.dart uses to navigate — routing on receipt would yank
    // the driver to a booking screen they never tapped.
    _notifyEntityStatus(message.data);

    if (Platform.isIOS) {
      // iOS displays notification natively; only show for data-only messages
      if (message.notification == null) {
        showNotificationFromMessage(message);
      }
    } else {
      // Android doesn't auto-display in foreground
      showNotificationFromMessage(message);
    }
  }

  /// Handle notification tap (app opened from notification)
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.data}');
    _processNotificationAction(message.data);
  }

  /// Handle local notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Local notification tapped: ${response.payload}');
    if (response.payload != null && response.payload!.isNotEmpty) {
      // Local notification taps don't carry full data, navigate to home
      _pendingNotificationController.add({});
    }
  }

  /// Show notification from FCM message
  Future<void> showNotificationFromMessage(RemoteMessage message) async {
    final data = message.data;

    final title = data['title'] ?? message.notification?.title ?? '';
    final body = data['body'] ?? message.notification?.body ?? '';
    final sound = data['sound'];
    final image = data['image'];

    // Skip live notifications (progress data)
    if (data['progress'] != null) return;

    if (title.isEmpty && body.isEmpty) return;

    await showNotification(
      title: title,
      body: body,
      sound: sound,
      imageUrl: image,
      payload: message.messageId,
    );
  }

  /// Show a local notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? sound,
    String? imageUrl,
    String? payload,
    bool isHighPriority = false,
  }) async {
    final bool hasCustomSound =
        sound != null && sound.isNotEmpty && sound != 'default' && sound != 'null';

    final channelId = isHighPriority
        ? NotificationChannels.highPriorityChannelId
        : NotificationChannels.regularChannelId;
    final channelName = isHighPriority
        ? NotificationChannels.highPriorityChannelName
        : NotificationChannels.regularChannelName;
    final channelDesc = isHighPriority
        ? NotificationChannels.highPriorityChannelDesc
        : NotificationChannels.regularChannelDesc;

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: isHighPriority ? Importance.high : Importance.defaultImportance,
      priority: isHighPriority ? Priority.high : Priority.defaultPriority,
      playSound: !hasCustomSound,
      styleInformation: BigTextStyleInformation(body),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final notificationId = DateTime.now().millisecondsSinceEpoch.hashCode;

    try {
      await _localNotifications.show(
        notificationId,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }

    if (hasCustomSound) {
      await _playCustomSound(sound);
    }
  }

  /// Play custom sound from storage
  Future<void> _playCustomSound(String soundName) async {
    try {
      final soundFile = await _getSoundFile(soundName);
      if (soundFile != null && await soundFile.exists()) {
        await _audioPlayer.play(DeviceFileSource(soundFile.path));
      }
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  /// Get sound file from storage
  Future<File?> _getSoundFile(String soundName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final soundsDir = Directory('${directory.path}/sounds');
      if (!await soundsDir.exists()) {
        await soundsDir.create(recursive: true);
      }
      return File('${soundsDir.path}/$soundName');
    } catch (e) {
      debugPrint('Error getting sound file: $e');
      return null;
    }
  }

  /// Download and save sound file
  Future<bool> downloadSound(String soundUrl, String soundName) async {
    try {
      final response = await http.get(Uri.parse(soundUrl));
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final soundsDir = Directory('${directory.path}/sounds');
        if (!await soundsDir.exists()) {
          await soundsDir.create(recursive: true);
        }
        final soundFile = File('${soundsDir.path}/$soundName');
        await soundFile.writeAsBytes(response.bodyBytes);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error downloading sound: $e');
      return false;
    }
  }

  /// Check if sound file exists
  Future<bool> soundExists(String soundName) async {
    final soundFile = await _getSoundFile(soundName);
    return soundFile != null && await soundFile.exists();
  }

  /// Fired when an ENTITY_STATUS push arrives (admin approved / declined /
  /// blocked the driver). Native reloads the entity on this — see
  /// `FirebaseCloudMessagingService.handleNotificationAction`.
  void Function(int status)? onEntityStatusChanged;

  void _notifyEntityStatus(Map<String, dynamic> data) {
    if (data['status']?.toString() != NotificationStatus.entityStatus) return;

    final status = int.tryParse(data['id']?.toString() ?? '');
    if (status == null) return;

    debugPrint('ENTITY_STATUS push received, id=$status');
    onEntityStatusChanged?.call(status);
  }

  /// Process notification action based on data
  void _processNotificationAction(Map<String, dynamic> data) {
    final status = data['status'];
    final id = data['id'];
    final bookingId = data['bookingId'];
    final pushCode = data['pushCode'];
    debugPrint(
        'Processing notification action: status=$status, id=$id, bookingId=$bookingId, pushCode=$pushCode');
    _notifyEntityStatus(data);
    _pendingNotificationController.add(data);
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  /// Delete FCM token (useful for logout)
  Future<void> deleteToken() async {
    // On iOS, deleteToken requires APNS token to be set.
    // Skip deletion if APNS is not available (e.g. simulator).
    if (Platform.isIOS) {
      final apnsToken = await _messaging.getAPNSToken();
      if (apnsToken == null) {
        _fcmToken = null;
        return;
      }
    }
    await _messaging.deleteToken();
    _fcmToken = null;
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Dispose resources
  void dispose() {
    _pendingNotificationController.close();
    _audioPlayer.dispose();
  }
}
