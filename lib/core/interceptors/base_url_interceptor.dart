class BaseUrlInterceptor {
  String _baseUrl;

  BaseUrlInterceptor(this._baseUrl);

  String get baseUrl => _baseUrl;

  void updateBaseUrl(String newBaseUrl) {
    _baseUrl = newBaseUrl;
  }

  Uri modifyUrl(Uri originalUrl, String path) {
    final baseUri = Uri.parse(_baseUrl);
    return baseUri.replace(
      path: baseUri.path + path,
      queryParameters: originalUrl.queryParameters.isNotEmpty
          ? originalUrl.queryParameters
          : null,
    );
  }
}
