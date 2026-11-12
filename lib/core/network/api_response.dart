/// Helpers for parsing the D:\Backend\rxedge API response & error envelopes.
///
/// Success envelope (`src/Utils/Response.js`):
/// `{ "success": true, "message": "...", "status": 200, "lang": {...}, "data": ... }`
///
/// Error envelope (`src/Utils/Response.js`):
/// `{ "success": false, "message": "...", "status": 400|401|..., "error": { "code": "...", "message": "...", "details": ... } }`
///
/// Joi validation error (`src/Middlewares/Validation.js`):
/// `{ "message": "...", "status": 400, "errors": ["...", "..."] }`
abstract final class ApiResponseParser {
  /// Unwraps `data` from a standard backend response map, or returns the map itself
  /// if no `data` envelope key is present (for endpoints/tests returning raw payloads).
  static dynamic unwrapData(dynamic body) {
    if (body is Map<String, dynamic> && body.containsKey('data')) {
      return body['data'];
    }
    return body;
  }

  /// Extracts a `Map<String, dynamic>` payload from [body] (either `body['data']` or [body]).
  static Map<String, dynamic> unwrapMap(dynamic body) {
    final unwrapped = unwrapData(body);
    if (unwrapped is Map<String, dynamic>) {
      return unwrapped;
    }
    if (unwrapped is Map) {
      return Map<String, dynamic>.from(unwrapped);
    }
    return const <String, dynamic>{};
  }

  /// Extracts a `List<Map<String, dynamic>>` from [body].
  /// Supports `body['data']` as `List`, `body['data']['items']`, or raw `List`.
  static List<Map<String, dynamic>> unwrapList(
    dynamic body, {
    List<String> nestedKeys = const ['items', 'results', 'records', 'notifications'],
  }) {
    final unwrapped = unwrapData(body);
    if (unwrapped is List) {
      return unwrapped
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (unwrapped is Map) {
      for (final key in nestedKeys) {
        final candidate = unwrapped[key];
        if (candidate is List) {
          return candidate
              .whereType<Map<dynamic, dynamic>>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }
    }
    return const <Map<String, dynamic>>[];
  }

  /// Extracts a user-facing error message from backend error payloads (`Response.js` & `Validation.js`).
  static String? extractErrorMessage(dynamic data) {
    if (data is! Map) return null;
    final map = Map<String, dynamic>.from(data);

    // 1. Joi validation error array (`Validation.js`)
    final joiErrors = map['errors'];
    if (joiErrors is List && joiErrors.isNotEmpty) {
      final first = joiErrors.first?.toString().trim();
      if (first != null && first.isNotEmpty) return first;
    }

    // 2. Nested `error: { code, message, details }` (`Response.js`)
    final nestedError = map['error'];
    if (nestedError is Map) {
      final nestedMsg = nestedError['message']?.toString().trim();
      if (nestedMsg != null && nestedMsg.isNotEmpty) return nestedMsg;
    }

    // 3. Top-level `message`
    final topMsg = map['message']?.toString().trim();
    if (topMsg != null && topMsg.isNotEmpty) return topMsg;

    return null;
  }

  /// Extracts field-level errors from `Validation.js` or `details` objects.
  static Map<String, String> extractFieldErrors(dynamic data) {
    final result = <String, String>{};
    if (data is! Map) return result;

    // Nested error.details map/list
    final errorObj = data['error'];
    if (errorObj is Map) {
      final details = errorObj['details'];
      if (details is Map) {
        details.forEach((k, v) {
          result[k.toString()] = v.toString();
        });
      }
    }

    // Direct map `errors: { field: msg }` or list `errors: ['"title" is required']`
    final errors = data['errors'];
    if (errors is Map) {
      errors.forEach((k, v) {
        result[k.toString()] = v.toString();
      });
    } else if (errors is List) {
      for (var i = 0; i < errors.length; i++) {
        final msg = errors[i].toString();
        final match = RegExp(r'^"([^"]+)"').firstMatch(msg);
        final key = match?.group(1) ?? 'field_$i';
        result[key] = msg;
      }
    }

    return result;
  }
}
