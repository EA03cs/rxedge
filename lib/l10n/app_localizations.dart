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
