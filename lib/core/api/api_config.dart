/// Central API configuration.
///
/// ALL services must import this file and use [ApiConfig.baseUrl] —
/// no URL should ever be hardcoded inside a feature service or widget.
class ApiConfig {
  ApiConfig._();

  /// ngrok-exposed backend host (no trailing slash, no /api suffix).
  static const String _host =
      'https://endorsable-eda-inobservantly.ngrok-free.dev';

  /// Full API base URL including the /api prefix.
  /// Use this to build every endpoint: '$baseUrl/travel/plan', etc.
  static const String baseUrl = '$_host/api';

  /// Required headers for every request to the ngrok tunnel.
  /// ngrok redirects to an HTML warning page unless this header is set.
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };
}
