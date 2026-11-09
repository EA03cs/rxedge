import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'RxEdge'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Medical Representative Learning & Field Resource Platform'**
  String get tagline;

  /// No description provided for @offlineNotice.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Changes are saved locally and will sync once reconnected.'**
  String get offlineNotice;

  /// No description provided for @offlineTag.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offlineTag;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @emptyStateTitle.
  ///
  /// In en, this message translates to:
  /// **'No scientific materials found'**
  String get emptyStateTitle;

  /// No description provided for @emptyStateDescription.
  ///
  /// In en, this message translates to:
  /// **'There are no approved detailing materials matching this territory or specialty yet.'**
  String get emptyStateDescription;

  /// No description provided for @emptyStateAction.
  ///
  /// In en, this message translates to:
  /// **'Browse Library'**
  String get emptyStateAction;

  /// No description provided for @errorStateTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to load detailing card'**
  String get errorStateTitle;

  /// No description provided for @errorStateDescription.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t retrieve the latest efficacy data. Please check your connection and try again.'**
  String get errorStateDescription;

  /// No description provided for @errorStateRetry.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get errorStateRetry;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search drug monographs, guidelines...'**
  String get searchHint;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Detailing'**
  String get navHome;

  /// No description provided for @navProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get navProducts;

  /// No description provided for @navLearning.
  ///
  /// In en, this message translates to:
  /// **'Modules'**
  String get navLearning;

  /// No description provided for @navSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get navSchedule;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabLearn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get tabLearn;

  /// No description provided for @tabLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get tabLibrary;

  /// No description provided for @tabChallenges.
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get tabChallenges;

  /// No description provided for @tabFeedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get tabFeedback;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get statusCompleted;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'In Review'**
  String get statusPending;

  /// No description provided for @statusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get statusDraft;

  /// No description provided for @statusUrgent.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get statusUrgent;

  /// No description provided for @statusArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get statusArchived;

  /// No description provided for @showcaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Design System Foundation'**
  String get showcaseTitle;

  /// No description provided for @showcaseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'RxEdge Design Tokens & Core Components'**
  String get showcaseSubtitle;

  /// No description provided for @colorsSection.
  ///
  /// In en, this message translates to:
  /// **'Color Palette'**
  String get colorsSection;

  /// No description provided for @typographySection.
  ///
  /// In en, this message translates to:
  /// **'Typography'**
  String get typographySection;

  /// No description provided for @buttonsSection.
  ///
  /// In en, this message translates to:
  /// **'Buttons'**
  String get buttonsSection;

  /// No description provided for @textFieldsSection.
  ///
  /// In en, this message translates to:
  /// **'Input Fields'**
  String get textFieldsSection;

  /// No description provided for @cardsSection.
  ///
  /// In en, this message translates to:
  /// **'Surface Cards'**
  String get cardsSection;

  /// No description provided for @chipsSection.
  ///
  /// In en, this message translates to:
  /// **'Chips & Selectors'**
  String get chipsSection;

  /// No description provided for @badgesSection.
  ///
  /// In en, this message translates to:
  /// **'Status Badges'**
  String get badgesSection;

  /// No description provided for @progressSection.
  ///
  /// In en, this message translates to:
  /// **'Progress Indicators'**
  String get progressSection;

  /// No description provided for @feedbackSection.
  ///
  /// In en, this message translates to:
  /// **'States & Feedback'**
  String get feedbackSection;

  /// No description provided for @toggleTheme.
  ///
  /// In en, this message translates to:
  /// **'Switch Theme'**
  String get toggleTheme;

  /// No description provided for @toggleLocale.
  ///
  /// In en, this message translates to:
  /// **'العربية / English'**
  String get toggleLocale;

  /// No description provided for @btnPrimary.
  ///
  /// In en, this message translates to:
  /// **'Primary Action'**
  String get btnPrimary;

  /// No description provided for @btnSecondary.
  ///
  /// In en, this message translates to:
  /// **'Secondary Action'**
  String get btnSecondary;

  /// No description provided for @btnGhost.
  ///
  /// In en, this message translates to:
  /// **'Ghost Action'**
  String get btnGhost;

  /// No description provided for @btnDestructive.
  ///
  /// In en, this message translates to:
  /// **'Delete Record'**
  String get btnDestructive;

  /// No description provided for @btnLoading.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get btnLoading;

  /// No description provided for @inputLabel.
  ///
  /// In en, this message translates to:
  /// **'Target Physician / Clinic'**
  String get inputLabel;

  /// No description provided for @inputPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. Dr. Sarah Jenkins (Cardiology)'**
  String get inputPlaceholder;

  /// No description provided for @inputHelper.
  ///
  /// In en, this message translates to:
  /// **'Select from verified hospital registry'**
  String get inputHelper;

  /// No description provided for @inputError.
  ///
  /// In en, this message translates to:
  /// **'Physician name is required'**
  String get inputError;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Learn every product'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'Access concise clinical monographs, dosing guides, and efficacy trials between doctor visits.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Find any material in seconds'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'Pull up approved detailing decks and study summaries without searching through email threads.'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Tell marketing what you see in the field'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'Share doctor feedback and physician objections directly to shape upcoming launch campaigns.'**
  String get onboardingDesc3;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to RxEdge'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Access your approved clinical detailing tools'**
  String get loginSubtitle;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Work Email or Employee ID'**
  String get usernameLabel;

  /// No description provided for @usernameHint.
  ///
  /// In en, this message translates to:
  /// **'rep@pharma.com or MR-1049'**
  String get usernameHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter corporate password'**
  String get passwordHint;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @companyAccountNote.
  ///
  /// In en, this message translates to:
  /// **'Accounts are provided by your company'**
  String get companyAccountNote;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @usernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Work Email or Employee ID is required'**
  String get usernameRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password. Please verify and try again.'**
  String get invalidCredentials;

  /// No description provided for @keepMeSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Keep me signed in'**
  String get keepMeSignedIn;

  /// No description provided for @biometricPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable Biometric Unlock?'**
  String get biometricPromptTitle;

  /// No description provided for @biometricPromptDesc.
  ///
  /// In en, this message translates to:
  /// **'Unlock RxEdge instantly between clinic visits using your fingerprint or Face ID.'**
  String get biometricPromptDesc;

  /// No description provided for @enableBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Enable Biometrics'**
  String get enableBiometrics;

  /// No description provided for @maybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get maybeLater;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Need Password Assistance?'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordInstructions.
  ///
  /// In en, this message translates to:
  /// **'RxEdge accounts are managed centrally by your enterprise identity provider. To reset your credentials, please reach out to your Field Marketing or Commercial IT administrator.'**
  String get forgotPasswordInstructions;

  /// No description provided for @contactMarketing.
  ///
  /// In en, this message translates to:
  /// **'Contact Marketing & IT Support'**
  String get contactMarketing;

  /// No description provided for @supportEmail.
  ///
  /// In en, this message translates to:
  /// **'support@rxedge.internal'**
  String get supportEmail;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Sign In'**
  String get backToLogin;

  /// No description provided for @sessionExpiredNotice.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again to continue.'**
  String get sessionExpiredNotice;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning, {name}'**
  String greetingMorning(String name);

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon, {name}'**
  String greetingAfternoon(String name);

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening, {name}'**
  String greetingEvening(String name);

  /// No description provided for @searchHintHome.
  ///
  /// In en, this message translates to:
  /// **'Search drug monographs, guidelines...'**
  String get searchHintHome;

  /// No description provided for @continueLearningTitle.
  ///
  /// In en, this message translates to:
  /// **'Continue Learning'**
  String get continueLearningTitle;

  /// No description provided for @btnContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get btnContinue;

  /// No description provided for @btnStartLesson.
  ///
  /// In en, this message translates to:
  /// **'Start Lesson'**
  String get btnStartLesson;

  /// No description provided for @noLessonStarted.
  ///
  /// In en, this message translates to:
  /// **'Start with {productName}'**
  String noLessonStarted(String productName);

  /// No description provided for @recommendedLabel.
  ///
  /// In en, this message translates to:
  /// **'Recommended for your territory'**
  String get recommendedLabel;

  /// No description provided for @monthlyChallengeTitle.
  ///
  /// In en, this message translates to:
  /// **'This Month\'s Challenge'**
  String get monthlyChallengeTitle;

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'{days} days left'**
  String daysLeft(int days);

  /// No description provided for @rankInDistrict.
  ///
  /// In en, this message translates to:
  /// **'Rank #{rank} of {total} in District'**
  String rankInDistrict(int rank, int total);

  /// No description provided for @objectionOfTheMonth.
  ///
  /// In en, this message translates to:
  /// **'Objection of the Month'**
  String get objectionOfTheMonth;

  /// No description provided for @seeHowToRespond.
  ///
  /// In en, this message translates to:
  /// **'See how to respond'**
  String get seeHowToRespond;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @quickActionQuiz.
  ///
  /// In en, this message translates to:
  /// **'Quick quiz'**
  String get quickActionQuiz;

  /// No description provided for @quickActionFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get quickActionFeedback;

  /// No description provided for @quickActionLibrary.
  ///
  /// In en, this message translates to:
  /// **'Search library'**
  String get quickActionLibrary;

  /// No description provided for @whatsNew.
  ///
  /// In en, this message translates to:
  /// **'What\'s New'**
  String get whatsNew;

  /// No description provided for @badgeNew.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get badgeNew;

  /// No description provided for @badgeUpdated.
  ///
  /// In en, this message translates to:
  /// **'UPDATED'**
  String get badgeUpdated;

  /// No description provided for @statPoints.
  ///
  /// In en, this message translates to:
  /// **'{points} Pts'**
  String statPoints(int points);

  /// No description provided for @statStreak.
  ///
  /// In en, this message translates to:
  /// **'{days}-Day Streak'**
  String statStreak(int days);

  /// No description provided for @statQuizzes.
  ///
  /// In en, this message translates to:
  /// **'{count} Quizzes'**
  String statQuizzes(int count);

  /// No description provided for @statPointsLabel.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get statPointsLabel;

  /// No description provided for @statStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get statStreakLabel;

  /// No description provided for @statQuizzesLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statQuizzesLabel;

  /// No description provided for @libraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Resource Library'**
  String get libraryTitle;

  /// No description provided for @librarySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search materials, monographs, trials...'**
  String get librarySearchHint;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterBrochures.
  ///
  /// In en, this message translates to:
  /// **'Brochures'**
  String get filterBrochures;

  /// No description provided for @filterVisualAids.
  ///
  /// In en, this message translates to:
  /// **'Visual Aids'**
  String get filterVisualAids;

  /// No description provided for @filterEDetail.
  ///
  /// In en, this message translates to:
  /// **'E-Detail'**
  String get filterEDetail;

  /// No description provided for @filterMarketing.
  ///
  /// In en, this message translates to:
  /// **'Marketing Materials'**
  String get filterMarketing;

  /// No description provided for @filterAllProducts.
  ///
  /// In en, this message translates to:
  /// **'All Products'**
  String get filterAllProducts;

  /// No description provided for @sortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get sortNewest;

  /// No description provided for @sortMostUsed.
  ///
  /// In en, this message translates to:
  /// **'Most used'**
  String get sortMostUsed;

  /// No description provided for @sortAlphabetical.
  ///
  /// In en, this message translates to:
  /// **'A to Z'**
  String get sortAlphabetical;

  /// No description provided for @shortcutFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get shortcutFavorites;

  /// No description provided for @shortcutDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get shortcutDownloaded;

  /// No description provided for @viewGrid.
  ///
  /// In en, this message translates to:
  /// **'Grid view'**
  String get viewGrid;

  /// No description provided for @viewList.
  ///
  /// In en, this message translates to:
  /// **'List view'**
  String get viewList;

  /// No description provided for @actionFavorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get actionFavorite;

  /// No description provided for @actionUnfavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get actionUnfavorite;

  /// No description provided for @actionDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get actionDownload;

  /// No description provided for @actionDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading {progress}%'**
  String actionDownloading(int progress);

  /// No description provided for @actionCancelDownload.
  ///
  /// In en, this message translates to:
  /// **'Cancel download'**
  String get actionCancelDownload;

  /// No description provided for @actionRemoveDownload.
  ///
  /// In en, this message translates to:
  /// **'Remove download'**
  String get actionRemoveDownload;

  /// No description provided for @actionShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get actionShare;

  /// No description provided for @actionOpenFile.
  ///
  /// In en, this message translates to:
  /// **'Open file'**
  String get actionOpenFile;

  /// No description provided for @offlineAvailable.
  ///
  /// In en, this message translates to:
  /// **'Offline available'**
  String get offlineAvailable;

  /// No description provided for @requiresDownload.
  ///
  /// In en, this message translates to:
  /// **'Requires download to view offline'**
  String get requiresDownload;

  /// No description provided for @emptySearchResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String emptySearchResultsTitle(String query);

  /// No description provided for @emptySearchResultsDesc.
  ///
  /// In en, this message translates to:
  /// **'Try fewer words or clear active filters.'**
  String get emptySearchResultsDesc;

  /// No description provided for @emptyFavoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'No favorites saved yet'**
  String get emptyFavoritesTitle;

  /// No description provided for @emptyFavoritesDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap the bookmark icon on any clinical material to access it instantly here.'**
  String get emptyFavoritesDesc;

  /// No description provided for @emptyDownloadsTitle.
  ///
  /// In en, this message translates to:
  /// **'No materials downloaded'**
  String get emptyDownloadsTitle;

  /// No description provided for @emptyDownloadsDesc.
  ///
  /// In en, this message translates to:
  /// **'Download clinical decks and monographs to present to physicians without cell coverage.'**
  String get emptyDownloadsDesc;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear all filters'**
  String get clearFilters;

  /// No description provided for @pageIndicator.
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String pageIndicator(int current, int total);

  /// No description provided for @slideIndicator.
  ///
  /// In en, this message translates to:
  /// **'Slide {current} of {total}'**
  String slideIndicator(int current, int total);

  /// No description provided for @zoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get zoomIn;

  /// No description provided for @zoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get zoomOut;

  /// No description provided for @resetZoom.
  ///
  /// In en, this message translates to:
  /// **'Reset zoom'**
  String get resetZoom;

  /// No description provided for @detailingKeyPoints.
  ///
  /// In en, this message translates to:
  /// **'Doctor Detailing Key Points'**
  String get detailingKeyPoints;

  /// No description provided for @hideChromeHint.
  ///
  /// In en, this message translates to:
  /// **'Tap screen to toggle controls'**
  String get hideChromeHint;

  /// No description provided for @materialsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 approved material} other{{count} approved materials}}'**
  String materialsCount(int count);

  /// No description provided for @learnTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Learning Hub'**
  String get learnTitle;

  /// No description provided for @learnSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Master product science and competitive detailing'**
  String get learnSubtitle;

  /// No description provided for @tabPositioning.
  ///
  /// In en, this message translates to:
  /// **'Product Positioning'**
  String get tabPositioning;

  /// No description provided for @tabCompetitive.
  ///
  /// In en, this message translates to:
  /// **'Competitive Handling'**
  String get tabCompetitive;

  /// No description provided for @lessonsCompleted.
  ///
  /// In en, this message translates to:
  /// **'{completed}/{total} lessons completed'**
  String lessonsCompleted(int completed, int total);

  /// No description provided for @btnBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get btnBookmarks;

  /// No description provided for @keyMessage.
  ///
  /// In en, this message translates to:
  /// **'Key Message'**
  String get keyMessage;

  /// No description provided for @targetDoctors.
  ///
  /// In en, this message translates to:
  /// **'Target Doctors'**
  String get targetDoctors;

  /// No description provided for @keyBenefits.
  ///
  /// In en, this message translates to:
  /// **'Key Benefits'**
  String get keyBenefits;

  /// No description provided for @dosageHighlights.
  ///
  /// In en, this message translates to:
  /// **'Dosage Highlights'**
  String get dosageHighlights;

  /// No description provided for @proofPoints.
  ///
  /// In en, this message translates to:
  /// **'Proof Points'**
  String get proofPoints;

  /// No description provided for @theirClaim.
  ///
  /// In en, this message translates to:
  /// **'Their claim'**
  String get theirClaim;

  /// No description provided for @howToRespond.
  ///
  /// In en, this message translates to:
  /// **'How to respond'**
  String get howToRespond;

  /// No description provided for @proofReference.
  ///
  /// In en, this message translates to:
  /// **'Proof / reference'**
  String get proofReference;

  /// No description provided for @copyTalkingPoint.
  ///
  /// In en, this message translates to:
  /// **'Copy talking point'**
  String get copyTalkingPoint;

  /// No description provided for @talkingPointCopied.
  ///
  /// In en, this message translates to:
  /// **'Talking point copied to clipboard'**
  String get talkingPointCopied;

  /// No description provided for @markAsComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark as complete'**
  String get markAsComplete;

  /// No description provided for @completedBadge.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedBadge;

  /// No description provided for @takeQuickQuiz.
  ///
  /// In en, this message translates to:
  /// **'Take quick quiz'**
  String get takeQuickQuiz;

  /// No description provided for @nextStep.
  ///
  /// In en, this message translates to:
  /// **'Next Step'**
  String get nextStep;

  /// No description provided for @bookmarksTitle.
  ///
  /// In en, this message translates to:
  /// **'Bookmarked Lessons'**
  String get bookmarksTitle;

  /// No description provided for @emptyBookmarksTitle.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks saved yet'**
  String get emptyBookmarksTitle;

  /// No description provided for @emptyBookmarksDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap the bookmark icon while reading any lesson to save it for quick review.'**
  String get emptyBookmarksDesc;

  /// No description provided for @btnBrowseLessons.
  ///
  /// In en, this message translates to:
  /// **'Browse Learning Hub'**
  String get btnBrowseLessons;

  /// No description provided for @recommendedTag.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommendedTag;

  /// No description provided for @inProgressTag.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgressTag;

  /// No description provided for @challengesTitle.
  ///
  /// In en, this message translates to:
  /// **'Field Challenges'**
  String get challengesTitle;

  /// No description provided for @tabMonthlyChallenge.
  ///
  /// In en, this message translates to:
  /// **'Monthly Challenge'**
  String get tabMonthlyChallenge;

  /// No description provided for @tabQuickQuizzes.
  ///
  /// In en, this message translates to:
  /// **'Quick Quizzes'**
  String get tabQuickQuizzes;

  /// No description provided for @tabObjection.
  ///
  /// In en, this message translates to:
  /// **'Objection of Month'**
  String get tabObjection;

  /// No description provided for @btnHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get btnHistory;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Challenges & Quiz History'**
  String get historyTitle;

  /// No description provided for @pastChallenges.
  ///
  /// In en, this message translates to:
  /// **'Past Challenges'**
  String get pastChallenges;

  /// No description provided for @quizResultsHistory.
  ///
  /// In en, this message translates to:
  /// **'Quiz Results'**
  String get quizResultsHistory;

  /// No description provided for @leaderboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Territory Leaderboard'**
  String get leaderboardTitle;

  /// No description provided for @pinnedMyRank.
  ///
  /// In en, this message translates to:
  /// **'My Rank'**
  String get pinnedMyRank;

  /// No description provided for @rulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Challenge Rules'**
  String get rulesTitle;

  /// No description provided for @rewardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievement Rewards'**
  String get rewardsTitle;

  /// No description provided for @myProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'My Challenge Progress'**
  String get myProgressTitle;

  /// No description provided for @btnStartQuiz.
  ///
  /// In en, this message translates to:
  /// **'Start Quiz'**
  String get btnStartQuiz;

  /// No description provided for @btnNextQuestion.
  ///
  /// In en, this message translates to:
  /// **'Next Question'**
  String get btnNextQuestion;

  /// No description provided for @btnFinishQuiz.
  ///
  /// In en, this message translates to:
  /// **'Finish Quiz'**
  String get btnFinishQuiz;

  /// No description provided for @quizQuestionProgress.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String quizQuestionProgress(int current, int total);

  /// No description provided for @quizScoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Quiz Completed'**
  String get quizScoreTitle;

  /// No description provided for @btnReviewMistakes.
  ///
  /// In en, this message translates to:
  /// **'Review Mistakes'**
  String get btnReviewMistakes;

  /// No description provided for @btnRetryQuiz.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get btnRetryQuiz;

  /// No description provided for @btnBackToLearning.
  ///
  /// In en, this message translates to:
  /// **'Back to Challenges'**
  String get btnBackToLearning;

  /// No description provided for @highScoreBadge.
  ///
  /// In en, this message translates to:
  /// **'Clinical Mastery Achieved'**
  String get highScoreBadge;

  /// No description provided for @thinkFirstTitle.
  ///
  /// In en, this message translates to:
  /// **'Think First'**
  String get thinkFirstTitle;

  /// No description provided for @thinkFirstPrompt.
  ///
  /// In en, this message translates to:
  /// **'How would you address this objection in the clinic before revealing the clinical recommendation?'**
  String get thinkFirstPrompt;

  /// No description provided for @btnRevealResponse.
  ///
  /// In en, this message translates to:
  /// **'Reveal Recommended Response'**
  String get btnRevealResponse;

  /// No description provided for @wasThisHelpful.
  ///
  /// In en, this message translates to:
  /// **'Was this response helpful?'**
  String get wasThisHelpful;

  /// No description provided for @btnHelpfulYes.
  ///
  /// In en, this message translates to:
  /// **'Helpful'**
  String get btnHelpfulYes;

  /// No description provided for @btnHelpfulNo.
  ///
  /// In en, this message translates to:
  /// **'Needs Work'**
  String get btnHelpfulNo;

  /// No description provided for @btnShareOwnResponse.
  ///
  /// In en, this message translates to:
  /// **'Share Your Response'**
  String get btnShareOwnResponse;

  /// No description provided for @shareResponseTitle.
  ///
  /// In en, this message translates to:
  /// **'Submit Field Objection Response'**
  String get shareResponseTitle;

  /// No description provided for @shareResponseHint.
  ///
  /// In en, this message translates to:
  /// **'Write the exact phrasing that resonated with doctors in your territory...'**
  String get shareResponseHint;

  /// No description provided for @btnSubmitResponse.
  ///
  /// In en, this message translates to:
  /// **'Submit Response'**
  String get btnSubmitResponse;

  /// No description provided for @responseSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Your response has been shared with medical affairs'**
  String get responseSubmitted;

  /// No description provided for @emptyHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'No History Recorded'**
  String get emptyHistoryTitle;

  /// No description provided for @emptyHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Completed challenges and quizzes will appear here.'**
  String get emptyHistoryDesc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
