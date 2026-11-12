import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_constants.dart';
import '../../localization/app_locale_provider.dart';

/// Injects `Accept-Language: ar|en` on every outgoing API request based on
/// the active [localeProvider] (Arabic `'ar'` by default).
class LanguageInterceptor extends Interceptor {
  final Ref _ref;

  LanguageInterceptor(this._ref);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final Locale locale = _ref.read(localeProvider);
    final code = locale.languageCode == 'en' ? 'en' : 'ar';
    options.headers[AppConstants.headerAcceptLanguage] = code;
    handler.next(options);
  }
}
