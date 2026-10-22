import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unmai/core/models/investigation.dart';
import 'package:unmai/features/result/result_screen.dart';
import 'package:unmai/main.dart';

void main() {
  testWidgets('App smoke test loads Unmai splash screen and transitions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: UnmaiApp()));

    // Initial splash screen renders Unmai logo and tagline
    expect(find.text('Unmai'), findsOneWidget);
    expect(find.text('Check before you share.'), findsOneWidget);

    // Settle splash timer
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();
  });

  testWidgets('ResultScreen handles long source metadata on narrow layouts', (
    WidgetTester tester,
  ) async {
    final investigation = Investigation(
      id: 'result-overflow-check',
      content: 'Long content',
      contentType: 'text',
      verdict: VerdictType.false_,
      oneSentenceReason:
          'This claim is false because the record shows the opposite and the official explanation is much longer than the summary here.',
      scoreInfo: ScoreInfo(
        supportedClaims: 1,
        totalClaims: 3,
        evidenceStrength: 'Medium',
        explanation: 'The available evidence supports only part of the claim.',
      ),
      whyFalseReason:
          'The claim is contradicted by a long official record and multiple independent briefings.',
      contradictingSources: [
        EvidenceSource(
          publisher:
              'The National Commission on Public Integrity and Accountability Office',
          title:
              'Official statement explaining the long-running discrepancies in the report and the evidence audit performed by the commission',
          url: 'https://example.com/very-long-official-report',
          publishedDate: 'January 12, 2026',
          sourceType: 'Government Report',
          stance: 'contradicts',
          summary:
              'A long summary that describes the contradictory evidence and the official record that clearly disputes the unsupported claim.',
        ),
      ],
      claims: [
        Claim(
          id: 'claim-1',
          text:
              'This claim is false because it ignores the official record and omits the context that explains why the statement is misleading in practice.',
          verdict: VerdictType.false_,
          explanation:
              'The available evidence shows the opposite and the context behind the statement is materially different from how it was presented.',
          contradictingEvidence: [
            'A broad record of official documents and independent reporting shows the statement is misleading because critical context was left out.',
          ],
          missingContext:
              'The public explanation makes this appear definitive when the full record shows it was a temporary response to an ongoing investigation.',
          sources: [
            EvidenceSource(
              publisher:
                  'The Independent Review Board for Public Communications and Verification',
              title:
                  'A detailed account of the timeline, official response, and why the claim is misleading without the surrounding context',
              url: 'https://example.com/very-long-claim-source',
              publishedDate: 'February 6, 2026',
              sourceType: 'Fact-check Report',
              stance: 'contradicts',
              summary:
                  'This source explains the timeline and why the claim fails to account for the surrounding events and the official record.',
            ),
          ],
        ),
      ],
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(360, 740)),
          child: ResultScreen(investigation: investigation),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  test('Investigation model parses live-shaped backend JSON payload accurately', () {
    final livePayload = {
      'id': 'live-uuid-1234',
      'content': 'NASA confirmed 3 days of total darkness across Earth in December.',
      'contentType': 'text',
      'verdict': 'false',
      'oneSentenceReason': 'This claim is contradicted by official NASA astronomy schedules.',
      'isDemo': false,
      'scoreInfo': {
        'supportedClaims': 0,
        'totalClaims': 1,
        'evidenceStrength': 'Strong',
        'explanation': 'Contradicted by official astronomical agency statements.'
      },
      'whyFalseReason': 'Astronomical records confirm solar cycles remain normal.',
      'contradictingSources': [
        {
          'id': 'src-1',
          'publisher': 'NASA Science',
          'title': 'Solar Myths and Earth Illumination Facts',
          'url': 'https://science.nasa.gov/solar-facts',
          'publishedDate': '2024-10-15',
          'sourceType': 'Official Government',
          'stance': 'contradicts',
          'summary': 'NASA confirmed no such eclipse or darkness event exists.'
        }
      ],
      'confirmedSources': [],
      'claims': [
        {
          'id': 'c-1',
          'text': 'Earth will experience 3 days of total darkness.',
          'verdict': 'false',
          'explanation': 'Contradicted by planetary physics and astronomical records.',
          'contradictingEvidence': ['Planetary records show normal daylight cycle.'],
          'supportingEvidence': [],
          'missingContext': null,
          'sources': []
        }
      ],
      'mediaAssessment': {
        'result': 'no_indicators_found',
        'reasons': ['Text verification only; no image metadata.'],
        'toolUsed': 'ExifAnalyzer',
        'limitations': 'Standard checks applied.'
      },
      'createdAt': '2026-10-22T21:00:00Z'
    };

    final inv = Investigation.fromJson(livePayload);

    expect(inv.id, 'live-uuid-1234');
    expect(inv.verdict, VerdictType.false_);
    expect(inv.isDemo, false);
    expect(inv.scoreInfo.supportedClaims, 0);
    expect(inv.scoreInfo.totalClaims, 1);
    expect(inv.scoreInfo.evidenceStrength, 'Strong');
    expect(inv.contradictingSources.length, 1);
    expect(inv.contradictingSources.first.publisher, 'NASA Science');
    expect(inv.mediaAssessment?.result, 'no_indicators_found');
  });

  testWidgets('ResultScreen displays "No trusted sources found" when sources are empty', (
    WidgetTester tester,
  ) async {
    final invEmptySources = Investigation(
      id: 'empty-sources-inv',
      content: 'Some unverifiable rumor with no public record',
      contentType: 'text',
      verdict: VerdictType.unverified,
      oneSentenceReason: 'No public records found to verify this statement.',
      scoreInfo: ScoreInfo(
        supportedClaims: 0,
        totalClaims: 1,
        evidenceStrength: 'Insufficient',
        explanation: 'No sources found.',
      ),
      claims: [],
      confirmedSources: [],
      contradictingSources: [],
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ResultScreen(investigation: invEmptySources),
      ),
    );

    expect(find.text('No trusted sources found'), findsOneWidget);
    expect(find.text('Investigation Result'), findsOneWidget);
  });
}

