import '../config/env_config.dart';

/// Builds HTTP authorization headers for protected backend media URLs.
///
/// Only attaches `Authorization: Bearer <token>` when [token] is non-empty and
/// the parsed [url] host matches the configured API host. Returns `null` for
/// external hosts (e.g. Google Drive, Unsplash) or invalid/empty URLs so JWT
/// credentials are never leaked to third parties.
Map<String, String>? buildProtectedMediaHeaders(
  String url,
  String? token, {
  String? apiBaseUrl,
}) {
  final trimmedToken = token?.trim();
  if (trimmedToken == null || trimmedToken.isEmpty) return null;

  final trimmedUrl = url.trim();
  if (trimmedUrl.isEmpty) return null;

  final apiHost = UrlResolver.apiHost(apiBaseUrl: apiBaseUrl);
  if (apiHost == null) return null;

  final targetUri = Uri.tryParse(trimmedUrl);
  if (targetUri == null ||
      (targetUri.scheme != 'http' && targetUri.scheme != 'https') ||
      targetUri.host.isEmpty) {
    return null;
  }

  if (targetUri.host.toLowerCase() != apiHost) {
    return null;
  }

  return <String, String>{
    'Authorization': 'Bearer $trimmedToken',
  };
}

/// Resolves relative backend storage URLs (e.g. `/uploads/materials/file.pdf`)
/// against the active backend server origin (stripping `/api/v1`).
abstract final class UrlResolver {
  /// Returns the normalized lowercase host of the configured API base URL.
  static String? apiHost({String? apiBaseUrl}) {
    final base = (apiBaseUrl ?? EnvConfig.baseUrl).trim();
    if (base.isEmpty) return null;
    final host = Uri.tryParse(base)?.host.toLowerCase();
    if (host == null || host.isEmpty) return null;
    return host;
  }

  /// Returns `true` when [url] is an HTTP(S) URL whose host matches [apiHost].
  static bool isApiHost(String? url, {String? apiBaseUrl}) {
    final trimmed = url?.trim();
    if (trimmed == null || trimmed.isEmpty) return false;
    final host = apiHost(apiBaseUrl: apiBaseUrl);
    if (host == null) return false;
    final uri = Uri.tryParse(trimmed);
    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      return false;
    }
    return uri.host.toLowerCase() == host;
  }

  /// Convenience alias for [buildProtectedMediaHeaders].
  static Map<String, String>? mediaHeaders(
    String url,
    String? token, {
    String? apiBaseUrl,
  }) =>
      buildProtectedMediaHeaders(url, token, apiBaseUrl: apiBaseUrl);
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

    if (value.startsWith('http://rxedge.agro-plus.net')) {
      return value.replaceFirst('http://', 'https://');
    }

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    final origin = originFromApiBaseUrl(apiBaseUrl ?? EnvConfig.baseUrl);
    if (origin.isEmpty) return value;

    final secureOrigin = origin.startsWith('http://rxedge.agro-plus.net')
        ? origin.replaceFirst('http://', 'https://')
        : origin;

    final normalizedPath = value.startsWith('/') ? value : '/$value';
    return '$secureOrigin$normalizedPath';
  }
}
