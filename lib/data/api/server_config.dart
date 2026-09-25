import '../../core/constants/app_constants.dart';
import '../../core/interceptors/base_url_interceptor.dart';
import '../../core/preferences/shared_preference_manager.dart';
import 'server_environment.dart';

class ServerConfig {
  static String apiBaseUrl = AppConstants.apiBaseUrl;
  static String imageBaseUrl = AppConstants.imageBaseUrl;
  static String historyBaseUrl = AppConstants.historyBaseUrl;
  static String socketBaseUrl = AppConstants.socketBaseUrl;

  static Future<void> setBaseURLs(
    SharedPreferenceManager sharedPref,
    BaseUrlInterceptor apiBaseUrlInterceptor,
    BaseUrlInterceptor historyBaseUrlInterceptor,
    BaseUrlInterceptor socketBaseUrlInterceptor,
  ) async {
    final serverEnvironment = sharedPref.getServerEnvironment();

    if (serverEnvironment == ServerEnvironment.local) {
      final localhost = sharedPref.getLocalBaseUrl();
      apiBaseUrl = 'http://$localhost:${AppConstants.apiPort}/api/';
      imageBaseUrl = 'http://$localhost:${AppConstants.apiPort}/';
      historyBaseUrl = 'http://$localhost:${AppConstants.historyPort}/api/';
      socketBaseUrl = 'http://$localhost:${AppConstants.socketPort}/';
    } else {
      apiBaseUrl = serverEnvironment.apiBaseUrl;
      imageBaseUrl = serverEnvironment.imageBaseUrl;
      historyBaseUrl = serverEnvironment.historyBaseUrl;
      socketBaseUrl = serverEnvironment.socketBaseUrl;
    }

    apiBaseUrlInterceptor.updateBaseUrl(apiBaseUrl);
    historyBaseUrlInterceptor.updateBaseUrl(historyBaseUrl);
    socketBaseUrlInterceptor.updateBaseUrl(socketBaseUrl);
  }

  static String getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.trim().isEmpty) {
      return '';
    }

    final cleanPath = imagePath.trim();
    if (cleanPath.startsWith('http://') || cleanPath.startsWith('https://')) {
      return cleanPath;
    }

    final normalizedBase = imageBaseUrl.replaceAll(RegExp(r'/+$'), '');
    final normalizedPath = cleanPath.replaceAll(RegExp(r'^/+'), '');
    return '$normalizedBase/$normalizedPath';
  }
}
