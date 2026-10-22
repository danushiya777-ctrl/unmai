// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appName => 'உண்மை';

  @override
  String get appTagline => 'பகிர்வதற்கு முன் சரிபார்க்கவும்.';

  @override
  String get tabVerify => 'சரிபார்';

  @override
  String get tabHistory => 'வரலாறு';

  @override
  String get tabSettings => 'அமைப்புகள்';

  @override
  String get pasteBoxPlaceholder =>
      'சந்தேகத்திற்குரிய செய்தி, கூற்று அல்லது இணைப்பை இங்கே ஒட்டவும்...';

  @override
  String get pasteButton => 'கிளிப்போர்டிலிருந்து ஒட்டு';

  @override
  String get pickImage => 'படம்';

  @override
  String get pickVideo => 'வீடியோ';

  @override
  String get removeAttachment => 'இணைப்பை நீக்கு';

  @override
  String get verifyButton => 'இப்போதே சரிபார்க்கவும்';

  @override
  String get progressReading => 'உள்ளடக்கத்தை படிக்கிறது';

  @override
  String get progressSearching => 'ஆதாரங்களை தேடுகிறது';

  @override
  String get progressCheckingMedia => 'படத்தை சரிபார்க்கிறது';

  @override
  String get progressResult => 'முடிவைத் தயாரிக்கிறது';

  @override
  String get emptyInputError =>
      'செய்தி, இணைப்பு அல்லது படம்/வீடியோவை உள்ளிடவும்.';

  @override
  String get invalidUrlError => 'சரியான இணையதள முகவரியை உள்ளிடவும்.';

  @override
  String get fileTooLargeError => 'கோப்பு 50MB அளவை விட பெரியதாக உள்ளது.';

  @override
  String get unsupportedFileError =>
      'ஆதரிக்கப்படாத வடிவம். JPG, PNG, WEBP அல்லது MP4 கோப்பைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get verdictTrue => 'உண்மை';

  @override
  String get verdictFalse => 'தவறு';

  @override
  String get verdictMisleading => 'தவறாக வழிநடத்துகிறது';

  @override
  String get verdictUnverified => 'சரிபார்க்க முடியவில்லை';

  @override
  String get correctnessTitle => 'துல்லிய மீட்டர்';

  @override
  String claimsSupported(int supported, int total) {
    return '$total இல் $supported கூற்றுகள் உண்மை';
  }

  @override
  String get evidenceStrengthStrong => 'வலுவான ஆதாரம்';

  @override
  String get evidenceStrengthMedium => 'மிதமான ஆதாரம்';

  @override
  String get evidenceStrengthWeak => 'பலவீனமான ஆதாரம்';

  @override
  String get notEnoughEvidence =>
      'நம்பகமான மதிப்பீட்டிற்கு போதுமான ஆதாரம் இல்லை.';

  @override
  String get mediaAssessmentTitle => 'ஊடக சோதனை';

  @override
  String get mediaLikelyAi => 'சாத்தியமான செயற்கை உருவாக்கம்';

  @override
  String get mediaPossiblyAi => 'செயற்கை உருவாக்கம் சாத்தியம்';

  @override
  String get mediaInconclusive => 'உறுதியாகக் கூற முடியவில்லை';

  @override
  String mediaToolUsed(String tool) {
    return 'பயன்படுத்தப்பட்ட கருவி: $tool';
  }

  @override
  String mediaLimitations(String limitations) {
    return 'வரம்புகள்: $limitations';
  }

  @override
  String get confirmedByTitle => 'உறுதிப்படுத்திய ஆதாரங்கள்';

  @override
  String get whyFalseTitle => 'இது ஏன் தவறானது';

  @override
  String get claimsBreakdownTitle => 'ஒவ்வொரு கூற்றின் பகுப்பாய்வு';

  @override
  String get shareCorrectionCard => 'திருத்த அட்டையைப் பகிரவும்';

  @override
  String get checkedWithUnmai => 'உண்மை (Unmai) மூலம் சரிபார்க்கப்பட்டது';

  @override
  String get demoDataBanner => 'மாதிரித் தகவல். நேரடி முடிவு அல்ல.';

  @override
  String get supportingEvidence => 'ஆதரிக்கும் தகவல்கள்';

  @override
  String get contradictingEvidence => 'மறுக்கும் தகவல்கள்';

  @override
  String get missingContext => 'விடுபட்ட சூழல்';

  @override
  String publishedOn(String date) {
    return 'வெளியிடப்பட்டது: $date';
  }

  @override
  String get openSourceLink => 'ஆதார இணைப்பைத் திறக்கவும்';

  @override
  String get historyTitle => 'சரிபார்ப்பு வரலாறு';

  @override
  String get searchPlaceholder => 'முந்தைய பதிவுகளைத் தேடுங்கள்...';

  @override
  String get filterAll => 'அனைத்தும்';

  @override
  String get emptyHistoryTitle => 'பதிவுகள் எதுவும் இல்லை';

  @override
  String get emptyHistorySubtitle =>
      'நீங்கள் சரிபார்க்கும் சந்தேகத்திற்குரிய செய்திகள் உங்கள் தொலைபேசியில் மட்டுமே சேமிக்கப்படும்.';

  @override
  String get deleteReportConfirm => 'இந்த அறிக்கையை நீக்கவா?';

  @override
  String get deleteButton => 'நீக்கு';

  @override
  String get cancelButton => 'ரத்து செய்';

  @override
  String get savedToHistory => 'வரலாற்றில் சேமிக்கப்பட்டது';

  @override
  String get settingsTitle => 'அமைப்புகள்';

  @override
  String get languageTitle => 'மொழி';

  @override
  String get howUnmaiDecidesTitle => 'உண்மை எப்படி தீர்மானிக்கிறது';

  @override
  String get howUnmaiDecidesContent =>
      'உண்மை ஆப் வரும் தகவல்களை அதிகாரப்பூர்வ தரவுத்தளங்கள் மற்றும் நம்பகமான ஆதாரங்களுடன் ஒப்பிடுகிறது. தெளிவான ஆதாரம் கிடைக்கவில்லை என்றால், தவறாக ஊகிக்காமல் \'சரிபார்க்க முடியவில்லை\' என்று வெளிப்படையாகத் தெரிவிக்கும்.';

  @override
  String get privacyTitle => 'தனியுரிமை குறிப்பு';

  @override
  String get privacyContent =>
      'உங்கள் சரிபார்ப்பு வரலாறு உங்கள் தொலைபேசியிலேயே பாதுகாப்பாக சேமிக்கப்படுகிறது. நீங்கள் சரிபார்க்கும் உள்ளடக்கம் மட்டுமே ஆய்வுக்கு அனுப்பப்படுகிறது. உங்கள் அடையாளம் சேகரிக்கப்படவோ விற்கப்படவோ மாட்டாது.';

  @override
  String get demoModeTitle => 'மாதிரி முறை (Demo)';

  @override
  String get demoModeSubtitle =>
      'பயிற்சிக்காக மாதிரி உதாரணங்களைப் பயன்படுத்தவும்';

  @override
  String get appVersionTitle => 'பதிப்பு';

  @override
  String get versionNumber => '1.0.0 (Unmai)';

  @override
  String get offlineError =>
      'இணைய இணைப்பு இல்லை. தயவுசெய்து சரிபார்த்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String get timeoutError =>
      'சரிபார்ப்புக்கு அதிக நேரம் எடுத்தது. தயவுசெய்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String get serverError =>
      'சேவையை அணுக முடியவில்லை. சிறிது நேரம் கழித்து முயற்சிக்கவும்.';

  @override
  String get retryButton => 'மீண்டும் முயற்சி செய்';
}
