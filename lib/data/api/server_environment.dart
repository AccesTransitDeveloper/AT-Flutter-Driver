import '../../core/constants/app_constants.dart';

enum ServerEnvironment {
  production('production'),
  demo('demo'),
  local('local');

  final String value;
  const ServerEnvironment(this.value);

  static ServerEnvironment fromValue(String value) {
    switch (value.toLowerCase()) {
      case 'production':
        return ServerEnvironment.production;
      case 'demo':
        return ServerEnvironment.demo;
      case 'local':
        return ServerEnvironment.local;
      default:
        return ServerEnvironment.production;
    }
  }

  String get apiBaseUrl {
    switch (this) {
      case ServerEnvironment.production:
        return AppConstants.apiBaseUrl;
      case ServerEnvironment.demo:
        return AppConstants.demoApiBaseUrl;
      case ServerEnvironment.local:
        return 'http://localhost:${AppConstants.apiPort}/api/';
    }
  }

  String get imageBaseUrl {
    switch (this) {
      case ServerEnvironment.production:
        return AppConstants.imageBaseUrl;
      case ServerEnvironment.demo:
        return AppConstants.demoImageBaseUrl;
      case ServerEnvironment.local:
        return 'http://localhost:${AppConstants.apiPort}/';
    }
  }

  String get historyBaseUrl {
    switch (this) {
      case ServerEnvironment.production:
        return AppConstants.historyBaseUrl;
      case ServerEnvironment.demo:
        return AppConstants.demoHistoryBaseUrl;
      case ServerEnvironment.local:
        return 'http://localhost:${AppConstants.historyPort}/api/';
    }
  }

  String get socketBaseUrl {
    switch (this) {
      case ServerEnvironment.production:
        return AppConstants.socketBaseUrl;
      case ServerEnvironment.demo:
        return AppConstants.demoSocketBaseUrl;
      case ServerEnvironment.local:
        return 'http://localhost:${AppConstants.socketPort}/';
    }
  }
}
