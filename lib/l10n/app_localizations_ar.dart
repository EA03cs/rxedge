// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'آر إكس إيدج';

  @override
  String get tagline => 'منصة التدريب والمراجع العلمية للمندوب الطبي';

  @override
  String get offlineNotice =>
      'أنت غير متصل بالإنترنت. تم حفظ البيانات محلياً وسيتم المزامنة فور الاتصال.';

  @override
  String get offlineTag => 'غير متصل';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get refresh => 'تحديث';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get loading => 'جارٍ التحميل...';

  @override
  String get emptyStateTitle => 'لا توجد مواد علمية متاحة';

  @override
  String get emptyStateDescription =>
      'لا توجد مواد عرض تفصيلية معتمدة تطابق هذه المنطقة أو التخصص حالياً.';

  @override
  String get emptyStateAction => 'استعراض المكتبة';

  @override
  String get errorStateTitle => 'تعذر تحميل بطاقة المنتج';

  @override
  String get errorStateDescription =>
      'لم نتمكن من جلب بيانات الفعالية السريرية الأخيرة. يرجى التحقق من الاتصال والمحاولة مجدداً.';

  @override
  String get errorStateRetry => 'إعادة المحاولة';

  @override
  String get searchHint => 'ابحث في الدراسات والكتيبات الطبية...';

  @override
  String get navHome => 'العرض العلمي';

  @override
  String get navProducts => 'المنتجات';

  @override
  String get navLearning => 'الوحدات';

  @override
  String get navSchedule => 'الجدول';

  @override
  String get navProfile => 'الحساب';

  @override
  String get statusCompleted => 'معتمد';

  @override
  String get statusPending => 'قيد المراجعة';

  @override
  String get statusDraft => 'مسودة';

  @override
  String get statusUrgent => 'إلزامي';

  @override
  String get statusArchived => 'مؤرشف';

  @override
  String get showcaseTitle => 'أساس نظام التصميم';

  @override
  String get showcaseSubtitle => 'رموز التصميم ومكونات RxEdge الأساسية';

  @override
  String get colorsSection => 'لوحة الألوان';

  @override
  String get typographySection => 'الخطوط والطباعة';

  @override
  String get buttonsSection => 'الأزرار';

  @override
  String get textFieldsSection => 'حقول الإدخال';

  @override
  String get cardsSection => 'البطاقات والأسطح';

  @override
  String get chipsSection => 'الشرائح والفلاتر';

  @override
  String get badgesSection => 'شارات الحالة';

  @override
  String get progressSection => 'مؤشرات التقدم';

  @override
  String get feedbackSection => 'الحالات والتنبيهات';

  @override
  String get toggleTheme => 'تبديل المظهر';

  @override
  String get toggleLocale => 'English / العربية';

  @override
  String get btnPrimary => 'إجراء رئيسي';

  @override
  String get btnSecondary => 'إجراء ثانوي';

  @override
  String get btnGhost => 'إجراء فرعي';

  @override
  String get btnDestructive => 'حذف السجل';

  @override
  String get btnLoading => 'جارٍ المعالجة...';

  @override
  String get inputLabel => 'الطبيب المستهدف / العيادة';

  @override
  String get inputPlaceholder => 'مثال: د. سارة الشريف (أمراض القلب)';

  @override
  String get inputHelper => 'اختر من سجل الأطباء المعتمد بالمستشفى';

  @override
  String get inputError => 'اسم الطبيب مطلوب';
}
