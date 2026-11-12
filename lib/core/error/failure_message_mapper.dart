import 'package:flutter/material.dart';
import 'package:rxedge/l10n/app_localizations.dart';
import 'failures.dart';

/// Maps sealed domain [Failure] values into user-facing localized UI strings.
abstract final class FailureMessageMapper {
  static String map(BuildContext context, Failure failure) {
    final l10n = AppLocalizations.of(context)!;
    switch (failure) {
      case NetworkFailure():
        return l10n.errNetwork;
      case UnauthorizedFailure(debugMessage: final msg):
        if (_isSafeServerMessage(msg)) return msg!;
        return l10n.errUnauthorized;
      case NotFoundFailure():
        return l10n.errNotFound;
      case ValidationFailure(fieldErrors: final fields, debugMessage: final msg):
        if (fields.isNotEmpty) {
          return localizeValidationCode(l10n, fields.values.first);
        }
        if (_isSafeServerMessage(msg)) return localizeValidationCode(l10n, msg!);
        return l10n.errValidation;
      case CacheFailure():
        return l10n.errCache;
      case ServerFailure(statusCode: final code, debugMessage: final msg):
        if (code != null && code >= 400 && code < 500 && _isSafeServerMessage(msg)) {
          return msg!;
        }
        return l10n.errServer;
      case UnknownFailure():
        return l10n.errUnknown;
    }
  }

  static bool _isSafeServerMessage(String? msg) {
    if (msg == null) return false;
    final trimmed = msg.trim();
    if (trimmed.isEmpty) return false;
    // Never leak internal transport/Dart exception details to the UI.
    if (trimmed.contains('DioException') ||
        trimmed.contains('Exception:') ||
        trimmed.startsWith('Instance of ')) {
      return false;
    }
    return true;
  }

  /// Translates raw backend validation keys (e.g. Joi `VALIDATION_*` codes)
  /// into user-facing localized copy when the backend does not map them.
  static String localizeValidationCode(AppLocalizations l10n, String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return l10n.errValidation;
    final upper = trimmed.toUpperCase();
    final isAr = l10n.localeName.toLowerCase().startsWith('ar');

    if (upper.contains('EMAIL_INVALID') ||
        (upper.contains('EMAIL') && upper.contains('VALID'))) {
      return isAr
          ? 'يرجى إدخال بريد إلكتروني صحيح للعمل (مثل rep@rxedge.com)'
          : 'Please enter a valid work email (e.g. rep@rxedge.com).';
    }
    if (upper.contains('EMAIL_REQUIRED') ||
        upper == 'VALIDATION_EMAIL_EMPTY') {
      return l10n.usernameRequired;
    }
    if (upper.contains('PASSWORD_MIN')) {
      return isAr
          ? 'كلمة المرور يجب أن لا تقل عن 6 أحرف'
          : 'Password must be at least 6 characters.';
    }
    if (upper.contains('PASSWORD_REQUIRED') ||
        upper == 'VALIDATION_PASSWORD_EMPTY') {
      return l10n.passwordRequired;
    }
    if (RegExp(r'^[A-Z0-9_]+$').hasMatch(trimmed)) {
      return l10n.errValidation;
    }
    return trimmed;
  }
}
