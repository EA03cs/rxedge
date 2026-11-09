import 'package:flutter/widgets.dart';
import '../../l10n/app_localizations.dart';
import 'failures.dart';

/// Single failure-to-message mapper
///
/// Follows Architecture Contract:
/// "A single mapper converts Failure to a user-friendly localized message. No raw errors, no status codes in the UI."
abstract final class FailureMessageMapper {
  static String map(BuildContext context, Failure failure) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n?.localeName == 'ar';

    switch (failure) {
      case NetworkFailure():
        return isArabic
            ? 'تعذر الاتصال بالشبكة. يرجى التحقق من اتصال الإنترنت والمحاولة ثانية.'
            : 'Unable to connect. Please verify your internet connection and try again.';

      case ServerFailure():
        return isArabic
            ? 'الخدمة غير متاحة حالياً. يرجى المحاولة بعد قليل.'
            : 'The service is temporarily unavailable. Please try again in a moment.';

      case UnauthorizedFailure():
        return isArabic
            ? 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مجدداً للمتابعة.'
            : 'Your session has expired. Please sign in again to continue.';

      case ValidationFailure():
        return isArabic
            ? 'يرجى مراجعة البيانات المدخلة وتصحيح الحقول المطلوبة.'
            : 'Please review the entered information and correct any errors.';

      case CacheFailure():
        return isArabic
            ? 'تعذر قراءة البيانات المحفوظة محلياً.'
            : 'Unable to read locally stored data.';

      case NotFoundFailure():
        return isArabic
            ? 'المورد المطلوب غير موجود.'
            : 'The requested resource could not be found.';

      case UnknownFailure():
        return isArabic
            ? 'حدث خطأ غير متوقع. يرجى المحاولة مجدداً.'
            : 'An unexpected issue occurred. Please try again.';
    }
  }
}
