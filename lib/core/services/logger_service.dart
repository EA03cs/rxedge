import 'dart:developer' as developer;
import '../config/env_config.dart';

/// Centralized Logger Wrapper for RxEdge
///
/// Follows Architecture Convention:
/// "Logging through one logger wrapper, no print()."
abstract final class AppLogger {
  static void d(String message, {String tag = 'RxEdge', Object? error, StackTrace? stackTrace}) {
    _log('DEBUG', message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void i(String message, {String tag = 'RxEdge'}) {
    _log('INFO', message, tag: tag);
  }

  static void w(String message, {String tag = 'RxEdge', Object? error, StackTrace? stackTrace}) {
    _log('WARN', message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void e(String message, {String tag = 'RxEdge', Object? error, StackTrace? stackTrace}) {
    _log('ERROR', message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void _log(
    String level,
    String message, {
    required String tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!EnvConfig.enableLogging && level == 'DEBUG') return;

    final now = DateTime.now().toIso8601String();
    developer.log(
      '[$now] [$level] [$tag] $message',
      name: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
