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
  String get tabHome => 'Home';

  @override
  String get tabLearn => 'Learn';

  @override
  String get tabLibrary => 'Library';

  @override
  String get tabChallenges => 'Challenges';

  @override
  String get tabFeedback => 'Feedback';

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

  @override
  String get onboardingTitle1 => 'Learn every product';

  @override
  String get onboardingDesc1 =>
      'Access concise clinical monographs, dosing guides, and efficacy trials between doctor visits.';

  @override
  String get onboardingTitle2 => 'Find any material in seconds';

  @override
  String get onboardingDesc2 =>
      'Pull up approved detailing decks and study summaries without searching through email threads.';

  @override
  String get onboardingTitle3 => 'Tell marketing what you see in the field';

  @override
  String get onboardingDesc3 =>
      'Share doctor feedback and physician objections directly to shape upcoming launch campaigns.';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get started';

  @override
  String get loginTitle => 'Sign in to RxEdge';

  @override
  String get loginSubtitle => 'Access your approved clinical detailing tools';

  @override
  String get usernameLabel => 'Work Email or Employee ID';

  @override
  String get usernameHint => 'rep@pharma.com or MR-1049';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Enter corporate password';

  @override
  String get signIn => 'Sign in';

  @override
  String get companyAccountNote => 'Accounts are provided by your company';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get usernameRequired => 'Work Email or Employee ID is required';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get invalidCredentials =>
      'Invalid username or password. Please verify and try again.';

  @override
  String get keepMeSignedIn => 'Keep me signed in';

  @override
  String get biometricPromptTitle => 'Enable Biometric Unlock?';

  @override
  String get biometricPromptDesc =>
      'Unlock RxEdge instantly between clinic visits using your fingerprint or Face ID.';

  @override
  String get enableBiometrics => 'Enable Biometrics';

  @override
  String get maybeLater => 'Maybe later';

  @override
  String get forgotPasswordTitle => 'Need Password Assistance?';

  @override
  String get forgotPasswordInstructions =>
      'RxEdge accounts are managed centrally by your enterprise identity provider. To reset your credentials, please reach out to your Field Marketing or Commercial IT administrator.';

  @override
  String get contactMarketing => 'Contact Marketing & IT Support';

  @override
  String get supportEmail => 'support@rxedge.internal';

  @override
  String get backToLogin => 'Back to Sign In';

  @override
  String get sessionExpiredNotice =>
      'Your session has expired. Please sign in again to continue.';

  @override
  String greetingMorning(String name) {
    return 'Good morning, $name';
  }

  @override
  String greetingAfternoon(String name) {
    return 'Good afternoon, $name';
  }

  @override
  String greetingEvening(String name) {
    return 'Good evening, $name';
  }

  @override
  String get searchHintHome => 'Search drug monographs, guidelines...';

  @override
  String get continueLearningTitle => 'Continue Learning';

  @override
  String get btnContinue => 'Continue';

  @override
  String get btnStartLesson => 'Start Lesson';

  @override
  String noLessonStarted(String productName) {
    return 'Start with $productName';
  }

  @override
  String get recommendedLabel => 'Recommended for your territory';

  @override
  String get monthlyChallengeTitle => 'This Month\'s Challenge';

  @override
  String daysLeft(int days) {
    return '$days days left';
  }

  @override
  String rankInDistrict(int rank, int total) {
    return 'Rank #$rank of $total in District';
  }

  @override
  String get objectionOfTheMonth => 'Objection of the Month';

  @override
  String get seeHowToRespond => 'See how to respond';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get quickActionQuiz => 'Quick quiz';

  @override
  String get quickActionFeedback => 'Send feedback';

  @override
  String get quickActionLibrary => 'Search library';

  @override
  String get whatsNew => 'What\'s New';

  @override
  String get badgeNew => 'NEW';

  @override
  String get badgeUpdated => 'UPDATED';

  @override
  String statPoints(int points) {
    return '$points Pts';
  }

  @override
  String statStreak(int days) {
    return '$days-Day Streak';
  }

  @override
  String statQuizzes(int count) {
    return '$count Quizzes';
  }

  @override
  String get statPointsLabel => 'Points';

  @override
  String get statStreakLabel => 'Streak';

  @override
  String get statQuizzesLabel => 'Completed';
}
