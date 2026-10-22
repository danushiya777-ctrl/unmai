import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/models/investigation.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/claim_card.dart';
import '../../core/widgets/correctness_meter.dart';
import '../../core/widgets/media_check_card.dart';
import '../../core/widgets/source_card.dart';
import '../../core/widgets/verdict_banner.dart';
import 'correction_card_widget.dart';

class ResultScreen extends StatefulWidget {
  final Investigation investigation;

  const ResultScreen({
    super.key,
    required this.investigation,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final GlobalKey _cardKey = GlobalKey();
  bool _isSharing = false;

  Future<void> _shareCorrectionCard() async {
    setState(() {
      _isSharing = true;
    });

    try {
      final boundary = _cardKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        // Fallback to text share
        // ignore: deprecated_member_use
        await Share.share(
          'Checked with Unmai:\nVerdict: ${verdictToString(widget.investigation.verdict).toUpperCase()}\n${widget.investigation.oneSentenceReason}',
        );
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null && !kIsWeb) {
        final buffer = byteData.buffer.asUint8List();
        final tempDir = await getTemporaryDirectory();
        final filePath =
            '${tempDir.path}/unmai_correction_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File(filePath);
        await file.writeAsBytes(buffer);

        // ignore: deprecated_member_use
        await Share.shareXFiles(
          [XFile(filePath)],
          text:
              'Checked with Unmai: ${widget.investigation.oneSentenceReason}',
        );
      } else {
        // ignore: deprecated_member_use
        await Share.share(
          'Checked with Unmai:\nVerdict: ${verdictToString(widget.investigation.verdict).toUpperCase()}\n${widget.investigation.oneSentenceReason}',
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sharing correction card...'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final inv = widget.investigation;
    final isTrue = inv.verdict == VerdictType.true_;
    final isFalseOrMisleading = inv.verdict == VerdictType.false_ ||
        inv.verdict == VerdictType.misleading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Investigation Result'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Mandatory Demo Data Banner if demo mode
              if (inv.isDemo) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.misleadingAmberLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.misleadingAmberBorder),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 18, color: AppColors.misleadingAmber),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Demo data. Not a live finding.',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.misleadingAmber,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 1. Verdict banner
              VerdictBanner(verdict: inv.verdict, isLarge: true),
              const SizedBox(height: 16),

              // 2. One-sentence plain-language reason
              Card(
                color: AppColors.surface,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SUMMARY',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        inv.oneSentenceReason,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 3. Correctness meter
              CorrectnessMeter(scoreInfo: inv.scoreInfo),
              const SizedBox(height: 16),

              // 4. Media check card (if image or video analysis exists)
              if (inv.mediaAssessment != null) ...[
                MediaCheckCard(assessment: inv.mediaAssessment!),
                const SizedBox(height: 16),
              ],

              // 5. Sources: Confirmed / Referenced / Empty
              if (inv.confirmedSources.isEmpty &&
                  inv.contradictingSources.isEmpty) ...[
                const Text(
                  'Sources',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 20, color: AppColors.textSecondary),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'No trusted sources found',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // If TRUE: "Confirmed by" list of source cards
              if (isTrue && inv.confirmedSources.isNotEmpty) ...[
                const Text(
                  'Confirmed by',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 10),
                ...inv.confirmedSources.map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SourceCard(source: s, isContradicting: false),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // If CAN'T VERIFY but has reference sources
              if (!isTrue &&
                  !isFalseOrMisleading &&
                  inv.confirmedSources.isNotEmpty) ...[
                const Text(
                  'Reference sources',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 10),
                ...inv.confirmedSources.map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SourceCard(source: s, isContradicting: false),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // 6. If FALSE or MISLEADING: "Why this is false"
              if (isFalseOrMisleading) ...[
                const Text(
                  'Why this is false',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.falseRed,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 10),
                if (inv.whyFalseReason != null &&
                    inv.whyFalseReason!.isNotEmpty) ...[
                  Card(
                    color: AppColors.falseRedLight,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.cancel_rounded,
                              size: 20, color: AppColors.falseRed),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              inv.whyFalseReason!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.falseRed,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                ...inv.contradictingSources.map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SourceCard(source: s, isContradicting: true),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // 7. Expandable claim-by-claim cards
              if (inv.claims.isNotEmpty) ...[
                const Text(
                  'Claim-by-claim analysis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 10),
                ...inv.claims.asMap().entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ClaimCard(
                      claim: entry.value,
                      index: entry.key,
                      initialExpanded: entry.key == 0,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 8. "Share correction card" button
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSharing ? null : _shareCorrectionCard,
                  icon: _isSharing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.share_rounded, size: 20),
                  label: const Text(
                    'Share correction card',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // High-res preview & RepaintBoundary for image generation
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: RepaintBoundary(
                    key: _cardKey,
                    child: CorrectionCardWidget(investigation: inv),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
