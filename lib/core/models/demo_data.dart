import 'investigation.dart';

class DemoData {
  /// Demo 1: Recycled old photo shared as a recent catastrophe (FALSE)
  static Investigation get falsePhotoReport => Investigation(
        id: 'demo-false-photo-001',
        content:
            'Breaking: Terrible explosion reported at the city central train station just minutes ago! Share immediately to alert others.',
        contentType: 'image',
        mediaPath: 'assets/images/demo_fire.jpg',
        verdict: VerdictType.false_,
        oneSentenceReason:
            'This photo is from an accidental storage fire that took place 6 years ago, and not from any incident today.',
        scoreInfo: ScoreInfo(
          supportedClaims: 0,
          totalClaims: 1,
          evidenceStrength: 'Strong',
          explanation:
              'Authoritative archival news records and official emergency services directly contradict the claim.',
        ),
        mediaAssessment: MediaAssessment(
          result: 'Inconclusive',
          reasons: [
            'Reverse image search identified the identical photograph published in August 2018.',
            'No evidence of AI digital synthesis detected; the visual is an authentic photograph recycled out of context.',
          ],
          toolUsed: 'Reverse visual search & archival database cross-referencing',
          limitations:
              'Reverse search checks publicly indexed media and cannot index private messages or closed groups.',
        ),
        whyFalseReason:
            'Recycled old content. The image was taken during a chemical warehouse fire in August 2018 and has no relation to present events.',
        contradictingSources: [
          EvidenceSource(
            publisher: 'Reuters Fact Check',
            title:
                'Fact Check: 2018 warehouse blaze falsely shared as recent railway station blast',
            url: 'https://www.reuters.com/fact-check',
            publishedDate: '14 Aug 2018',
            sourceType: 'Fact-Check Report',
            stance: 'contradicts',
            summary:
                'Archived photographs verify the scene was an industrial fire in 2018. Railway authorities confirm regular operations with zero incidents.',
          ),
          EvidenceSource(
            publisher: 'Official Police Verification Bureau',
            title:
                'Public Advisory: False alarm circulating about train terminus security',
            url: 'https://pib.gov.in/factcheck',
            publishedDate: '12 Oct 2024',
            sourceType: 'Official Record',
            stance: 'contradicts',
            summary:
                'City law enforcement inspected the terminal and confirmed zero emergencies. Legal action is being pursued against malicious misinformation spreaders.',
          ),
        ],
        claims: [
          Claim(
            id: 'c1',
            text:
                'An explosion occurred at the metropolitan central railway station today.',
            verdict: VerdictType.false_,
            explanation:
                'Railway officials, local police, and emergency responders verified that all terminals are running normally with no safety incidents.',
            contradictingEvidence: [
              'Central Railway public relations office issued a formal denial confirming normal schedule.',
              'The accompanying image was proven to date back to an August 2018 industrial accident.',
            ],
            missingContext:
                'The forwarded post attached a 2018 photo to generate panic in community chat groups.',
            sources: [
              EvidenceSource(
                publisher: 'Reuters Fact Check',
                title: 'Fact Check: 2018 warehouse blaze falsely shared as recent blast',
                url: 'https://www.reuters.com/fact-check',
                publishedDate: '14 Aug 2018',
                sourceType: 'Fact-Check Report',
                stance: 'contradicts',
                summary: 'Confirmed original photo publication in 2018.',
              ),
            ],
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isDemo: true,
      );

  /// Demo 2: True government health advisory (TRUE)
  static Investigation get trueGovReport => Investigation(
        id: 'demo-true-gov-002',
        content:
            'Health department announces free nationwide HPV vaccination campaign for adolescent girls aged 9 to 14 at all government wellness clinics.',
        contentType: 'text',
        verdict: VerdictType.true_,
        oneSentenceReason:
            'The Ministry of Health officially launched this free immunization program for girls aged 9 to 14 across public health centers.',
        scoreInfo: ScoreInfo(
          supportedClaims: 2,
          totalClaims: 2,
          evidenceStrength: 'Strong',
          explanation:
              'Both key assertions are directly verified against published government gazettes and ministry press releases.',
        ),
        mediaAssessment: null,
        confirmedSources: [
          EvidenceSource(
            publisher: 'Press Information Bureau (PIB)',
            title:
                'Government rolls out free cervical cancer vaccination for girls aged 9-14',
            url: 'https://pib.gov.in',
            publishedDate: '15 Jan 2024',
            sourceType: 'Government Gazette',
            stance: 'supports',
            summary:
                'The Union Health Ministry announced the phased rollout of free HPV vaccines through the Universal Immunization Programme at government clinics.',
          ),
          EvidenceSource(
            publisher: 'World Health Organization (WHO)',
            title: 'National Immunization Technical Guidance: HPV Prevention',
            url: 'https://www.who.int',
            publishedDate: '02 Feb 2024',
            sourceType: 'Public Health Agency',
            stance: 'supports',
            summary:
                'WHO applauded the public health initiative providing primary protection against cervical cancer for young girls.',
          ),
        ],
        claims: [
          Claim(
            id: 'c1',
            text:
                'Free HPV vaccination is provided for adolescent girls between 9 and 14 years.',
            verdict: VerdictType.true_,
            explanation:
                'The official operational guidelines define the eligible cohort specifically as girls aged 9 through 14 years.',
            supportingEvidence: [
              'Target demographic is codified in Ministry of Health circular #HPV-2024.',
              'Schools and community health centers have begun scheduled immunization camps.',
            ],
            sources: [
              EvidenceSource(
                publisher: 'Press Information Bureau (PIB)',
                title: 'Government rolls out free cervical cancer vaccination',
                url: 'https://pib.gov.in',
                publishedDate: '15 Jan 2024',
                sourceType: 'Government Gazette',
                stance: 'supports',
                summary: 'Eligible age confirmed as 9 to 14 years.',
              ),
            ],
          ),
          Claim(
            id: 'c2',
            text:
                'Vaccines are administered at no cost in public health clinics.',
            verdict: VerdictType.true_,
            explanation:
                'All doses under this public health initiative are fully funded by the national health mission.',
            supportingEvidence: [
              'No user fee or registration fee is charged at any government facility.',
            ],
            sources: [
              EvidenceSource(
                publisher: 'Ministry of Health & Family Welfare',
                title: 'Universal Immunization Guidelines',
                url: 'https://pib.gov.in',
                publishedDate: '18 Jan 2024',
                sourceType: 'Official Record',
                stance: 'supports',
                summary: 'Zero cost verified across public clinics.',
              ),
            ],
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
        isDemo: true,
      );
}
