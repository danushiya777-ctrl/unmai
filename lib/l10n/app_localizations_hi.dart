// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'Unmai';

  @override
  String get appTagline => 'शेयर करने से पहले जांचें।';

  @override
  String get tabVerify => 'जांचें';

  @override
  String get tabHistory => 'इतिहास';

  @override
  String get tabSettings => 'सेटिंग्स';

  @override
  String get pasteBoxPlaceholder =>
      'संदिग्ध संदेश, दावा या लिंक यहाँ पेस्ट करें...';

  @override
  String get pasteButton => 'क्लिपबोर्ड से पेस्ट करें';

  @override
  String get pickImage => 'तस्वीर';

  @override
  String get pickVideo => 'वीडियो';

  @override
  String get removeAttachment => 'हटाएं';

  @override
  String get verifyButton => 'अभी जांचें';

  @override
  String get progressReading => 'सामग्री पढ़ रहे हैं';

  @override
  String get progressSearching => 'स्रोत खोज रहे हैं';

  @override
  String get progressCheckingMedia => 'तस्वीर/वीडियो की जांच';

  @override
  String get progressResult => 'परिणाम तैयार कर रहे हैं';

  @override
  String get emptyInputError =>
      'कृपया कोई संदेश, लिंक दर्ज करें या तस्वीर/वीडियो चुनें।';

  @override
  String get invalidUrlError => 'कृपया एक मान्य वेब लिंक (URL) दर्ज करें।';

  @override
  String get fileTooLargeError => 'फ़ाइल का आकार 50MB से अधिक है।';

  @override
  String get unsupportedFileError =>
      'असमर्थित प्रारूप। कृपया JPG, PNG, WEBP या MP4 चुनें।';

  @override
  String get verdictTrue => 'सच';

  @override
  String get verdictFalse => 'गलत';

  @override
  String get verdictMisleading => 'भ्रामक';

  @override
  String get verdictUnverified => 'पुष्टि नहीं हो सकी';

  @override
  String get correctnessTitle => 'सटीकता मीटर';

  @override
  String claimsSupported(int supported, int total) {
    return '$total में से $supported दावे सही पाए गए';
  }

  @override
  String get evidenceStrengthStrong => 'मजबूत सबूत';

  @override
  String get evidenceStrengthMedium => 'मध्यम सबूत';

  @override
  String get evidenceStrengthWeak => 'कमजोर सबूत';

  @override
  String get notEnoughEvidence =>
      'सटीक स्कोर के लिए पर्याप्त सबूत उपलब्ध नहीं हैं।';

  @override
  String get mediaAssessmentTitle => 'मीडिया जांच';

  @override
  String get mediaLikelyAi => 'संभावित कृत्रिम निर्माण (AI)';

  @override
  String get mediaPossiblyAi => 'संभावित फेरबदल';

  @override
  String get mediaInconclusive => 'अस्पष्ट (निर्णय नहीं हो सका)';

  @override
  String mediaToolUsed(String tool) {
    return 'प्रयुक्त साधन: $tool';
  }

  @override
  String mediaLimitations(String limitations) {
    return 'सीमाएं: $limitations';
  }

  @override
  String get confirmedByTitle => 'इन स्रोतों द्वारा पुष्टि की गई';

  @override
  String get whyFalseTitle => 'यह गलत क्यों है';

  @override
  String get claimsBreakdownTitle => 'दावों का विस्तृत विवरण';

  @override
  String get shareCorrectionCard => 'सुधार कार्ड शेयर करें';

  @override
  String get checkedWithUnmai => 'Unmai द्वारा जाँचा गया';

  @override
  String get demoDataBanner => 'डेमो डेटा। यह वास्तविक परिणाम नहीं है।';

  @override
  String get supportingEvidence => 'समर्थक सबूत';

  @override
  String get contradictingEvidence => 'खंडन करने वाले सबूत';

  @override
  String get missingContext => 'गायब संदर्भ';

  @override
  String publishedOn(String date) {
    return 'प्रकाशित: $date';
  }

  @override
  String get openSourceLink => 'मूल स्रोत लिंक खोलें';

  @override
  String get historyTitle => 'इतिहास';

  @override
  String get searchPlaceholder => 'पिछली जांच खोजें...';

  @override
  String get filterAll => 'सभी';

  @override
  String get emptyHistoryTitle => 'अभी कोई जांच नहीं हुई';

  @override
  String get emptyHistorySubtitle =>
      'आपके द्वारा जाँचे गए संदेश सुरक्षित रूप से केवल आपके फ़ोन पर सहेजे जाएंगे।';

  @override
  String get deleteReportConfirm => 'क्या इस रिपोर्ट को हटाना चाहते हैं?';

  @override
  String get deleteButton => 'हटाएं';

  @override
  String get cancelButton => 'रद्द करें';

  @override
  String get savedToHistory => 'इतिहास में सहेजा गया';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get languageTitle => 'भाषा (Language)';

  @override
  String get howUnmaiDecidesTitle => 'Unmai कैसे निर्णय लेता है';

  @override
  String get howUnmaiDecidesContent =>
      'Unmai संदेशों की तुलना आधिकारिक डेटाबेस, सरकारी घोषणाओं और विश्वसनीय समाचार स्रोतों से करता है। अगर पुख्ता सबूत नहीं मिलते, तो हम अंदाज़ा लगाने के बजाय स्पष्ट रूप से \'पुष्टि नहीं हो सकी\' बताते हैं।';

  @override
  String get privacyTitle => 'गोपनीयता नोट';

  @override
  String get privacyContent =>
      'आपकी सभी जाँची गई रिपोर्ट केवल आपके फ़ोन में रहती हैं। विश्लेषण के लिए केवल संदेश सर्वर पर भेजा जाता है। हम आपका व्यक्तिगत डेटा कभी नहीं बेचते।';

  @override
  String get demoModeTitle => 'डेमो मोड (Demo)';

  @override
  String get demoModeSubtitle => 'अभ्यास के लिए तैयार उदाहरणों का उपयोग करें';

  @override
  String get appVersionTitle => 'ऐप संस्करण';

  @override
  String get versionNumber => '1.0.0 (Unmai)';

  @override
  String get offlineError =>
      'इंटरनेट कनेक्शन नहीं है। कृपया नेटवर्क जांचें और पुनः प्रयास करें।';

  @override
  String get timeoutError => 'जांच में अधिक समय लगा। कृपया पुनः प्रयास करें।';

  @override
  String get serverError =>
      'सत्यापन सेवा से कनेक्ट नहीं हो सका। कृपया थोड़ी देर बाद प्रयास करें।';

  @override
  String get retryButton => 'फिर से प्रयास करें';
}
