import '../theme/app_theme.dart';
export '../theme/app_theme.dart' show VerdictType;

class EvidenceSource {
  final String publisher;
  final String title;
  final String url;
  final String? publishedDate;
  final String sourceType;
  final String stance; // 'supports' or 'contradicts'
  final String summary;

  EvidenceSource({
    required this.publisher,
    required this.title,
    required this.url,
    this.publishedDate,
    required this.sourceType,
    required this.stance,
    required this.summary,
  });

  bool get supports => stance.toLowerCase() == 'supports';
  bool get contradicts => stance.toLowerCase() == 'contradicts';

  factory EvidenceSource.fromJson(Map<String, dynamic> json) {
    return EvidenceSource(
      publisher: json['publisher'] as String? ?? 'Unknown Publisher',
      title: json['title'] as String? ?? 'Evidence Reference',
      url: json['url'] as String? ?? '',
      publishedDate: json['publishedDate'] as String?,
      sourceType: json['sourceType'] as String? ?? 'Fact-check Report',
      stance: json['stance'] as String? ??
          (json['supports'] == true ? 'supports' : 'contradicts'),
      summary: json['summary'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'publisher': publisher,
      'title': title,
      'url': url,
      'publishedDate': publishedDate,
      'sourceType': sourceType,
      'stance': stance,
      'summary': summary,
    };
  }
}

class MediaAssessment {
  final String result; // 'Likely AI', 'Possibly AI', 'Inconclusive'
  final List<String> reasons;
  final String toolUsed;
  final String limitations;

  MediaAssessment({
    required this.result,
    required this.reasons,
    required this.toolUsed,
    required this.limitations,
  });

