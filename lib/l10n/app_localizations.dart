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
  /// **'Product Navigator'**
  String get tabLearn;

  /// No description provided for @tabLibrary.
  ///
  /// In en, this message translates to:
  /// **'Marketing Hub'**
  String get tabLibrary;

  /// No description provided for @tabChallenges.
  ///
  /// In en, this message translates to:
  /// **'Eye-Know Challenges'**
  String get tabChallenges;

  /// No description provided for @tabFeedback.
  ///
  /// In en, this message translates to:
  /// **'Rep Voice'**
  String get tabFeedback;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get statusCompleted;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
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
  /// **'English'**
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
  /// **'Rank #{rank} of {total} Company-wide'**
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

  /// No description provided for @homeSectionQuickAccess.
  ///
  /// In en, this message translates to:
  /// **'Core Portfolio Modules'**
  String get homeSectionQuickAccess;

  /// No description provided for @homeSectionClinicalFocus.
  ///
  /// In en, this message translates to:
  /// **'Daily Clinical Focus & Performance'**
  String get homeSectionClinicalFocus;

  /// No description provided for @homeSectionFieldIntel.
  ///
  /// In en, this message translates to:
  /// **'Field Intelligence & Updates'**
  String get homeSectionFieldIntel;

  /// No description provided for @moduleProductNavigator.
  ///
  /// In en, this message translates to:
  /// **'Product Navigator'**
  String get moduleProductNavigator;

  /// No description provided for @moduleProductNavigatorSub.
  ///
  /// In en, this message translates to:
  /// **'Portfolio Science & Dosing'**
  String get moduleProductNavigatorSub;

  /// No description provided for @moduleMarketingHub.
  ///
  /// In en, this message translates to:
  /// **'Marketing Hub'**
  String get moduleMarketingHub;

  /// No description provided for @moduleMarketingHubSub.
  ///
  /// In en, this message translates to:
  /// **'Visual Aids & E-Detailing'**
  String get moduleMarketingHubSub;

  /// No description provided for @moduleEyeKnowChallenges.
  ///
  /// In en, this message translates to:
  /// **'Eye-Know Challenges'**
  String get moduleEyeKnowChallenges;

  /// No description provided for @moduleEyeKnowChallengesSub.
  ///
  /// In en, this message translates to:
  /// **'Quizzes & Company Rank'**
  String get moduleEyeKnowChallengesSub;

  /// No description provided for @moduleRepVoice.
  ///
  /// In en, this message translates to:
  /// **'Rep Voice'**
  String get moduleRepVoice;

  /// No description provided for @moduleRepVoiceSub.
  ///
  /// In en, this message translates to:
  /// **'Field Insights & Objections'**
  String get moduleRepVoiceSub;

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
  /// **'{points} Marks'**
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
  /// **'Challenge Marks'**
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
  /// **'Marketing Hub'**
  String get libraryTitle;

  /// No description provided for @materialsUpdatedQuarterly.
  ///
  /// In en, this message translates to:
  /// **'Materials are updated quarterly.'**
  String get materialsUpdatedQuarterly;

  /// No description provided for @productRohtoDryAid.
  ///
  /// In en, this message translates to:
  /// **'Rohto Dry Aid'**
  String get productRohtoDryAid;

  /// No description provided for @productRohtoCoolAqua.
  ///
  /// In en, this message translates to:
  /// **'Rohto Cool & Aqua'**
  String get productRohtoCoolAqua;

  /// No description provided for @productRohtoCool.
  ///
  /// In en, this message translates to:
  /// **'Rohto Cool'**
  String get productRohtoCool;

  /// No description provided for @productRohtoAqua.
  ///
  /// In en, this message translates to:
  /// **'Rohto Aqua'**
  String get productRohtoAqua;

  /// No description provided for @sectionBrochures.
  ///
  /// In en, this message translates to:
  /// **'Brochures'**
  String get sectionBrochures;

  /// No description provided for @sectionVisualAids.
  ///
  /// In en, this message translates to:
  /// **'Visual Aids'**
  String get sectionVisualAids;

  /// No description provided for @sectionEdetail.
  ///
  /// In en, this message translates to:
  /// **'E-detailed Slides'**
  String get sectionEdetail;

  /// No description provided for @sectionOtherMaterials.
  ///
  /// In en, this message translates to:
  /// **'Other Materials'**
  String get sectionOtherMaterials;

  /// No description provided for @statusComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get statusComingSoon;

  /// No description provided for @statusToDevelopLater.
  ///
  /// In en, this message translates to:
  /// **'To be developed later'**
  String get statusToDevelopLater;

  /// No description provided for @visualAidsComingSoonDesc.
  ///
  /// In en, this message translates to:
  /// **'Visual aids will be developed later.'**
  String get visualAidsComingSoonDesc;

  /// No description provided for @brochuresComingSoonDesc.
  ///
  /// In en, this message translates to:
  /// **'No material available yet.'**
  String get brochuresComingSoonDesc;

  /// No description provided for @edetailComingSoonDesc.
  ///
  /// In en, this message translates to:
  /// **'No material available yet.'**
  String get edetailComingSoonDesc;

  /// No description provided for @noMaterialAvailableYet.
  ///
  /// In en, this message translates to:
  /// **'No material available yet.'**
  String get noMaterialAvailableYet;

  /// No description provided for @rohtoAquaNoMaterials.
  ///
  /// In en, this message translates to:
  /// **'No materials available yet for Rohto Aqua.'**
  String get rohtoAquaNoMaterials;

  /// No description provided for @materialCountOne.
  ///
  /// In en, this message translates to:
  /// **'1 material'**
  String get materialCountOne;

  /// No description provided for @materialCountOther.
  ///
  /// In en, this message translates to:
  /// **'{count} materials'**
  String materialCountOther(int count);

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

  /// No description provided for @actionOpenOnline.
  ///
  /// In en, this message translates to:
  /// **'Open Online'**
  String get actionOpenOnline;

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
  /// **'Product Navigator'**
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

  /// No description provided for @tabFaqs.
  ///
  /// In en, this message translates to:
  /// **'FAQs & Studies'**
  String get tabFaqs;

  /// No description provided for @targetPatient.
  ///
  /// In en, this message translates to:
  /// **'Target Patient'**
  String get targetPatient;

  /// No description provided for @faqsTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get faqsTitle;

  /// No description provided for @supportingStudiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Supporting Clinical Studies'**
  String get supportingStudiesTitle;

  /// No description provided for @packShotsTitle.
  ///
  /// In en, this message translates to:
  /// **'Pack Shots'**
  String get packShotsTitle;

  /// No description provided for @noFaqsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No FAQs available for this product yet.'**
  String get noFaqsAvailable;

  /// No description provided for @openStudy.
  ///
  /// In en, this message translates to:
  /// **'Open Study'**
  String get openStudy;

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

  /// No description provided for @productOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Product Overview'**
  String get productOverviewTitle;

  /// No description provided for @keyPositioningTitle.
  ///
  /// In en, this message translates to:
  /// **'Key Positioning'**
  String get keyPositioningTitle;

  /// No description provided for @keyMessagingTitle.
  ///
  /// In en, this message translates to:
  /// **'Key Messaging'**
  String get keyMessagingTitle;

  /// No description provided for @packShotTitle.
  ///
  /// In en, this message translates to:
  /// **'Pack Shot'**
  String get packShotTitle;

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
  /// **'Eye-Know Challenges'**
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

  /// No description provided for @quizSingleAttemptNote.
  ///
  /// In en, this message translates to:
  /// **'Challenge marks are awarded once, on your single attempt. Retakes are not permitted.'**
  String get quizSingleAttemptNote;

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

  /// No description provided for @feedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Rep Voice'**
  String get feedbackTitle;

  /// No description provided for @feedbackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share real clinic insights directly with medical affairs'**
  String get feedbackSubtitle;

  /// No description provided for @typeDoctorObjection.
  ///
  /// In en, this message translates to:
  /// **'Doctor Objection'**
  String get typeDoctorObjection;

  /// No description provided for @descDoctorObjection.
  ///
  /// In en, this message translates to:
  /// **'Real questions, skepticism, or pushback heard in clinic visits.'**
  String get descDoctorObjection;

  /// No description provided for @typeCompetitorClaim.
  ///
  /// In en, this message translates to:
  /// **'Competitor Claim'**
  String get typeCompetitorClaim;

  /// No description provided for @descCompetitorClaim.
  ///
  /// In en, this message translates to:
  /// **'Aggressive promotion or unverified clinical claims heard in territory.'**
  String get descCompetitorClaim;

  /// No description provided for @typeFieldFeedback.
  ///
  /// In en, this message translates to:
  /// **'Field Feedback'**
  String get typeFieldFeedback;

  /// No description provided for @descFieldFeedback.
  ///
  /// In en, this message translates to:
  /// **'Material requests, sample shortages, or commercial campaign ideas.'**
  String get descFieldFeedback;

  /// No description provided for @mySubmissions.
  ///
  /// In en, this message translates to:
  /// **'My Submissions'**
  String get mySubmissions;

  /// No description provided for @emptySubmissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'No Feedback Submitted Yet'**
  String get emptySubmissionsTitle;

  /// No description provided for @emptySubmissionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Submissions shape upcoming detailing materials and clinical rebuttal decks.'**
  String get emptySubmissionsDesc;

  /// No description provided for @btnSendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get btnSendFeedback;

  /// No description provided for @draftRestored.
  ///
  /// In en, this message translates to:
  /// **'Draft restored'**
  String get draftRestored;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @feedbackSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Sent. Your marketing team will see this.'**
  String get feedbackSentTitle;

  /// No description provided for @feedbackQueuedTitle.
  ///
  /// In en, this message translates to:
  /// **'Will send when you\'re back online'**
  String get feedbackQueuedTitle;

  /// No description provided for @btnSendAnother.
  ///
  /// In en, this message translates to:
  /// **'Send Another Feedback'**
  String get btnSendAnother;

  /// No description provided for @btnBackHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Feedback'**
  String get btnBackHome;

  /// No description provided for @statusSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get statusSent;

  /// No description provided for @statusSeen.
  ///
  /// In en, this message translates to:
  /// **'Seen by Marketing'**
  String get statusSeen;

  /// No description provided for @statusAnswered.
  ///
  /// In en, this message translates to:
  /// **'Answered'**
  String get statusAnswered;

  /// No description provided for @marketingReply.
  ///
  /// In en, this message translates to:
  /// **'Marketing & Medical Reply'**
  String get marketingReply;

  /// No description provided for @noReplyYet.
  ///
  /// In en, this message translates to:
  /// **'Marketing has received your submission and is reviewing it.'**
  String get noReplyYet;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile & Settings'**
  String get profileTitle;

  /// No description provided for @repDetails.
  ///
  /// In en, this message translates to:
  /// **'Representative Details'**
  String get repDetails;

  /// No description provided for @territoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Territory'**
  String get territoryLabel;

  /// No description provided for @employeeIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Employee ID'**
  String get employeeIdLabel;

  /// No description provided for @pointsAndBadges.
  ///
  /// In en, this message translates to:
  /// **'Challenge Marks & Achievements'**
  String get pointsAndBadges;

  /// No description provided for @streakDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'{days} Days Streak'**
  String streakDaysLabel(int days);

  /// No description provided for @settingsGeneral.
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get settingsGeneral;

  /// No description provided for @languagePreference.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languagePreference;

  /// No description provided for @themePreference.
  ///
  /// In en, this message translates to:
  /// **'App Theme'**
  String get themePreference;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get themeDark;

  /// No description provided for @notificationPreferences.
  ///
  /// In en, this message translates to:
  /// **'Notification Preferences'**
  String get notificationPreferences;

  /// No description provided for @prefNewMaterials.
  ///
  /// In en, this message translates to:
  /// **'New Marketing Materials'**
  String get prefNewMaterials;

  /// No description provided for @prefChallenges.
  ///
  /// In en, this message translates to:
  /// **'Monthly Challenges'**
  String get prefChallenges;

  /// No description provided for @prefFeedbackReplies.
  ///
  /// In en, this message translates to:
  /// **'Marketing Responses'**
  String get prefFeedbackReplies;

  /// No description provided for @prefQuizReminders.
  ///
  /// In en, this message translates to:
  /// **'Quiz Deadlines'**
  String get prefQuizReminders;

  /// No description provided for @storageAndDownloads.
  ///
  /// In en, this message translates to:
  /// **'Storage & Downloads'**
  String get storageAndDownloads;

  /// No description provided for @offlineStorageUsed.
  ///
  /// In en, this message translates to:
  /// **'{size} Cached Offline'**
  String offlineStorageUsed(String size);

  /// No description provided for @btnClearDownloads.
  ///
  /// In en, this message translates to:
  /// **'Clear Cached Downloads'**
  String get btnClearDownloads;

  /// No description provided for @clearDownloadsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove all offline downloaded materials? You can re-download them anytime.'**
  String get clearDownloadsConfirm;

  /// No description provided for @downloadsClearedToast.
  ///
  /// In en, this message translates to:
  /// **'Offline downloads cleared'**
  String get downloadsClearedToast;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Company Credentials'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordDesc.
  ///
  /// In en, this message translates to:
  /// **'Your employee account credentials are authenticated and managed by corporate IT & Commercial Operations. To change or reset your password, contact marketing support.'**
  String get changePasswordDesc;

  /// No description provided for @contactMarketingTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Marketing Support'**
  String get contactMarketingTitle;

  /// No description provided for @contactMarketingEmail.
  ///
  /// In en, this message translates to:
  /// **'marketing@rxedgepharma.com'**
  String get contactMarketingEmail;

  /// No description provided for @contactMarketingPhone.
  ///
  /// In en, this message translates to:
  /// **'+20 2 2795 4000'**
  String get contactMarketingPhone;

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get logoutTitle;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out? You will need your employee credentials to sign back in.'**
  String get logoutConfirm;

  /// No description provided for @appVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'RxEdge v1.0.0 (Build 24)'**
  String get appVersionLabel;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @btnMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get btnMarkAllRead;

  /// No description provided for @emptyNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'All Caught Up'**
  String get emptyNotificationsTitle;

  /// No description provided for @emptyNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'You have reviewed all clinical updates, quiz deadlines, and marketing messages.'**
  String get emptyNotificationsDesc;

  /// No description provided for @globalSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search Everything'**
  String get globalSearchTitle;

  /// No description provided for @globalSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search lessons, library materials, doctor objections...'**
  String get globalSearchPlaceholder;

  /// No description provided for @recentSearchesTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get recentSearchesTitle;

  /// No description provided for @btnClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get btnClearAll;

  /// No description provided for @groupLessons.
  ///
  /// In en, this message translates to:
  /// **'Clinical Lessons & Monographs'**
  String get groupLessons;

  /// No description provided for @groupLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library Files & Visual Aids'**
  String get groupLibrary;

  /// No description provided for @groupObjections.
  ///
  /// In en, this message translates to:
  /// **'Doctor Objections & Talking Points'**
  String get groupObjections;

  /// No description provided for @searchNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String searchNoResultsTitle(String query);

  /// No description provided for @searchNoResultsDesc.
  ///
  /// In en, this message translates to:
  /// **'Try fewer words, check product spelling, or search by therapeutic area (e.g. Rohto Dry Aid, Rohto Cool).'**
  String get searchNoResultsDesc;

  /// No description provided for @offlineBannerConnected.
  ///
  /// In en, this message translates to:
  /// **'Back online — synced with marketing'**
  String get offlineBannerConnected;

  /// No description provided for @coachMarkTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to RxEdge'**
  String get coachMarkTitle;

  /// No description provided for @coachMarkSlide1Title.
  ///
  /// In en, this message translates to:
  /// **'Instant Detailing Review'**
  String get coachMarkSlide1Title;

  /// No description provided for @coachMarkSlide1Desc.
  ///
  /// In en, this message translates to:
  /// **'Review approved clinical monographs, dosing schedules, and talking points in 30 seconds before your visit.'**
  String get coachMarkSlide1Desc;

  /// No description provided for @coachMarkSlide2Title.
  ///
  /// In en, this message translates to:
  /// **'Reliable Offline Library'**
  String get coachMarkSlide2Title;

  /// No description provided for @coachMarkSlide2Desc.
  ///
  /// In en, this message translates to:
  /// **'Download brochures and e-detail slides to present seamlessly in hospital clinics with zero mobile signal.'**
  String get coachMarkSlide2Desc;

  /// No description provided for @coachMarkSlide3Title.
  ///
  /// In en, this message translates to:
  /// **'Direct Voice to Marketing'**
  String get coachMarkSlide3Title;

  /// No description provided for @coachMarkSlide3Desc.
  ///
  /// In en, this message translates to:
  /// **'Log physician pushback and competitor claims from the field directly to medical affairs directors.'**
  String get coachMarkSlide3Desc;

  /// No description provided for @btnGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got It'**
  String get btnGotIt;

  /// No description provided for @btnSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get btnSkip;

  /// No description provided for @btnClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get btnClose;

  /// No description provided for @btnClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get btnClear;

  /// No description provided for @supportAndSecurity.
  ///
  /// In en, this message translates to:
  /// **'Support & Security'**
  String get supportAndSecurity;

  /// No description provided for @actionSyncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get actionSyncNow;

  /// No description provided for @pendingSyncNotice.
  ///
  /// In en, this message translates to:
  /// **'{count} queued for sync'**
  String pendingSyncNotice(int count);

  /// No description provided for @defaultRepName.
  ///
  /// In en, this message translates to:
  /// **'Field Representative'**
  String get defaultRepName;

  /// No description provided for @dailyDetailingItinerary.
  ///
  /// In en, this message translates to:
  /// **'Daily Detailing Itinerary'**
  String get dailyDetailingItinerary;

  /// No description provided for @moduleProgressCount.
  ///
  /// In en, this message translates to:
  /// **'Module {completed} of {total}'**
  String moduleProgressCount(int completed, int total);

  /// No description provided for @recommendedDetailingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Master the key clinical trials and first-line detailing messaging.'**
  String get recommendedDetailingSubtitle;

  /// No description provided for @clinicalDetailingGuidance.
  ///
  /// In en, this message translates to:
  /// **'Clinical Detailing Guidance'**
  String get clinicalDetailingGuidance;

  /// No description provided for @recommendedClinicalCounter.
  ///
  /// In en, this message translates to:
  /// **'Recommended Clinical Counter'**
  String get recommendedClinicalCounter;

  /// No description provided for @profileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTooltip;

  /// No description provided for @notificationsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTooltip;

  /// No description provided for @noLearningModulesTitle.
  ///
  /// In en, this message translates to:
  /// **'No Learning Modules'**
  String get noLearningModulesTitle;

  /// No description provided for @noLearningModulesDesc.
  ///
  /// In en, this message translates to:
  /// **'Clinical detailing modules will appear here once assigned by your medical director.'**
  String get noLearningModulesDesc;

  /// No description provided for @bookmarksLabel.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get bookmarksLabel;

  /// No description provided for @lessonModulesLabel.
  ///
  /// In en, this message translates to:
  /// **'Lesson Modules'**
  String get lessonModulesLabel;

  /// No description provided for @lessonsTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get lessonsTabLabel;

  /// No description provided for @noCompetitorsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No competitor comparisons available for this product.'**
  String get noCompetitorsAvailable;

  /// No description provided for @clinicalRecallQuizTitle.
  ///
  /// In en, this message translates to:
  /// **'Clinical Recall Quiz'**
  String get clinicalRecallQuizTitle;

  /// No description provided for @lessonQuizReinforceDesc.
  ///
  /// In en, this message translates to:
  /// **'Reinforce your detailing confidence with {count} quick clinical recall questions.'**
  String lessonQuizReinforceDesc(int count);

  /// No description provided for @lessonQuizDialogBody.
  ///
  /// In en, this message translates to:
  /// **'This quiz includes {count} questions testing key study endpoints and competitor differentiation.'**
  String lessonQuizDialogBody(int count);

  /// No description provided for @btnStartQuizNow.
  ///
  /// In en, this message translates to:
  /// **'Start Quiz Now'**
  String get btnStartQuizNow;

  /// No description provided for @btnReviewLater.
  ///
  /// In en, this message translates to:
  /// **'Review Later'**
  String get btnReviewLater;

  /// No description provided for @offlineStatusBadge.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offlineStatusBadge;

  /// No description provided for @onlineOnlyStatusBadge.
  ///
  /// In en, this message translates to:
  /// **'Online only'**
  String get onlineOnlyStatusBadge;

  /// No description provided for @slidesCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} slides'**
  String slidesCountLabel(int count);

  /// No description provided for @pagesCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 page} other{{count} pages}}'**
  String pagesCountLabel(int count);

  /// No description provided for @regulatoryMonographHeader.
  ///
  /// In en, this message translates to:
  /// **'REGULATORY CLINICAL MONOGRAPH'**
  String get regulatoryMonographHeader;

  /// No description provided for @sectionNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'SECTION {number}'**
  String sectionNumberLabel(int number);

  /// No description provided for @therapeuticClassLabel.
  ///
  /// In en, this message translates to:
  /// **'Therapeutic Class: {productName}'**
  String therapeuticClassLabel(String productName);

  /// No description provided for @clinicalVisualAidBadge.
  ///
  /// In en, this message translates to:
  /// **'CLINICAL TRIAL VISUAL AID'**
  String get clinicalVisualAidBadge;

  /// No description provided for @documentIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Document ID: {id}'**
  String documentIdLabel(String id);

  /// No description provided for @confidentialDetailingFooter.
  ///
  /// In en, this message translates to:
  /// **'Confidential Medical Detailing'**
  String get confidentialDetailingFooter;

  /// No description provided for @activeSprintBadge.
  ///
  /// In en, this message translates to:
  /// **'Active Sprint'**
  String get activeSprintBadge;

  /// No description provided for @timeLeftCountdown.
  ///
  /// In en, this message translates to:
  /// **'{days}d {hours}h left'**
  String timeLeftCountdown(int days, int hours);

  /// No description provided for @leaderboardUpdateCaption.
  ///
  /// In en, this message translates to:
  /// **'Updated hourly across company medical reps'**
  String get leaderboardUpdateCaption;

  /// No description provided for @youLabel.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get youLabel;

  /// No description provided for @rankOfTotalDistrict.
  ///
  /// In en, this message translates to:
  /// **'Rank #{rank} of {total} Company-wide'**
  String rankOfTotalDistrict(int rank, int total);

  /// No description provided for @rankOfTotalSimple.
  ///
  /// In en, this message translates to:
  /// **'Rank #{rank} of {total}'**
  String rankOfTotalSimple(int rank, int total);

  /// No description provided for @noQuizzesTitle.
  ///
  /// In en, this message translates to:
  /// **'No Quizzes Available'**
  String get noQuizzesTitle;

  /// No description provided for @noQuizzesDesc.
  ///
  /// In en, this message translates to:
  /// **'New clinical quizzes will appear here with each detailing cycle.'**
  String get noQuizzesDesc;

  /// No description provided for @questionsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} questions'**
  String questionsCountLabel(int count);

  /// No description provided for @minutesCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutesCountLabel(int minutes);

  /// No description provided for @scoreOutOfLabel.
  ///
  /// In en, this message translates to:
  /// **'Score: {score}/{total}'**
  String scoreOutOfLabel(int score, int total);

  /// No description provided for @pointsPlusValue.
  ///
  /// In en, this message translates to:
  /// **'+{points} Marks'**
  String pointsPlusValue(int points);

  /// No description provided for @correctRecallLabel.
  ///
  /// In en, this message translates to:
  /// **'Correct Recall'**
  String get correctRecallLabel;

  /// No description provided for @clinicalRationaleLabel.
  ///
  /// In en, this message translates to:
  /// **'Clinical Rationale'**
  String get clinicalRationaleLabel;

  /// No description provided for @scoreCorrectOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{score} of {total} Questions Correct'**
  String scoreCorrectOfTotal(int score, int total);

  /// No description provided for @pointsEarnedLabel.
  ///
  /// In en, this message translates to:
  /// **'Marks Earned'**
  String get pointsEarnedLabel;

  /// No description provided for @timeElapsedLabel.
  ///
  /// In en, this message translates to:
  /// **'Time Elapsed'**
  String get timeElapsedLabel;

  /// No description provided for @btnHideMistakes.
  ///
  /// In en, this message translates to:
  /// **'Hide Mistakes'**
  String get btnHideMistakes;

  /// No description provided for @flawlessAnswersMsg.
  ///
  /// In en, this message translates to:
  /// **'Flawless! Zero incorrect answers to review.'**
  String get flawlessAnswersMsg;

  /// No description provided for @incorrectBreakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Incorrect Answers Breakdown'**
  String get incorrectBreakdownTitle;

  /// No description provided for @questionsBreakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Questions Breakdown'**
  String get questionsBreakdownTitle;

  /// No description provided for @filterAllCount.
  ///
  /// In en, this message translates to:
  /// **'All ({count})'**
  String filterAllCount(int count);

  /// No description provided for @filterIncorrectCount.
  ///
  /// In en, this message translates to:
  /// **'Incorrect only ({count})'**
  String filterIncorrectCount(int count);

  /// No description provided for @statusCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get statusCorrect;

  /// No description provided for @statusIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get statusIncorrect;

  /// No description provided for @notAnsweredLabel.
  ///
  /// In en, this message translates to:
  /// **'Not answered'**
  String get notAnsweredLabel;

  /// No description provided for @explanationHeader.
  ///
  /// In en, this message translates to:
  /// **'Clinical Explanation'**
  String get explanationHeader;

  /// No description provided for @btnShowAllQuestions.
  ///
  /// In en, this message translates to:
  /// **'Show All Questions'**
  String get btnShowAllQuestions;

  /// No description provided for @questionNumber.
  ///
  /// In en, this message translates to:
  /// **'Question {index}'**
  String questionNumber(int index);

  /// No description provided for @yourAnswerPrefix.
  ///
  /// In en, this message translates to:
  /// **'Your answer: {answer}'**
  String yourAnswerPrefix(String answer);

  /// No description provided for @quizClosesInDays.
  ///
  /// In en, this message translates to:
  /// **'Closes in {days} days'**
  String quizClosesInDays(int days);

  /// No description provided for @quizClosesToday.
  ///
  /// In en, this message translates to:
  /// **'Closes today'**
  String get quizClosesToday;

  /// No description provided for @quizOpensOn.
  ///
  /// In en, this message translates to:
  /// **'Opens on {date}'**
  String quizOpensOn(String date);

  /// No description provided for @quizClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get quizClosed;

  /// No description provided for @quizWindowClosedError.
  ///
  /// In en, this message translates to:
  /// **'This quiz is closed as the completion window has ended.'**
  String get quizWindowClosedError;

  /// No description provided for @quizNotStartedError.
  ///
  /// In en, this message translates to:
  /// **'This quiz has not started yet. Please check back on the start date.'**
  String get quizNotStartedError;

  /// No description provided for @quizComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Quiz coming soon'**
  String get quizComingSoon;

  /// No description provided for @correctAnswerPrefix.
  ///
  /// In en, this message translates to:
  /// **'Correct answer: {answer}'**
  String correctAnswerPrefix(String answer);

  /// No description provided for @recommendedClinicalResponseLabel.
  ///
  /// In en, this message translates to:
  /// **'Recommended Clinical Response'**
  String get recommendedClinicalResponseLabel;

  /// No description provided for @keyDetailingAnchorsLabel.
  ///
  /// In en, this message translates to:
  /// **'Key Detailing Anchors'**
  String get keyDetailingAnchorsLabel;

  /// No description provided for @unableLoadFeedback.
  ///
  /// In en, this message translates to:
  /// **'Unable to load feedback'**
  String get unableLoadFeedback;

  /// No description provided for @pendingOfflineWarning.
  ///
  /// In en, this message translates to:
  /// **'Some submissions are pending offline and will sync when connected.'**
  String get pendingOfflineWarning;

  /// No description provided for @feedbackDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Feedback Details'**
  String get feedbackDetailsTitle;

  /// No description provided for @submissionNotFound.
  ///
  /// In en, this message translates to:
  /// **'Submission not found'**
  String get submissionNotFound;

  /// No description provided for @fieldSubmissionHeader.
  ///
  /// In en, this message translates to:
  /// **'Field Submission'**
  String get fieldSubmissionHeader;

  /// No description provided for @labelProduct.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get labelProduct;

  /// No description provided for @labelDoctorObjection.
  ///
  /// In en, this message translates to:
  /// **'Doctor Objection'**
  String get labelDoctorObjection;

  /// No description provided for @labelDoctorSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Doctor Specialty'**
  String get labelDoctorSpecialty;

  /// No description provided for @labelHowResponded.
  ///
  /// In en, this message translates to:
  /// **'How I Responded'**
  String get labelHowResponded;

  /// No description provided for @labelCompetitor.
  ///
  /// In en, this message translates to:
  /// **'Competitor'**
  String get labelCompetitor;

  /// No description provided for @labelClaimHeard.
  ///
  /// In en, this message translates to:
  /// **'Claim Heard'**
  String get labelClaimHeard;

  /// No description provided for @labelWhereHeard.
  ///
  /// In en, this message translates to:
  /// **'Where Heard'**
  String get labelWhereHeard;

  /// No description provided for @labelTopic.
  ///
  /// In en, this message translates to:
  /// **'Topic'**
  String get labelTopic;

  /// No description provided for @labelDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get labelDetails;

  /// No description provided for @optionalFieldSuffix.
  ///
  /// In en, this message translates to:
  /// **'{label} (optional)'**
  String optionalFieldSuffix(String label);

  /// No description provided for @hintDoctorObjection.
  ///
  /// In en, this message translates to:
  /// **'Please describe the doctor\'s objection...'**
  String get hintDoctorObjection;

  /// No description provided for @hintHowResponded.
  ///
  /// In en, this message translates to:
  /// **'What clinical talking point or trial data did you share?'**
  String get hintHowResponded;

  /// No description provided for @labelCompetitorProduct.
  ///
  /// In en, this message translates to:
  /// **'Competitor Name & Product'**
  String get labelCompetitorProduct;

  /// No description provided for @hintCompetitorClaim.
  ///
  /// In en, this message translates to:
  /// **'Please describe the competitor activity...'**
  String get hintCompetitorClaim;

  /// No description provided for @labelTopicCampaign.
  ///
  /// In en, this message translates to:
  /// **'Topic / Campaign'**
  String get labelTopicCampaign;

  /// No description provided for @hintDetails.
  ///
  /// In en, this message translates to:
  /// **'Explain the situation or request clearly for the marketing team...'**
  String get hintDetails;

  /// No description provided for @attachPhotoOptional.
  ///
  /// In en, this message translates to:
  /// **'Attach supporting photo (optional)'**
  String get attachPhotoOptional;

  /// No description provided for @photoAttachedLabel.
  ///
  /// In en, this message translates to:
  /// **'Supporting photo attached'**
  String get photoAttachedLabel;

  /// No description provided for @attachVoiceOptional.
  ///
  /// In en, this message translates to:
  /// **'Attach quick voice note (optional)'**
  String get attachVoiceOptional;

  /// No description provided for @voiceAttachedLabel.
  ///
  /// In en, this message translates to:
  /// **'Voice note attached'**
  String get voiceAttachedLabel;

  /// No description provided for @medicalAffairsDefault.
  ///
  /// In en, this message translates to:
  /// **'Medical Affairs'**
  String get medicalAffairsDefault;

  /// No description provided for @offlineQueueInfo.
  ///
  /// In en, this message translates to:
  /// **'Saved offline. It will be sent automatically as soon as an internet connection is established.'**
  String get offlineQueueInfo;

  /// No description provided for @submissionFailedFallback.
  ///
  /// In en, this message translates to:
  /// **'Submission failed'**
  String get submissionFailedFallback;

  /// No description provided for @feedbackSentExtraNote.
  ///
  /// In en, this message translates to:
  /// **'Commercial marketing and medical affairs review field intelligence reports daily to update talking points.'**
  String get feedbackSentExtraNote;

  /// No description provided for @feedbackQueuedExtraNote.
  ///
  /// In en, this message translates to:
  /// **'Stored securely on your device. We will automatically submit it to medical affairs as soon as connection is restored.'**
  String get feedbackQueuedExtraNote;

  /// No description provided for @selectProductOptional.
  ///
  /// In en, this message translates to:
  /// **'Related Product (optional)'**
  String get selectProductOptional;

  /// No description provided for @noProductSelected.
  ///
  /// In en, this message translates to:
  /// **'General / No specific product'**
  String get noProductSelected;

  /// No description provided for @unableLoadNotifications.
  ///
  /// In en, this message translates to:
  /// **'Unable to load notifications'**
  String get unableLoadNotifications;

  /// No description provided for @unableLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Unable to load profile'**
  String get unableLoadProfile;

  /// No description provided for @storageStatusDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get storageStatusDownloaded;

  /// No description provided for @storageStatusEmpty.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get storageStatusEmpty;

  /// No description provided for @offlineStorageDesc.
  ///
  /// In en, this message translates to:
  /// **'Downloaded brochures, e-detail decks, and monographs are available when offline.'**
  String get offlineStorageDesc;

  /// No description provided for @searchFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Search failed'**
  String get searchFailedTitle;

  /// No description provided for @suggestedTopicsLabel.
  ///
  /// In en, this message translates to:
  /// **'Suggested Topics'**
  String get suggestedTopicsLabel;

  /// No description provided for @suggestedTopicDosing.
  ///
  /// In en, this message translates to:
  /// **'Tearshield'**
  String get suggestedTopicDosing;

  /// No description provided for @suggestedTopicHypotension.
  ///
  /// In en, this message translates to:
  /// **'Contact Lenses'**
  String get suggestedTopicHypotension;

  /// No description provided for @suggestedTopicGits.
  ///
  /// In en, this message translates to:
  /// **'MGD Relief'**
  String get suggestedTopicGits;

  /// No description provided for @systemDiagnosticsTitle.
  ///
  /// In en, this message translates to:
  /// **'System Diagnostics'**
  String get systemDiagnosticsTitle;

  /// No description provided for @appMetadataTitle.
  ///
  /// In en, this message translates to:
  /// **'Application Metadata'**
  String get appMetadataTitle;

  /// No description provided for @appMetadataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Active runtime environment and build specification'**
  String get appMetadataSubtitle;

  /// No description provided for @unableLoadDiagnostics.
  ///
  /// In en, this message translates to:
  /// **'Unable to Load Diagnostics'**
  String get unableLoadDiagnostics;

  /// No description provided for @retryConnection.
  ///
  /// In en, this message translates to:
  /// **'Retry Connection'**
  String get retryConnection;

  /// No description provided for @minSupportedVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Min Supported Version'**
  String get minSupportedVersionLabel;

  /// No description provided for @maintenanceStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Maintenance Status'**
  String get maintenanceStatusLabel;

  /// No description provided for @maintenanceActive.
  ///
  /// In en, this message translates to:
  /// **'Active (Read Only)'**
  String get maintenanceActive;

  /// No description provided for @operationalStatus.
  ///
  /// In en, this message translates to:
  /// **'Operational'**
  String get operationalStatus;

  /// No description provided for @apiEndpointLabel.
  ///
  /// In en, this message translates to:
  /// **'API Endpoint'**
  String get apiEndpointLabel;

  /// No description provided for @configuredBaseUrl.
  ///
  /// In en, this message translates to:
  /// **'Configured Base URL'**
  String get configuredBaseUrl;

  /// No description provided for @serverTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Server Time'**
  String get serverTimeLabel;

  /// No description provided for @refreshSystemStatus.
  ///
  /// In en, this message translates to:
  /// **'Refresh System Status'**
  String get refreshSystemStatus;

  /// No description provided for @forgotHelpdeskTitle.
  ///
  /// In en, this message translates to:
  /// **'Commercial IT & Marketing Helpdesk'**
  String get forgotHelpdeskTitle;

  /// No description provided for @forgotSupportSentToast.
  ///
  /// In en, this message translates to:
  /// **'Support request sent to {email}'**
  String forgotSupportSentToast(String email);

  /// No description provided for @taglineFieldMedical.
  ///
  /// In en, this message translates to:
  /// **'Field Medical Intelligence'**
  String get taglineFieldMedical;

  /// No description provided for @pointTxQuizCompletion.
  ///
  /// In en, this message translates to:
  /// **'Quick Quiz Reward'**
  String get pointTxQuizCompletion;

  /// No description provided for @pointTxLessonCompletion.
  ///
  /// In en, this message translates to:
  /// **'Module Completion Reward'**
  String get pointTxLessonCompletion;

  /// No description provided for @pointTxChallengeReward.
  ///
  /// In en, this message translates to:
  /// **'Monthly Challenge Bonus'**
  String get pointTxChallengeReward;

  /// No description provided for @pointTxManualAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Administrative Adjustment'**
  String get pointTxManualAdjustment;

  /// No description provided for @helpfulVotesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} helpful votes'**
  String helpfulVotesCount(int count);

  /// No description provided for @peersContributedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} peers contributed field phrasing'**
  String peersContributedCount(int count);

  /// No description provided for @minAgoCount.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String minAgoCount(int count);

  /// No description provided for @hoursAgoCount.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String hoursAgoCount(int count);

  /// No description provided for @daysAgoCount.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String daysAgoCount(int count);

  /// No description provided for @topTenTerritoryBadge.
  ///
  /// In en, this message translates to:
  /// **'Top 10% in Territory'**
  String get topTenTerritoryBadge;

  /// No description provided for @productHintExamples.
  ///
  /// In en, this message translates to:
  /// **'e.g. Rohto Dry Aid, Rohto Cool'**
  String get productHintExamples;

  /// No description provided for @specialtyHintExamples.
  ///
  /// In en, this message translates to:
  /// **'e.g. Consultant Ophthalmologist, Cornea Specialist'**
  String get specialtyHintExamples;

  /// No description provided for @competitorHintExamples.
  ///
  /// In en, this message translates to:
  /// **'e.g. Generic Artificial Tears'**
  String get competitorHintExamples;

  /// No description provided for @whereHeardHintExamples.
  ///
  /// In en, this message translates to:
  /// **'e.g. Ophthalmology Society Conference, Clinic Visit'**
  String get whereHeardHintExamples;

  /// No description provided for @topicHintExamples.
  ///
  /// In en, this message translates to:
  /// **'e.g. Sample Availability, Laminated Visual Aid Request'**
  String get topicHintExamples;

  /// No description provided for @errNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network and try again.'**
  String get errNetwork;

  /// No description provided for @errUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Your session is unauthorized or expired. Please sign in again.'**
  String get errUnauthorized;

  /// No description provided for @errNotFound.
  ///
  /// In en, this message translates to:
  /// **'Requested content could not be found.'**
  String get errNotFound;

  /// No description provided for @errValidation.
  ///
  /// In en, this message translates to:
  /// **'Please check the highlighted fields and try again.'**
  String get errValidation;

  /// No description provided for @errCache.
  ///
  /// In en, this message translates to:
  /// **'Unable to read local offline cache.'**
  String get errCache;

  /// No description provided for @errServer.
  ///
  /// In en, this message translates to:
  /// **'The server encountered an error. Please try again shortly.'**
  String get errServer;

  /// No description provided for @errRateLimit.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please wait a moment and try again.'**
  String get errRateLimit;

  /// No description provided for @errUnknown.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get errUnknown;

  /// No description provided for @quizOfflineSubmitError.
  ///
  /// In en, this message translates to:
  /// **'Connect to the internet to submit your answers.'**
  String get quizOfflineSubmitError;

  /// No description provided for @failedSyncWarning.
  ///
  /// In en, this message translates to:
  /// **'Some offline submissions failed to sync.'**
  String get failedSyncWarning;

  /// No description provided for @actionDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get actionDiscard;

  /// No description provided for @syncRetryFailed.
  ///
  /// In en, this message translates to:
  /// **'Still unable to sync. Please check your connection or submission details.'**
  String get syncRetryFailed;

  /// No description provided for @minReadCount.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min read'**
  String minReadCount(int minutes);

  /// No description provided for @reviewQuizAnswers.
  ///
  /// In en, this message translates to:
  /// **'Review Quiz Answers'**
  String get reviewQuizAnswers;

  /// No description provided for @quizAlreadyAttemptedError.
  ///
  /// In en, this message translates to:
  /// **'You have already attempted this quiz. Retakes are not permitted per challenge policy.'**
  String get quizAlreadyAttemptedError;

  /// No description provided for @marksClaimedLabel.
  ///
  /// In en, this message translates to:
  /// **'Claimed'**
  String get marksClaimedLabel;

  /// No description provided for @quizMarksNoteWithReward.
  ///
  /// In en, this message translates to:
  /// **'Marks Note: Quiz challenge marks (+{points} Marks) are awarded once upon first pass. Additional attempts serve as clinical refresher and practice.'**
  String quizMarksNoteWithReward(int points);

  /// No description provided for @quizMarksNote.
  ///
  /// In en, this message translates to:
  /// **'Marks Note: Quiz challenge marks are awarded once upon first pass. Additional attempts serve as clinical refresher and practice.'**
  String get quizMarksNote;

  /// No description provided for @quizPassedLessonCompleted.
  ///
  /// In en, this message translates to:
  /// **'Quiz passed! The associated lesson has been automatically marked as complete.'**
  String get quizPassedLessonCompleted;

  /// No description provided for @durationMinutesSeconds.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m {seconds}s'**
  String durationMinutesSeconds(int minutes, int seconds);

  /// No description provided for @layoutAndSortOptions.
  ///
  /// In en, this message translates to:
  /// **'Layout & Sort Options'**
  String get layoutAndSortOptions;

  /// No description provided for @switchToListView.
  ///
  /// In en, this message translates to:
  /// **'Switch to List View'**
  String get switchToListView;

  /// No description provided for @switchToGridView.
  ///
  /// In en, this message translates to:
  /// **'Switch to Grid View'**
  String get switchToGridView;

  /// No description provided for @sortOrderLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort Order'**
  String get sortOrderLabel;

  /// No description provided for @sortNewestFirst.
  ///
  /// In en, this message translates to:
  /// **'Newest First'**
  String get sortNewestFirst;

  /// No description provided for @sortMostUsedLabel.
  ///
  /// In en, this message translates to:
  /// **'Most Used'**
  String get sortMostUsedLabel;

  /// No description provided for @sortAlphabeticalLabel.
  ///
  /// In en, this message translates to:
  /// **'Alphabetical (A-Z)'**
  String get sortAlphabeticalLabel;

  /// No description provided for @tooltipOnlineMode.
  ///
  /// In en, this message translates to:
  /// **'Online Mode'**
  String get tooltipOnlineMode;

  /// No description provided for @tooltipSimulateOfflineMode.
  ///
  /// In en, this message translates to:
  /// **'Simulate Offline Mode'**
  String get tooltipSimulateOfflineMode;

  /// No description provided for @filterOptionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Filter options'**
  String get filterOptionsTooltip;

  /// No description provided for @filterByProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter by Pharmaceutical Product'**
  String get filterByProductTitle;

  /// No description provided for @sortMaterialsByTitle.
  ///
  /// In en, this message translates to:
  /// **'Sort Materials By'**
  String get sortMaterialsByTitle;

  /// No description provided for @materialShareLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Approved sharing link copied to clipboard for: {title}'**
  String materialShareLinkCopied(String title);

  /// No description provided for @storeOfflineSize.
  ///
  /// In en, this message translates to:
  /// **'Store {size} on device for offline detailing'**
  String storeOfflineSize(String size);

  /// No description provided for @freesOfflineSize.
  ///
  /// In en, this message translates to:
  /// **'Frees {size} of local storage'**
  String freesOfflineSize(String size);

  /// No description provided for @takePhotoWithCamera.
  ///
  /// In en, this message translates to:
  /// **'Take Photo with Camera'**
  String get takePhotoWithCamera;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @photoSavedLocallyOffline.
  ///
  /// In en, this message translates to:
  /// **'Photo saved locally and will upload when back online.'**
  String get photoSavedLocallyOffline;

  /// No description provided for @failedToUploadImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload image. Please check connection.'**
  String get failedToUploadImage;

  /// No description provided for @voiceNoteSavedLocallyOffline.
  ///
  /// In en, this message translates to:
  /// **'Voice note saved locally and will upload when back online.'**
  String get voiceNoteSavedLocallyOffline;

  /// No description provided for @microphonePermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is required to record a voice note.'**
  String get microphonePermissionRequired;

  /// No description provided for @voiceRecordingMobileOnly.
  ///
  /// In en, this message translates to:
  /// **'Voice recording is available on mobile devices.'**
  String get voiceRecordingMobileOnly;

  /// No description provided for @unableToRecordAudio.
  ///
  /// In en, this message translates to:
  /// **'Unable to record audio on this device.'**
  String get unableToRecordAudio;

  /// No description provided for @uploadingVoiceNote.
  ///
  /// In en, this message translates to:
  /// **'Uploading voice note...'**
  String get uploadingVoiceNote;

  /// No description provided for @recordingTapToStop.
  ///
  /// In en, this message translates to:
  /// **'Recording... Tap to stop ({duration})'**
  String recordingTapToStop(String duration);

  /// No description provided for @unableToPlayVoiceNote.
  ///
  /// In en, this message translates to:
  /// **'Unable to play voice note right now.'**
  String get unableToPlayVoiceNote;

  /// No description provided for @playingVoiceNote.
  ///
  /// In en, this message translates to:
  /// **'Playing voice note...'**
  String get playingVoiceNote;

  /// No description provided for @defaultScopeCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get defaultScopeCompany;

  /// No description provided for @rankInScope.
  ///
  /// In en, this message translates to:
  /// **'Rank #{rank} of {total} in {scope}'**
  String rankInScope(int rank, int total, String scope);

  /// No description provided for @unrankedInScope.
  ///
  /// In en, this message translates to:
  /// **'Unranked in {scope}'**
  String unrankedInScope(String scope);

  /// No description provided for @sprintRankNumber.
  ///
  /// In en, this message translates to:
  /// **'Sprint Rank #{rank}'**
  String sprintRankNumber(int rank);

  /// No description provided for @unrankedLabel.
  ///
  /// In en, this message translates to:
  /// **'Unranked'**
  String get unrankedLabel;

  /// No description provided for @challengesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Compete in monthly sprints, test clinical recall, and climb the ranks'**
  String get challengesSubtitle;

  /// No description provided for @unableToLoadQuizReview.
  ///
  /// In en, this message translates to:
  /// **'Unable to load quiz review.'**
  String get unableToLoadQuizReview;

  /// No description provided for @repVoicePrivacyNoticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Data Notice'**
  String get repVoicePrivacyNoticeTitle;

  /// No description provided for @repVoicePrivacyNoticeBody.
  ///
  /// In en, this message translates to:
  /// **'Submissions and photos are stored securely, accessible only to you and authorized Supervisors or Marketing Admins, retained per company policy (365 days), and removable via Rep Voice history or deletion requests.'**
  String get repVoicePrivacyNoticeBody;

  /// No description provided for @quarterlyBadgesEmpty.
  ///
  /// In en, this message translates to:
  /// **'Quarterly badges will appear here'**
  String get quarterlyBadgesEmpty;
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
