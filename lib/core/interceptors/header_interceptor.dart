import '../preferences/shared_preference_manager.dart';
import '../constants/api_constants.dart';

class HeaderInterceptor {
  final SharedPreferenceManager _sharedPreferenceManager;

  HeaderInterceptor(this._sharedPreferenceManager);

  Map<String, String> getHeaders({Map<String, String>? additionalHeaders}) {
    final headers = <String, String>{};

    // Add authorization token if available
    final authToken = _sharedPreferenceManager.getAuthorization();
    if (authToken != null && authToken.isNotEmpty) {
      headers[ApiParams.authorization] = authToken;
    }

    // Add content type
    headers['Content-Type'] = 'application/json';

    // Merge with additional headers (additional headers can override defaults)
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  void updateAuthToken(String token) {
    _sharedPreferenceManager.setAuthorization(token);
  }

  void removeAuthToken() {
    _sharedPreferenceManager.removeAuthorization();
  }
}
