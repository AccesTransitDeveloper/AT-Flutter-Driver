import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../preferences/shared_preference_manager.dart';
import '../interceptors/base_url_interceptor.dart';
import '../interceptors/header_interceptor.dart';
import '../interceptors/logging_interceptor.dart';
import '../../data/api/api_client.dart';
import '../../data/api/server_config.dart';
import '../../core/constants/app_constants.dart';

// SharedPreferences provider
final sharedPreferenceManagerProvider = FutureProvider<SharedPreferenceManager>((ref) async {
  return await SharedPreferenceManager.create();
});

// Base URL Interceptors
final apiBaseUrlInterceptorProvider = Provider<BaseUrlInterceptor>((ref) {
  return BaseUrlInterceptor(AppConstants.apiBaseUrl);
});

final historyBaseUrlInterceptorProvider = Provider<BaseUrlInterceptor>((ref) {
  return BaseUrlInterceptor(AppConstants.historyBaseUrl);
});

final socketBaseUrlInterceptorProvider = Provider<BaseUrlInterceptor>((ref) {
  return BaseUrlInterceptor(AppConstants.socketBaseUrl);
});

// Header Interceptor provider
final headerInterceptorProvider = Provider<HeaderInterceptor>((ref) {
  final sharedPrefAsync = ref.watch(sharedPreferenceManagerProvider);

  return sharedPrefAsync.when(
    data: (sharedPref) => HeaderInterceptor(sharedPref),
    loading: () => throw Exception('SharedPreferences not initialized'),
    error: (error, stack) => throw error,
  );
});

// Logging Interceptor provider
final loggingInterceptorProvider = Provider<LoggingInterceptor>((ref) {
  return LoggingInterceptor();
});

// API Clients
final apiClientProvider = Provider<ApiClient>((ref) {
  final baseUrlInterceptor = ref.watch(apiBaseUrlInterceptorProvider);
  final headerInterceptor = ref.watch(headerInterceptorProvider);
  final loggingInterceptor = ref.watch(loggingInterceptorProvider);
  return ApiClient(baseUrlInterceptor, headerInterceptor, loggingInterceptor);
});

final historyApiClientProvider = Provider<ApiClient>((ref) {
  final baseUrlInterceptor = ref.watch(historyBaseUrlInterceptorProvider);
  final headerInterceptor = ref.watch(headerInterceptorProvider);
  final loggingInterceptor = ref.watch(loggingInterceptorProvider);
  return ApiClient(baseUrlInterceptor, headerInterceptor, loggingInterceptor);
});

final socketApiClientProvider = Provider<ApiClient>((ref) {
  final baseUrlInterceptor = ref.watch(socketBaseUrlInterceptorProvider);
  final headerInterceptor = ref.watch(headerInterceptorProvider);
  final loggingInterceptor = ref.watch(loggingInterceptorProvider);
  return ApiClient(baseUrlInterceptor, headerInterceptor, loggingInterceptor);
});

// Initialize server configuration
final serverConfigInitializerProvider = FutureProvider<void>((ref) async {
  final sharedPref = await ref.watch(sharedPreferenceManagerProvider.future);
  final apiInterceptor = ref.watch(apiBaseUrlInterceptorProvider);
  final historyInterceptor = ref.watch(historyBaseUrlInterceptorProvider);
  final socketInterceptor = ref.watch(socketBaseUrlInterceptorProvider);

  await ServerConfig.setBaseURLs(
    sharedPref,
    apiInterceptor,
    historyInterceptor,
    socketInterceptor,
  );
});
