import 'package:intl/intl.dart';

/// Formatting helpers for dates, numbers, and file sizes
abstract final class Formatters {
  static String formatDate(DateTime date, {String format = 'yyyy-MM-dd', String? locale}) {
    return DateFormat(format, locale).format(date);
  }

  static String formatTime(DateTime time, {String? locale}) {
    return DateFormat.jm(locale).format(time);
  }

  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static String formatQuota(int current, int target) {
    return '$current / $target';
  }

  static String formatPercentage(double value) {
    return '${(value * 100).toInt()}%';
  }
}
