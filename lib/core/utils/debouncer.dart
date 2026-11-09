import 'dart:async';
import 'package:flutter/foundation.dart';
import '../config/app_constants.dart';

/// Debouncer to prevent rapid fire API calls during search input
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = AppConstants.searchDebounceDuration});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void cancel() {
    _timer?.cancel();
  }

  void dispose() {
    _timer?.cancel();
  }
}
