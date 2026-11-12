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
  String get statusPending => 'Pending';

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

  @override
  String get challengesTitle => 'Field Challenges';

  @override
  String get tabMonthlyChallenge => 'Monthly Challenge';

  @override
  String get tabQuickQuizzes => 'Quick Quizzes';

  @override
  String get tabObjection => 'Objection of Month';

  @override
  String get btnHistory => 'History';

  @override
  String get historyTitle => 'Challenges & Quiz History';

  @override
  String get pastChallenges => 'Past Challenges';

  @override
  String get quizResultsHistory => 'Quiz Results';

  @override
  String get leaderboardTitle => 'Territory Leaderboard';

  @override
  String get pinnedMyRank => 'My Rank';

  @override
  String get rulesTitle => 'Challenge Rules';

  @override
  String get rewardsTitle => 'Achievement Rewards';

  @override
  String get myProgressTitle => 'My Challenge Progress';

  @override
  String get btnStartQuiz => 'Start Quiz';

  @override
  String get btnNextQuestion => 'Next Question';

  @override
  String get btnFinishQuiz => 'Finish Quiz';

  @override
  String quizQuestionProgress(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get quizScoreTitle => 'Quiz Completed';

  @override
  String get btnReviewMistakes => 'Review Mistakes';

  @override
  String get btnRetryQuiz => 'Retry';

  @override
  String get btnBackToLearning => 'Back to Challenges';

  @override
  String get highScoreBadge => 'Clinical Mastery Achieved';

  @override
  String get thinkFirstTitle => 'Think First';

  @override
  String get thinkFirstPrompt =>
      'How would you address this objection in the clinic before revealing the clinical recommendation?';

  @override
  String get btnRevealResponse => 'Reveal Recommended Response';

  @override
  String get wasThisHelpful => 'Was this response helpful?';

  @override
  String get btnHelpfulYes => 'Helpful';

  @override
  String get btnHelpfulNo => 'Needs Work';

  @override
  String get btnShareOwnResponse => 'Share Your Response';

  @override
  String get shareResponseTitle => 'Submit Field Objection Response';

  @override
  String get shareResponseHint =>
      'Write the exact phrasing that resonated with doctors in your territory...';

  @override
  String get btnSubmitResponse => 'Submit Response';

  @override
  String get responseSubmitted =>
      'Your response has been shared with medical affairs';

  @override
  String get emptyHistoryTitle => 'No History Recorded';

  @override
  String get emptyHistoryDesc =>
      'Completed challenges and quizzes will appear here.';

  @override
  String get feedbackTitle => 'Marketing Feedback';

  @override
  String get feedbackSubtitle =>
      'Share real clinic insights directly with medical affairs';

  @override
  String get typeDoctorObjection => 'Doctor Objection';

  @override
  String get descDoctorObjection =>
      'Real questions, skepticism, or pushback heard in clinic visits.';

  @override
  String get typeCompetitorClaim => 'Competitor Claim';

  @override
  String get descCompetitorClaim =>
      'Aggressive promotion or unverified clinical claims heard in territory.';

  @override
  String get typeFieldFeedback => 'Field Feedback';

  @override
  String get descFieldFeedback =>
      'Material requests, sample shortages, or commercial campaign ideas.';

  @override
  String get mySubmissions => 'My Submissions';

  @override
  String get emptySubmissionsTitle => 'No Feedback Submitted Yet';

  @override
  String get emptySubmissionsDesc =>
      'Submissions shape upcoming detailing materials and clinical rebuttal decks.';

  @override
  String get btnSendFeedback => 'Send Feedback';

  @override
  String get draftRestored => 'Draft restored';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get feedbackSentTitle => 'Sent. Your marketing team will see this.';

  @override
  String get feedbackQueuedTitle => 'Will send when you\'re back online';

  @override
  String get btnSendAnother => 'Send Another Feedback';

  @override
  String get btnBackHome => 'Back to Feedback';

  @override
  String get statusSent => 'Sent';

  @override
  String get statusSeen => 'Seen by Marketing';

  @override
  String get statusAnswered => 'Answered';

  @override
  String get marketingReply => 'Marketing & Medical Reply';

  @override
  String get noReplyYet =>
      'Marketing has received your submission and is reviewing it.';

  @override
  String get profileTitle => 'Profile & Settings';

  @override
  String get repDetails => 'Representative Details';

  @override
  String get territoryLabel => 'Territory';

  @override
  String get employeeIdLabel => 'Employee ID';

  @override
  String get pointsAndBadges => 'Points & Achievements';

  @override
  String streakDaysLabel(int days) {
    return '$days Days Streak';
  }

  @override
  String get settingsGeneral => 'General Settings';

  @override
  String get languagePreference => 'Language';

  @override
  String get themePreference => 'App Theme';

  @override
  String get themeSystem => 'System Default';

  @override
  String get themeLight => 'Light Theme';

  @override
  String get themeDark => 'Dark Theme';

  @override
  String get notificationPreferences => 'Notification Preferences';

  @override
  String get prefNewMaterials => 'New Marketing Materials';

  @override
  String get prefChallenges => 'Monthly Challenges';

  @override
  String get prefFeedbackReplies => 'Marketing Responses';

  @override
  String get prefQuizReminders => 'Quiz Deadlines';

  @override
  String get storageAndDownloads => 'Storage & Downloads';

  @override
  String offlineStorageUsed(String size) {
    return '$size Cached Offline';
  }

  @override
  String get btnClearDownloads => 'Clear Cached Downloads';

  @override
  String get clearDownloadsConfirm =>
      'Are you sure you want to remove all offline downloaded materials? You can re-download them anytime.';

  @override
  String get downloadsClearedToast => 'Offline downloads cleared';

  @override
  String get changePasswordTitle => 'Company Credentials';

  @override
  String get changePasswordDesc =>
      'Your employee account credentials are authenticated and managed by corporate IT & Commercial Operations. To change or reset your password, contact marketing support.';

  @override
  String get contactMarketingTitle => 'Contact Marketing Support';

  @override
  String get contactMarketingEmail => 'marketing@rxedgepharma.com';

  @override
  String get contactMarketingPhone => '+20 2 2795 4000';

  @override
  String get logoutTitle => 'Sign Out';

  @override
  String get logoutConfirm =>
      'Are you sure you want to sign out? You will need your employee credentials to sign back in.';

  @override
  String get appVersionLabel => 'RxEdge v1.0.0 (Build 24) • Clean Architecture';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get btnMarkAllRead => 'Mark all as read';

  @override
  String get emptyNotificationsTitle => 'All Caught Up';

  @override
  String get emptyNotificationsDesc =>
      'You have reviewed all clinical updates, quiz deadlines, and marketing messages.';

  @override
  String get globalSearchTitle => 'Search Everything';

  @override
  String get globalSearchPlaceholder =>
      'Search lessons, library materials, doctor objections...';

  @override
  String get recentSearchesTitle => 'Recent Searches';

  @override
  String get btnClearAll => 'Clear all';

  @override
  String get groupLessons => 'Clinical Lessons & Monographs';

  @override
  String get groupLibrary => 'Library Files & Visual Aids';

  @override
  String get groupObjections => 'Doctor Objections & Talking Points';

  @override
  String searchNoResultsTitle(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get searchNoResultsDesc =>
      'Try fewer words, check product spelling, or search by therapeutic area (e.g. Cardura XL, AtorvaCare).';

  @override
  String get offlineBannerConnected => 'Back online — synced with marketing';

  @override
  String get coachMarkTitle => 'Welcome to RxEdge';

  @override
  String get coachMarkSlide1Title => 'Instant Detailing Review';

  @override
  String get coachMarkSlide1Desc =>
      'Review approved clinical monographs, dosing schedules, and talking points in 30 seconds before your visit.';

  @override
  String get coachMarkSlide2Title => 'Reliable Offline Library';

  @override
  String get coachMarkSlide2Desc =>
      'Download brochures and e-detail slides to present seamlessly in hospital clinics with zero mobile signal.';

  @override
  String get coachMarkSlide3Title => 'Direct Voice to Marketing';

  @override
  String get coachMarkSlide3Desc =>
      'Log physician pushback and competitor claims from the field directly to medical affairs directors.';

  @override
  String get btnGotIt => 'Got It';

  @override
  String get btnSkip => 'Skip';

  @override
  String get btnClose => 'Close';

  @override
  String get btnClear => 'Clear';

  @override
  String get supportAndSecurity => 'Support & Security';

  @override
  String get actionSyncNow => 'Sync Now';

  @override
  String pendingSyncNotice(int count) {
    return '$count queued for sync';
  }

  @override
  String get defaultRepName => 'Field Representative';

  @override
  String get dailyDetailingItinerary => 'Daily Detailing Itinerary';

  @override
  String moduleProgressCount(int completed, int total) {
    return 'Module $completed of $total';
  }

  @override
  String get recommendedDetailingSubtitle =>
      'Master the key clinical trials and first-line detailing messaging.';

  @override
  String get clinicalDetailingGuidance => 'Clinical Detailing Guidance';

  @override
  String get recommendedClinicalCounter => 'Recommended Clinical Counter';

  @override
  String get profileTooltip => 'Profile';

  @override
  String get notificationsTooltip => 'Notifications';

  @override
  String get noLearningModulesTitle => 'No Learning Modules';

  @override
  String get noLearningModulesDesc =>
      'Clinical detailing modules will appear here once assigned by your medical director.';

  @override
  String get bookmarksLabel => 'Bookmarks';

  @override
  String get lessonModulesLabel => 'Lesson Modules';

  @override
  String get lessonsTabLabel => 'Lessons';

  @override
  String get noCompetitorsAvailable =>
      'No competitor comparisons available for this product.';

  @override
  String get clinicalRecallQuizTitle => 'Clinical Recall Quiz';

  @override
  String lessonQuizReinforceDesc(int count) {
    return 'Reinforce your detailing confidence with $count quick clinical recall questions.';
  }

  @override
  String lessonQuizDialogBody(int count) {
    return 'This quiz includes $count questions testing key study endpoints and competitor differentiation.';
  }

  @override
  String get btnStartQuizNow => 'Start Quiz Now (+50 Pts)';

  @override
  String get btnReviewLater => 'Review Later';

  @override
  String get offlineStatusBadge => 'Offline';

  @override
  String get onlineOnlyStatusBadge => 'Online only';

  @override
  String slidesCountLabel(int count) {
    return '$count slides';
  }

  @override
  String pagesCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages',
      one: '1 page',
    );
    return '$_temp0';
  }

  @override
  String get regulatoryMonographHeader => 'REGULATORY CLINICAL MONOGRAPH';

  @override
  String sectionNumberLabel(int number) {
    return 'SECTION $number';
  }

  @override
  String therapeuticClassLabel(String productName) {
    return 'Therapeutic Class: $productName';
  }

  @override
  String get clinicalVisualAidBadge => 'CLINICAL TRIAL VISUAL AID';

  @override
  String documentIdLabel(String id) {
    return 'Document ID: $id';
  }

  @override
  String get confidentialDetailingFooter => 'Confidential Medical Detailing';

  @override
  String get activeSprintBadge => 'Active Sprint';

  @override
  String timeLeftCountdown(int days, int hours) {
    return '${days}d ${hours}h left';
  }

  @override
  String get leaderboardUpdateCaption =>
      'Updated hourly across District medical reps';

  @override
  String get youLabel => 'You';

  @override
  String rankOfTotalDistrict(int rank, int total) {
    return 'Rank #$rank of $total in District';
  }

  @override
  String rankOfTotalSimple(int rank, int total) {
    return 'Rank #$rank of $total';
  }

  @override
  String get noQuizzesTitle => 'No Quizzes Available';

  @override
  String get noQuizzesDesc =>
      'New clinical quizzes will appear here with each detailing cycle.';

  @override
  String questionsCountLabel(int count) {
    return '$count questions';
  }

  @override
  String minutesCountLabel(int minutes) {
    return '$minutes min';
  }

  @override
  String scoreOutOfLabel(int score, int total) {
    return 'Score: $score/$total';
  }

  @override
  String get btnRetakeQuiz => 'Retake Quiz';

  @override
  String pointsPlusValue(int points) {
    return '+$points Pts';
  }

  @override
  String get correctRecallLabel => 'Correct Recall';

  @override
  String get clinicalRationaleLabel => 'Clinical Rationale';

  @override
  String scoreCorrectOfTotal(int score, int total) {
    return '$score of $total Questions Correct';
  }

  @override
  String get pointsEarnedLabel => 'Points Earned';

  @override
  String get timeElapsedLabel => 'Time Elapsed';

  @override
  String get btnHideMistakes => 'Hide Mistakes';

  @override
  String get flawlessAnswersMsg =>
      'Flawless! Zero incorrect answers to review.';

  @override
  String get incorrectBreakdownTitle => 'Incorrect Answers Breakdown';

  @override
  String yourAnswerPrefix(String answer) {
    return 'Your answer: $answer';
  }

  @override
  String correctAnswerPrefix(String answer) {
    return 'Correct answer: $answer';
  }

  @override
  String get recommendedClinicalResponseLabel =>
      'Recommended Clinical Response';

  @override
  String get keyDetailingAnchorsLabel => 'Key Detailing Anchors';

  @override
  String get unableLoadFeedback => 'Unable to load feedback';

  @override
  String get pendingOfflineWarning =>
      'Some submissions are pending offline and will sync when connected.';

  @override
  String get feedbackDetailsTitle => 'Feedback Details';

  @override
  String get submissionNotFound => 'Submission not found';

  @override
  String get fieldSubmissionHeader => 'Field Submission';

  @override
  String get labelProduct => 'Product';

  @override
  String get labelDoctorObjection => 'Doctor Objection';

  @override
  String get labelDoctorSpecialty => 'Doctor Specialty';

  @override
  String get labelHowResponded => 'How I Responded';

  @override
  String get labelCompetitor => 'Competitor';

  @override
  String get labelClaimHeard => 'Claim Heard';

  @override
  String get labelWhereHeard => 'Where Heard';

  @override
  String get labelTopic => 'Topic';

  @override
  String get labelDetails => 'Details';

  @override
  String optionalFieldSuffix(String label) {
    return '$label (optional)';
  }

  @override
  String get hintDoctorObjection =>
      'What exact concern or skepticism did the doctor express?';

  @override
  String get hintHowResponded =>
      'What clinical talking point or trial data did you share?';

  @override
  String get labelCompetitorProduct => 'Competitor Name & Product';

  @override
  String get hintCompetitorClaim =>
      'What promotional statement or comparison was made?';

  @override
  String get labelTopicCampaign => 'Topic / Campaign';

  @override
  String get hintDetails =>
      'Explain the situation or request clearly for the marketing team...';

  @override
  String get attachPhotoOptional =>
      'Attach flyer or promotional photo (optional)';

  @override
  String get photoAttachedLabel => 'Promotional photo attached';

  @override
  String get attachVoiceOptional => 'Attach quick voice note (optional)';

  @override
  String get voiceAttachedLabel => 'Voice note attached';

  @override
  String get medicalAffairsDefault => 'Medical Affairs';

  @override
  String get offlineQueueInfo =>
      'Saved offline. It will be sent automatically as soon as an internet connection is established.';

  @override
  String get submissionFailedFallback => 'Submission failed';

  @override
  String get feedbackSentExtraNote =>
      'Commercial marketing and medical affairs review field intelligence reports daily to update talking points.';

  @override
  String get feedbackQueuedExtraNote =>
      'Stored securely on your device. We will automatically submit it to medical affairs as soon as connection is restored.';

  @override
  String get selectProductOptional => 'Related Product (optional)';

  @override
  String get noProductSelected => 'General / No specific product';

  @override
  String get unableLoadNotifications => 'Unable to load notifications';

  @override
  String get unableLoadProfile => 'Unable to load profile';

  @override
  String get storageStatusDownloaded => 'Downloaded';

  @override
  String get storageStatusEmpty => 'Empty';

  @override
  String get offlineStorageDesc =>
      'Downloaded brochures, e-detail decks, and monographs are available when offline.';

  @override
  String get searchFailedTitle => 'Search failed';

  @override
  String get suggestedTopicsLabel => 'Suggested Topics';

  @override
  String get suggestedTopicDosing => 'Dosing';

  @override
  String get suggestedTopicHypotension => 'Hypotension';

  @override
  String get suggestedTopicGits => 'GITS delivery';

  @override
  String get systemDiagnosticsTitle => 'System Diagnostics';

  @override
  String get appMetadataTitle => 'Application Metadata';

  @override
  String get appMetadataSubtitle =>
      'Active runtime environment and build specification';

  @override
  String get unableLoadDiagnostics => 'Unable to Load Diagnostics';

  @override
  String get retryConnection => 'Retry Connection';

  @override
  String get minSupportedVersionLabel => 'Min Supported Version';

  @override
  String get maintenanceStatusLabel => 'Maintenance Status';

  @override
  String get maintenanceActive => 'Active (Read Only)';

  @override
  String get operationalStatus => 'Operational';

  @override
  String get apiEndpointLabel => 'API Endpoint';

  @override
  String get configuredBaseUrl => 'Configured Base URL';

  @override
  String get serverTimeLabel => 'Server Time';

  @override
  String get refreshSystemStatus => 'Refresh System Status';

  @override
  String get forgotHelpdeskTitle => 'Commercial IT & Marketing Helpdesk';

  @override
  String forgotSupportSentToast(String email) {
    return 'Support request sent to $email';
  }

  @override
  String get taglineFieldMedical => 'Field Medical Intelligence';

  @override
  String get pointTxQuizCompletion => 'Quick Quiz Reward';

  @override
  String get pointTxLessonCompletion => 'Module Completion Reward';

  @override
  String get pointTxChallengeReward => 'Monthly Challenge Bonus';

  @override
  String get pointTxManualAdjustment => 'Administrative Adjustment';

  @override
  String helpfulVotesCount(int count) {
    return '$count helpful votes';
  }

  @override
  String peersContributedCount(int count) {
    return '$count peers contributed field phrasing';
  }

  @override
  String minAgoCount(int count) {
    return '${count}m ago';
  }

  @override
  String hoursAgoCount(int count) {
    return '${count}h ago';
  }

  @override
  String daysAgoCount(int count) {
    return '${count}d ago';
  }

  @override
  String get topTenTerritoryBadge => 'Top 10% in Territory';

  @override
  String get productHintExamples => 'e.g. Cardura XL, AtorvaCare';

  @override
  String get specialtyHintExamples =>
      'e.g. Interventional Cardiologist, Nephrologist';

  @override
  String get competitorHintExamples => 'e.g. PharmaStar Generic Atorvastatin';

  @override
  String get whereHeardHintExamples =>
      'e.g. Cardiology CME Conference, Hospital Dept Meeting';

  @override
  String get topicHintExamples =>
      'e.g. Sample Availability, Laminated Visual Aid Request';

  @override
  String get errNetwork =>
      'No internet connection. Please check your network and try again.';

  @override
  String get errUnauthorized =>
      'Your session is unauthorized or expired. Please sign in again.';

  @override
  String get errNotFound => 'Requested content could not be found.';

  @override
  String get errValidation =>
      'Please check the highlighted fields and try again.';

  @override
  String get errCache => 'Unable to read local offline cache.';

  @override
  String get errServer =>
      'The server encountered an error. Please try again shortly.';

  @override
  String get errUnknown => 'An unexpected error occurred. Please try again.';
}
