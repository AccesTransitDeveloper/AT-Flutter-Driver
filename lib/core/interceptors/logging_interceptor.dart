/// API logger. Prints only a clean cURL command per request (no bodies, no
/// responses) so the console stays readable. Output goes through `print()` so
/// it shows in the `flutter:` console, chunked so long cURLs aren't truncated.
class LoggingInterceptor {
  void logRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    dynamic body,
  }) {
    final curl = _generateCurl(
      method: method,
      url: url,
      headers: headers,
      body: body,
    );
    _printChunked('\n🧾 $method  ${_shortUrl(url)}\n$curl');
  }

  // Response logging is disabled — only the request cURL is printed.
  void logResponse({
    required String method,
    required String url,
    required int statusCode,
    required String? responseBody,
    required Duration duration,
  }) {}

  void logError({
    required String method,
    required String url,
    required String error,
    required Duration duration,
  }) {
    // ignore: avoid_print
    print('⛔️ $method  ${_shortUrl(url)}  →  $error');
  }

  // ── Helpers ──────────────────────────────────────────────────────

  /// Drop the scheme so the endpoint reads at a glance.
  String _shortUrl(String url) =>
      url.replaceFirst(RegExp(r'^https?://'), '');

  /// Print a long string across multiple log lines so it is not truncated.
  void _printChunked(String text) {
    const int chunkSize = 800;
    for (int i = 0; i < text.length; i += chunkSize) {
      final end = (i + chunkSize < text.length) ? i + chunkSize : text.length;
      // ignore: avoid_print
      print(text.substring(i, end));
    }
  }

  String _generateCurl({
    required String method,
    required String url,
    Map<String, String>? headers,
    dynamic body,
  }) {
    final buffer = StringBuffer();
    buffer.write('curl -X $method');

    if (headers != null && headers.isNotEmpty) {
      headers.forEach((key, value) {
        final escapedValue = value.replaceAll("'", "'\\''");
        buffer.write(" -H '$key: $escapedValue'");
      });
    }

    if (body != null && body.toString().isNotEmpty) {
      final escapedBody = body.toString().replaceAll("'", "'\\''");
      buffer.write(" -d '$escapedBody'");
    }

    buffer.write(" '$url'");
    return buffer.toString();
  }
}
