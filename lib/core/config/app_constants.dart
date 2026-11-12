/// Global Application Constants for RxEdge
abstract final class AppConstants {
  // Storage Keys
  static const String keyAuthToken = 'rxedge_auth_token';
  static const String keyRefreshToken = 'rxedge_refresh_token';
  static const String keyUserId = 'rxedge_user_id';
  static const String keyUserRole = 'rxedge_user_role';
  static const String keyLocale = 'rxedge_app_locale';
  static const String keyThemeMode = 'rxedge_theme_mode';

  // HTTP Headers
  static const String headerAuthorization = 'Authorization';
  static const String headerBearerPrefix = 'Bearer ';
  static const String headerContentType = 'Content-Type';
  static const String headerContentTypeJson = 'application/json';
  static const String headerAccept = 'Accept';
  static const String headerAcceptLanguage = 'Accept-Language';
  static const String headerIfNoneMatch = 'If-None-Match';
  static const String headerAppVersion = 'X-App-Version';
  static const String headerDeviceId = 'X-Device-Id';
  static const String keyLastSyncManifest = 'rxedge_last_sync_manifest';

  // Cache & Stale Times & Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration defaultCacheTtl = Duration(hours: 4);
  static const Duration offlineQueueRetryDelay = Duration(seconds: 30);
  static const int maxOfflineRetries = 5;
  static const int maxOfflineQueueRetries = maxOfflineRetries;

  // Debounce & Throttling
  static const Duration searchDebounceDuration = Duration(milliseconds: 300);
  static const Duration throttleDuration = Duration(milliseconds: 500);
}
