// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Unmai';

  @override
  String get appTagline => 'Check before you share.';

  @override
  String get tabVerify => 'Verify';

  @override
  String get tabHistory => 'History';

  @override
  String get tabSettings => 'Settings';

  @override
  String get pasteBoxPlaceholder =>
      'Paste suspicious message, claim, or link here...';

  @override
  String get pasteButton => 'Paste from clipboard';

  @override
  String get pickImage => 'Photo';

  @override
  String get pickVideo => 'Video';

  @override
  String get removeAttachment => 'Remove attachment';

  @override
  String get verifyButton => 'Verify now';

  @override
  String get progressReading => 'Reading content';

  @override
  String get progressSearching => 'Searching sources';

  @override
  String get progressCheckingMedia => 'Checking media';

  @override
  String get progressResult => 'Preparing result';

  @override
  String get emptyInputError =>
      'Please enter text, a URL, or attach a photo or video.';

  @override
  String get invalidUrlError => 'Please enter a valid web URL.';

  @override
  String get fileTooLargeError => 'File exceeds 50MB limit.';

  @override
  String get unsupportedFileError =>
      'Unsupported format. Please select JPG, PNG, WEBP, or MP4.';

  @override
  String get verdictTrue => 'True';

  @override
  String get verdictFalse => 'False';

  @override
  String get verdictMisleading => 'Misleading';

  @override
  String get verdictUnverified => 'Can\'t verify';

  @override
  String get correctnessTitle => 'Correctness meter';

  @override
  String claimsSupported(int supported, int total) {
    return '$supported of $total claims supported';
  }

  @override
  String get evidenceStrengthStrong => 'Strong evidence';

  @override
  String get evidenceStrengthMedium => 'Medium evidence';

  @override
  String get evidenceStrengthWeak => 'Weak evidence';

  @override
  String get notEnoughEvidence => 'Not enough evidence for a reliable score.';

  @override
  String get mediaAssessmentTitle => 'Media check';

  @override
  String get mediaLikelyAi => 'Likely AI';

  @override
  String get mediaPossiblyAi => 'Possibly AI';

  @override
  String get mediaInconclusive => 'Inconclusive';

  @override
  String mediaToolUsed(String tool) {
    return 'Tool used: $tool';
  }

  @override
  String mediaLimitations(String limitations) {
    return 'Limitations: $limitations';
  }

  @override
  String get confirmedByTitle => 'Confirmed by';

  @override
  String get whyFalseTitle => 'Why this is false';

  @override
  String get claimsBreakdownTitle => 'Claim-by-claim breakdown';

  @override
  String get shareCorrectionCard => 'Share correction card';

  @override
  String get checkedWithUnmai => 'Checked with Unmai';

  @override
  String get demoDataBanner => 'Demo data. Not a live finding.';

  @override
  String get supportingEvidence => 'Supporting evidence';

  @override
  String get contradictingEvidence => 'Contradicting evidence';

  @override
  String get missingContext => 'Missing context';

  @override
  String publishedOn(String date) {
    return 'Published: $date';
  }

  @override
  String get openSourceLink => 'Open source link';

  @override
  String get historyTitle => 'History';

  @override
  String get searchPlaceholder => 'Search previous checks...';

  @override
  String get filterAll => 'All';

  @override
  String get emptyHistoryTitle => 'No checks yet';

  @override
  String get emptyHistorySubtitle =>
      'Suspicious forwards you verify will be saved here on your device.';

  @override
  String get deleteReportConfirm => 'Delete this report?';

  @override
  String get deleteButton => 'Delete';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get savedToHistory => 'Saved to history';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageTitle => 'Language';

  @override
  String get howUnmaiDecidesTitle => 'How Unmai decides';

  @override
  String get howUnmaiDecidesContent =>
      'Unmai compares claims against authoritative fact-check databases, official sources, and public records. If reliable evidence cannot be found, we clearly mark it as unverified rather than guessing.';

  @override
  String get privacyTitle => 'Privacy note';

  @override
  String get privacyContent =>
      'All your verification history is saved locally on your phone. When you verify a claim, only that text or media is sent securely to the server. We do not sell your data or track your identity.';

  @override
  String get demoModeTitle => 'Demo mode';

  @override
  String get demoModeSubtitle => 'Use built-in realistic examples for practice';

  @override
  String get appVersionTitle => 'App version';

  @override
  String get versionNumber => '1.0.0 (Unmai)';

  @override
  String get offlineError =>
      'No internet connection. Please check your network and try again.';

  @override
  String get timeoutError =>
      'The check took too long to complete. Please try again.';

  @override
  String get serverError =>
      'Could not connect to the verification service. Please try again shortly.';

  @override
  String get retryButton => 'Try again';
}
