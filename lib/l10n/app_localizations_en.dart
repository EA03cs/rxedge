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

  @override
  String get libraryTitle => 'Resource Library';

  @override
  String get librarySearchHint => 'Search materials, monographs, trials...';

  @override
  String get filterAll => 'All';

  @override
  String get filterBrochures => 'Brochures';

  @override
  String get filterVisualAids => 'Visual Aids';

  @override
  String get filterEDetail => 'E-Detail';

  @override
  String get filterMarketing => 'Marketing Materials';

  @override
  String get filterAllProducts => 'All Products';

  @override
  String get sortNewest => 'Newest';

  @override
  String get sortMostUsed => 'Most used';

  @override
  String get sortAlphabetical => 'A to Z';

  @override
  String get shortcutFavorites => 'Favorites';

  @override
  String get shortcutDownloaded => 'Downloaded';

  @override
  String get viewGrid => 'Grid view';

  @override
  String get viewList => 'List view';

  @override
  String get actionFavorite => 'Favorite';

  @override
  String get actionUnfavorite => 'Remove from favorites';

  @override
  String get actionDownload => 'Download';

  @override
  String actionDownloading(int progress) {
    return 'Downloading $progress%';
  }

  @override
  String get actionCancelDownload => 'Cancel download';

  @override
  String get actionRemoveDownload => 'Remove download';

  @override
  String get actionShare => 'Share';

  @override
  String get actionOpenFile => 'Open file';

  @override
  String get offlineAvailable => 'Offline available';

  @override
  String get requiresDownload => 'Requires download to view offline';

  @override
  String emptySearchResultsTitle(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get emptySearchResultsDesc =>
      'Try fewer words or clear active filters.';

  @override
  String get emptyFavoritesTitle => 'No favorites saved yet';

  @override
  String get emptyFavoritesDesc =>
      'Tap the bookmark icon on any clinical material to access it instantly here.';

  @override
  String get emptyDownloadsTitle => 'No materials downloaded';

  @override
  String get emptyDownloadsDesc =>
      'Download clinical decks and monographs to present to physicians without cell coverage.';

  @override
  String get clearFilters => 'Clear all filters';

  @override
  String pageIndicator(int current, int total) {
    return 'Page $current of $total';
  }

  @override
  String slideIndicator(int current, int total) {
    return 'Slide $current of $total';
  }

  @override
  String get zoomIn => 'Zoom in';

  @override
  String get zoomOut => 'Zoom out';

  @override
  String get resetZoom => 'Reset zoom';

  @override
  String get detailingKeyPoints => 'Doctor Detailing Key Points';

  @override
  String get hideChromeHint => 'Tap screen to toggle controls';

  @override
  String materialsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count approved materials',
      one: '1 approved material',
    );
    return '$_temp0';
  }

  @override
  String get learnTitle => 'Smart Learning Hub';

  @override
  String get learnSubtitle =>
      'Master product science and competitive detailing';

  @override
  String get tabPositioning => 'Product Positioning';

  @override
  String get tabCompetitive => 'Competitive Handling';

  @override
  String lessonsCompleted(int completed, int total) {
    return '$completed/$total lessons completed';
  }

  @override
  String get btnBookmarks => 'Bookmarks';

  @override
  String get keyMessage => 'Key Message';

  @override
  String get targetDoctors => 'Target Doctors';

  @override
  String get keyBenefits => 'Key Benefits';

  @override
  String get dosageHighlights => 'Dosage Highlights';

  @override
  String get proofPoints => 'Proof Points';

  @override
  String get theirClaim => 'Their claim';

  @override
  String get howToRespond => 'How to respond';

  @override
  String get proofReference => 'Proof / reference';

  @override
  String get copyTalkingPoint => 'Copy talking point';

  @override
  String get talkingPointCopied => 'Talking point copied to clipboard';

  @override
  String get markAsComplete => 'Mark as complete';

  @override
  String get completedBadge => 'Completed';

  @override
  String get takeQuickQuiz => 'Take quick quiz';

  @override
  String get nextStep => 'Next Step';

  @override
  String get bookmarksTitle => 'Bookmarked Lessons';

  @override
  String get emptyBookmarksTitle => 'No bookmarks saved yet';

  @override
  String get emptyBookmarksDesc =>
      'Tap the bookmark icon while reading any lesson to save it for quick review.';

  @override
  String get btnBrowseLessons => 'Browse Learning Hub';

  @override
  String get recommendedTag => 'Recommended';

  @override
  String get inProgressTag => 'In Progress';
}
