import '../config/env_config.dart';

/// Resolves relative backend storage URLs (e.g. `/uploads/materials/file.pdf`)
/// against the active backend server origin (stripping `/api/v1`).
abstract final class UrlResolver {
  /// Derives server origin (scheme + host + optional port) from an API base URL.
  static String originFromApiBaseUrl(String apiBaseUrl) {
    final trimmed = apiBaseUrl.trim();
    if (trimmed.isEmpty) return '';
    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return trimmed
          .replaceFirst(RegExp(r'/api/v\d+/?$'), '')
          .replaceFirst(RegExp(r'/v\d+/?$'), '')
          .replaceFirst(RegExp(r'/+$'), '');
    }
    final portSuffix = uri.hasPort &&
            !((uri.scheme == 'http' && uri.port == 80) ||
                (uri.scheme == 'https' && uri.port == 443))
        ? ':${uri.port}'
        : '';
    return '${uri.scheme}://${uri.host}$portSuffix';
  }

  /// Resolves [rawUrl] to an absolute URL when possible.
  /// Returns null when [rawUrl] is null or empty.
  static String? resolve(String? rawUrl, {String? apiBaseUrl}) {
    final value = rawUrl?.trim();
    if (value == null || value.isEmpty) return null;

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    final origin = originFromApiBaseUrl(apiBaseUrl ?? EnvConfig.baseUrl);
    if (origin.isEmpty) return value;

    final normalizedPath = value.startsWith('/') ? value : '/$value';
    return '$origin$normalizedPath';
  }
}
