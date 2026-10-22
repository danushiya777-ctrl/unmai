import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ta.dart';

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
    Locale('en'),
    Locale('hi'),
    Locale('ta'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Unmai'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Check before you share.'**
  String get appTagline;

  /// No description provided for @tabVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get tabVerify;

  /// No description provided for @tabHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get tabHistory;

  /// No description provided for @tabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// No description provided for @pasteBoxPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Paste suspicious message, claim, or link here...'**
  String get pasteBoxPlaceholder;

  /// No description provided for @pasteButton.
  ///
  /// In en, this message translates to:
  /// **'Paste from clipboard'**
  String get pasteButton;

  /// No description provided for @pickImage.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get pickImage;

  /// No description provided for @pickVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get pickVideo;

  /// No description provided for @removeAttachment.
  ///
  /// In en, this message translates to:
  /// **'Remove attachment'**
  String get removeAttachment;

  /// No description provided for @verifyButton.
  ///
  /// In en, this message translates to:
  /// **'Verify now'**
  String get verifyButton;

  /// No description provided for @progressReading.
  ///
  /// In en, this message translates to:
  /// **'Reading content'**
  String get progressReading;

  /// No description provided for @progressSearching.
  ///
  /// In en, this message translates to:
  /// **'Searching sources'**
  String get progressSearching;

  /// No description provided for @progressCheckingMedia.
  ///
  /// In en, this message translates to:
  /// **'Checking media'**
  String get progressCheckingMedia;

  /// No description provided for @progressResult.
  ///
  /// In en, this message translates to:
  /// **'Preparing result'**
  String get progressResult;

  /// No description provided for @emptyInputError.
  ///
  /// In en, this message translates to:
  /// **'Please enter text, a URL, or attach a photo or video.'**
  String get emptyInputError;

  /// No description provided for @invalidUrlError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid web URL.'**
  String get invalidUrlError;

  /// No description provided for @fileTooLargeError.
  ///
  /// In en, this message translates to:
  /// **'File exceeds 50MB limit.'**
  String get fileTooLargeError;

  /// No description provided for @unsupportedFileError.
  ///
  /// In en, this message translates to:
  /// **'Unsupported format. Please select JPG, PNG, WEBP, or MP4.'**
  String get unsupportedFileError;

  /// No description provided for @verdictTrue.
  ///
  /// In en, this message translates to:
  /// **'True'**
  String get verdictTrue;

  /// No description provided for @verdictFalse.
  ///
  /// In en, this message translates to:
  /// **'False'**
  String get verdictFalse;

  /// No description provided for @verdictMisleading.
  ///
  /// In en, this message translates to:
  /// **'Misleading'**
  String get verdictMisleading;

  /// No description provided for @verdictUnverified.
  ///
  /// In en, this message translates to:
  /// **'Can\'t verify'**
  String get verdictUnverified;

  /// No description provided for @correctnessTitle.
  ///
  /// In en, this message translates to:
  /// **'Correctness meter'**
  String get correctnessTitle;

  /// No description provided for @claimsSupported.
  ///
  /// In en, this message translates to:
  /// **'{supported} of {total} claims supported'**
  String claimsSupported(int supported, int total);

  /// No description provided for @evidenceStrengthStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong evidence'**
  String get evidenceStrengthStrong;

  /// No description provided for @evidenceStrengthMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium evidence'**
  String get evidenceStrengthMedium;

  /// No description provided for @evidenceStrengthWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak evidence'**
  String get evidenceStrengthWeak;

  /// No description provided for @notEnoughEvidence.
  ///
  /// In en, this message translates to:
  /// **'Not enough evidence for a reliable score.'**
  String get notEnoughEvidence;

  /// No description provided for @mediaAssessmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Media check'**
  String get mediaAssessmentTitle;

  /// No description provided for @mediaLikelyAi.
  ///
  /// In en, this message translates to:
  /// **'Likely AI'**
  String get mediaLikelyAi;

  /// No description provided for @mediaPossiblyAi.
  ///
  /// In en, this message translates to:
  /// **'Possibly AI'**
  String get mediaPossiblyAi;

  /// No description provided for @mediaInconclusive.
  ///
  /// In en, this message translates to:
  /// **'Inconclusive'**
  String get mediaInconclusive;

  /// No description provided for @mediaToolUsed.
  ///
  /// In en, this message translates to:
  /// **'Tool used: {tool}'**
  String mediaToolUsed(String tool);

  /// No description provided for @mediaLimitations.
  ///
  /// In en, this message translates to:
  /// **'Limitations: {limitations}'**
  String mediaLimitations(String limitations);

  /// No description provided for @confirmedByTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirmed by'**
  String get confirmedByTitle;

  /// No description provided for @whyFalseTitle.
  ///
  /// In en, this message translates to:
  /// **'Why this is false'**
  String get whyFalseTitle;

  /// No description provided for @claimsBreakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Claim-by-claim breakdown'**
  String get claimsBreakdownTitle;

  /// No description provided for @shareCorrectionCard.
  ///
  /// In en, this message translates to:
  /// **'Share correction card'**
  String get shareCorrectionCard;

  /// No description provided for @checkedWithUnmai.
  ///
  /// In en, this message translates to:
  /// **'Checked with Unmai'**
  String get checkedWithUnmai;

  /// No description provided for @demoDataBanner.
  ///
  /// In en, this message translates to:
  /// **'Demo data. Not a live finding.'**
  String get demoDataBanner;

  /// No description provided for @supportingEvidence.
  ///
  /// In en, this message translates to:
  /// **'Supporting evidence'**
  String get supportingEvidence;

  /// No description provided for @contradictingEvidence.
  ///
  /// In en, this message translates to:
  /// **'Contradicting evidence'**
  String get contradictingEvidence;

  /// No description provided for @missingContext.
  ///
  /// In en, this message translates to:
  /// **'Missing context'**
  String get missingContext;

  /// No description provided for @publishedOn.
  ///
  /// In en, this message translates to:
  /// **'Published: {date}'**
  String publishedOn(String date);

  /// No description provided for @openSourceLink.
  ///
  /// In en, this message translates to:
  /// **'Open source link'**
  String get openSourceLink;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search previous checks...'**
  String get searchPlaceholder;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @emptyHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'No checks yet'**
  String get emptyHistoryTitle;

  /// No description provided for @emptyHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Suspicious forwards you verify will be saved here on your device.'**
  String get emptyHistorySubtitle;

  /// No description provided for @deleteReportConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this report?'**
  String get deleteReportConfirm;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @savedToHistory.
  ///
  /// In en, this message translates to:
  /// **'Saved to history'**
  String get savedToHistory;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @howUnmaiDecidesTitle.
  ///
  /// In en, this message translates to:
  /// **'How Unmai decides'**
  String get howUnmaiDecidesTitle;

  /// No description provided for @howUnmaiDecidesContent.
  ///
  /// In en, this message translates to:
  /// **'Unmai compares claims against authoritative fact-check databases, official sources, and public records. If reliable evidence cannot be found, we clearly mark it as unverified rather than guessing.'**
  String get howUnmaiDecidesContent;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy note'**
  String get privacyTitle;

  /// No description provided for @privacyContent.
  ///
  /// In en, this message translates to:
  /// **'All your verification history is saved locally on your phone. When you verify a claim, only that text or media is sent securely to the server. We do not sell your data or track your identity.'**
  String get privacyContent;

  /// No description provided for @demoModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Demo mode'**
  String get demoModeTitle;

  /// No description provided for @demoModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use built-in realistic examples for practice'**
  String get demoModeSubtitle;

  /// No description provided for @appVersionTitle.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get appVersionTitle;

  /// No description provided for @versionNumber.
  ///
  /// In en, this message translates to:
  /// **'1.0.0 (Unmai)'**
  String get versionNumber;

  /// No description provided for @offlineError.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network and try again.'**
  String get offlineError;

  /// No description provided for @timeoutError.
  ///
  /// In en, this message translates to:
  /// **'The check took too long to complete. Please try again.'**
  String get timeoutError;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the verification service. Please try again shortly.'**
  String get serverError;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retryButton;
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
      <String>['en', 'hi', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
