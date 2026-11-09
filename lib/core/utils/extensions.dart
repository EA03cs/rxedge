import 'package:flutter/material.dart';
import '../error/failure_message_mapper.dart';
import '../error/failures.dart';

/// BuildContext convenience extensions
extension BuildContextUtils on BuildContext {
  /// Display human-friendly localized error message for Failure
  void showFailureSnackBar(Failure failure) {
    final message = FailureMessageMapper.map(this, failure);
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Whether current theme is dark
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Whether layout direction is RTL
  bool get isRtlDirection => Directionality.of(this) == TextDirection.rtl;

  /// Screen size shortcuts
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
}

/// String utility extensions
extension StringUtils on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
