// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'RxEdge';

  @override
  String get tagline =>
      'Medical Representative Learning & Field Resource Platform';

  @override
  String get offlineNotice =>
      'You\'re offline. Changes are saved locally and will sync once reconnected.';

  @override
  String get offlineTag => 'Offline';

  @override
  String get retry => 'Retry';

  @override
  String get refresh => 'Refresh';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get loading => 'Loading...';

  @override
  String get emptyStateTitle => 'No scientific materials found';

  @override
  String get emptyStateDescription =>
      'There are no approved detailing materials matching this territory or specialty yet.';

  @override
  String get emptyStateAction => 'Browse Library';

  @override
  String get errorStateTitle => 'Unable to load detailing card';

  @override
  String get errorStateDescription =>
      'We couldn\'t retrieve the latest efficacy data. Please check your connection and try again.';

  @override
  String get errorStateRetry => 'Try Again';

  @override
  String get searchHint => 'Search drug monographs, guidelines...';

  @override
  String get navHome => 'Detailing';

  @override
  String get navProducts => 'Products';

  @override
  String get navLearning => 'Modules';

  @override
  String get navSchedule => 'Schedule';

  @override
  String get navProfile => 'Profile';

  @override
  String get statusCompleted => 'Approved';

  @override
  String get statusPending => 'In Review';

  @override
  String get statusDraft => 'Draft';

  @override
  String get statusUrgent => 'Required';

  @override
  String get statusArchived => 'Archived';

  @override
  String get showcaseTitle => 'Design System Foundation';

  @override
  String get showcaseSubtitle => 'RxEdge Design Tokens & Core Components';

  @override
  String get colorsSection => 'Color Palette';

  @override
  String get typographySection => 'Typography';

  @override
  String get buttonsSection => 'Buttons';

  @override
  String get textFieldsSection => 'Input Fields';

  @override
  String get cardsSection => 'Surface Cards';

  @override
  String get chipsSection => 'Chips & Selectors';

  @override
  String get badgesSection => 'Status Badges';

  @override
  String get progressSection => 'Progress Indicators';

  @override
  String get feedbackSection => 'States & Feedback';

  @override
  String get toggleTheme => 'Switch Theme';

  @override
  String get toggleLocale => 'العربية / English';

  @override
  String get btnPrimary => 'Primary Action';

  @override
  String get btnSecondary => 'Secondary Action';

  @override
  String get btnGhost => 'Ghost Action';

  @override
  String get btnDestructive => 'Delete Record';

  @override
  String get btnLoading => 'Processing...';

  @override
  String get inputLabel => 'Target Physician / Clinic';

  @override
  String get inputPlaceholder => 'e.g. Dr. Sarah Jenkins (Cardiology)';

  @override
  String get inputHelper => 'Select from verified hospital registry';

  @override
  String get inputError => 'Physician name is required';
}