  factory MediaAssessment.fromJson(Map<String, dynamic> json) {
    return MediaAssessment(
      result: json['result'] as String? ?? 'Inconclusive',
      reasons: (json['reasons'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      toolUsed: json['toolUsed'] as String? ?? 'Reverse search & metadata audit',
      limitations: json['limitations'] as String? ??
          'Visual artifacts can be caused by heavy compression; not a definitive proof on its own.',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'result': result,
      'reasons': reasons,
      'toolUsed': toolUsed,
      'limitations': limitations,
    };
  }
}

class ScoreInfo {
  final int supportedClaims;
  final int totalClaims;
  final String evidenceStrength; // 'Strong', 'Medium', 'Weak', 'Insufficient'
  final String explanation;

  ScoreInfo({
    required this.supportedClaims,
    required this.totalClaims,
    required this.evidenceStrength,
    required this.explanation,
  });

  bool get isReliable =>
      evidenceStrength.toLowerCase() != 'insufficient' && totalClaims > 0;

  double get percentage =>
      totalClaims > 0 ? (supportedClaims / totalClaims) * 100 : 0.0;

  factory ScoreInfo.fromJson(Map<String, dynamic> json) {
    return ScoreInfo(
      supportedClaims: json['supportedClaims'] as int? ?? 0,
      totalClaims: json['totalClaims'] as int? ?? 0,
      evidenceStrength: json['evidenceStrength'] as String? ?? 'Weak',
      explanation: json['explanation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supportedClaims': supportedClaims,
      'totalClaims': totalClaims,
      'evidenceStrength': evidenceStrength,
      'explanation': explanation,
    };
  }
}

class Claim {
  final String id;
  final String text;
  final VerdictType verdict;
  final String explanation;
  final List<String> supportingEvidence;
  final List<String> contradictingEvidence;
  final String? missingContext;
  final List<EvidenceSource> sources;

  Claim({
    required this.id,
    required this.text,
    required this.verdict,
    required this.explanation,
    this.supportingEvidence = const [],
    this.contradictingEvidence = const [],
    this.missingContext,
    this.sources = const [],
  });

  factory Claim.fromJson(Map<String, dynamic> json) {
    return Claim(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      text: json['text'] as String? ?? '',
      verdict: _parseVerdict(json['verdict'] as String?),
      explanation: json['explanation'] as String? ?? '',
      supportingEvidence: (json['supportingEvidence'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      contradictingEvidence: (json['contradictingEvidence'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      missingContext: json['missingContext'] as String?,
      sources: (json['sources'] as List<dynamic>?)
              ?.map((e) => EvidenceSource.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'verdict': verdictToString(verdict),
      'explanation': explanation,
      'supportingEvidence': supportingEvidence,
      'contradictingEvidence': contradictingEvidence,
      'missingContext': missingContext,
      'sources': sources.map((s) => s.toJson()).toList(),
    };
  }
}

class Investigation {
  final String id;
  final String content;
  final String contentType; // 'text', 'url', 'image', 'video'
  final String? mediaPath;
  final VerdictType verdict;
  final String oneSentenceReason;
  final ScoreInfo scoreInfo;
  final MediaAssessment? mediaAssessment;
  final List<EvidenceSource> confirmedSources;
  final String? whyFalseReason;
  final List<EvidenceSource> contradictingSources;
  final List<Claim> claims;
  final DateTime createdAt;
  final bool isDemo;

  Investigation({
    required this.id,
    required this.content,
    required this.contentType,
    this.mediaPath,
    required this.verdict,
    required this.oneSentenceReason,
    required this.scoreInfo,
    this.mediaAssessment,
    this.confirmedSources = const [],
    this.whyFalseReason,
    this.contradictingSources = const [],
    this.claims = const [],
    required this.createdAt,
    this.isDemo = false,
  });

  factory Investigation.fromJson(Map<String, dynamic> json) {
    return Investigation(
      id: json['id'] as String? ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      content: json['content'] as String? ?? '',
      contentType: json['contentType'] as String? ?? 'text',
      mediaPath: json['mediaPath'] as String?,
      verdict: _parseVerdict(json['verdict'] as String?),
      oneSentenceReason: json['oneSentenceReason'] as String? ?? '',
      scoreInfo: json['scoreInfo'] != null
          ? ScoreInfo.fromJson(json['scoreInfo'] as Map<String, dynamic>)
          : ScoreInfo(
              supportedClaims: 0,
              totalClaims: 0,
              evidenceStrength: 'Insufficient',
              explanation: 'No claims verified.',
            ),
      mediaAssessment: json['mediaAssessment'] != null
          ? MediaAssessment.fromJson(
              json['mediaAssessment'] as Map<String, dynamic>)
          : null,
      confirmedSources: (json['confirmedSources'] as List<dynamic>?)
              ?.map((e) => EvidenceSource.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      whyFalseReason: json['whyFalseReason'] as String?,
      contradictingSources: (json['contradictingSources'] as List<dynamic>?)
              ?.map((e) => EvidenceSource.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      claims: (json['claims'] as List<dynamic>?)
              ?.map((e) => Claim.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      isDemo: json['isDemo'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'contentType': contentType,
      'mediaPath': mediaPath,
      'verdict': verdictToString(verdict),
      'oneSentenceReason': oneSentenceReason,
      'scoreInfo': scoreInfo.toJson(),
      'mediaAssessment': mediaAssessment?.toJson(),
      'confirmedSources': confirmedSources.map((s) => s.toJson()).toList(),
      'whyFalseReason': whyFalseReason,
      'contradictingSources':
          contradictingSources.map((s) => s.toJson()).toList(),
      'claims': claims.map((c) => c.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'isDemo': isDemo,
    };
  }
}

VerdictType _parseVerdict(String? raw) {
  if (raw == null) return VerdictType.unverified;
  final clean = raw.toLowerCase().trim();
  if (clean == 'true' || clean == 'true_') return VerdictType.true_;
  if (clean == 'false' || clean == 'false_') return VerdictType.false_;
  if (clean == 'misleading') return VerdictType.misleading;
  return VerdictType.unverified;
}

String verdictToString(VerdictType verdict) {
  switch (verdict) {
    case VerdictType.true_:
      return 'true';
    case VerdictType.false_:
      return 'false';
    case VerdictType.misleading:
      return 'misleading';
    case VerdictType.unverified:
      return 'unverified';
  }
}
