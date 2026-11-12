import 'package:flutter/foundation.dart';
import 'flavor_config.dart';
import '../network/url_resolver.dart';

/// Environment Configuration resolving URLs and flags based on Flavor
abstract final class EnvConfig {
  static const String _defineApiBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const String liveServerBaseUrl = 'http://rxedge.agro-plus.net/api/v1';

  /// Live production backend URL (`http://rxedge.agro-plus.net/api/v1`).
  /// Can always be overridden at build/run time with `--dart-define=API_BASE_URL=...`.
  static String get defaultLiveBaseUrl {
    if (_defineApiBaseUrl.isNotEmpty) return _defineApiBaseUrl;
    return liveServerBaseUrl;
  }

  /// Platform-aware local dev API URL for `D:\Backend\rxedge` (port 4010).
  /// Can always be overridden at build/run time with `--dart-define=API_BASE_URL=...`.
  static String get defaultDevBaseUrl {
    if (_defineApiBaseUrl.isNotEmpty) return _defineApiBaseUrl;
    if (kIsWeb) return 'http://localhost:4010/api/v1';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:4010/api/v1';
    }
    return 'http://localhost:4010/api/v1';
  }

  static String get baseUrl {
    if (_defineApiBaseUrl.isNotEmpty) return _defineApiBaseUrl;
    return FlavorConfig.isInitialized
        ? FlavorConfig.instance.apiBaseUrl
        : defaultLiveBaseUrl;
  }

  /// Base server origin without `/api/v1`, used to resolve relative `/uploads/...` URLs.
  static String get serverOrigin => UrlResolver.originFromApiBaseUrl(baseUrl);
  static String get appName =>
      FlavorConfig.isInitialized ? FlavorConfig.instance.appName : 'RxEdge (Test)';
  static bool get enableLogging =>
      FlavorConfig.isInitialized ? FlavorConfig.instance.enableLogging : true;
  static Duration get connectTimeout =>
      FlavorConfig.isInitialized ? FlavorConfig.instance.connectTimeout : const Duration(seconds: 15);
  static Duration get receiveTimeout =>
      FlavorConfig.isInitialized ? FlavorConfig.instance.receiveTimeout : const Duration(seconds: 15);
}
