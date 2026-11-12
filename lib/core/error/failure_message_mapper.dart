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
        if (fields.isNotEmpty) return fields.values.first;
        if (_isSafeServerMessage(msg)) return msg!;
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
}
