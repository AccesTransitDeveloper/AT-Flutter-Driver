import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/theme_notifier.dart';
import 'core/providers/app_providers.dart';
import 'core/router/app_router.dart';
import 'core/managers/session_manager.dart';
import 'core/managers/notification_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await Firebase.initializeApp();

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize notification manager
  await NotificationManager.instance.init();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  StreamSubscription<Map<String, dynamic>>? _notificationSubscription;

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  void _setupNotificationNavigation(GoRouter router) {
    if (_notificationSubscription != null) return;
    _notificationSubscription = NotificationManager
        .instance.pendingNotificationStream
        .listen((data) {
      _handleNotificationNavigation(router, data);
    });
  }

  void _handleNotificationNavigation(
      GoRouter router, Map<String, dynamic> data) {
    final bookingId = data['bookingId']?.toString();
    if (bookingId != null && bookingId.isNotEmpty) {
      // Navigate to trip/booking screen
      router.push('/current-ride/$bookingId');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final serverConfigInit = ref.watch(serverConfigInitializerProvider);
    final router = ref.watch(goRouterProvider);

    // Initialize SessionManager and token persistence with shared preferences
    ref.watch(sharedPreferenceManagerProvider).whenData((sharedPref) {
      SessionManager.instance.init(sharedPref);
      NotificationManager.instance.setOnTokenChanged((token) {
        sharedPref.setDeviceToken(token);
      });
    });

    // Set session expired callback to navigate to login
    SessionManager.instance.setSessionExpiredCallback(() {
      router.go('/login');
    });

    // Listen for notification taps and navigate
    _setupNotificationNavigation(router);

    return serverConfigInit.when(
      data: (_) => MaterialApp.router(
        title: 'AT Driver — Drive & Earn NYC',
        debugShowCheckedModeBanner: false,
        theme: themeState.getLightTheme(),
        darkTheme: themeState.getDarkTheme(),
        themeMode: themeState.materialThemeMode,
        routerConfig: router,
      ),
      loading: () => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: Text('Error initializing app: $error')),
        ),
      ),
    );
  }
}
