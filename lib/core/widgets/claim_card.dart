import 'package:flutter/material.dart';
import '../models/investigation.dart';
import '../theme/app_theme.dart';
import 'source_card.dart';
import 'verdict_banner.dart';

class ClaimCard extends StatefulWidget {
  final Claim claim;
  final int index;
  final bool initialExpanded;

  const ClaimCard({
    super.key,
    required this.claim,
    required this.index,
    this.initialExpanded = false,
  });

  @override
  State<ClaimCard> createState() => _ClaimCardState();
}

class _ClaimCardState extends State<ClaimCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initialExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final claim = widget.claim;

    return Card(
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${widget.index + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          claim.text,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 8),
                        VerdictBanner(
                          verdict: claim.verdict,
                          isLarge: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (claim.explanation.isNotEmpty) ...[
                    Text(
                      claim.explanation,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  if (claim.supportingEvidence.isNotEmpty) ...[
                    const Text(
                      'Supporting evidence:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.trueGreen,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...claim.supportingEvidence.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('✓ ',
                                style: TextStyle(
                                    color: AppColors.trueGreen,
                                    fontWeight: FontWeight.bold)),
                            Expanded(
                              child: Text(
                                e,
                                style: const TextStyle(
                                    fontSize: 13, color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (claim.contradictingEvidence.isNotEmpty) ...[
                    const Text(
                      'Contradicting evidence:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.falseRed,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...claim.contradictingEvidence.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('✗ ',
                                style: TextStyle(
                                    color: AppColors.falseRed,
                                    fontWeight: FontWeight.bold)),
                            Expanded(
                              child: Text(
                                e,
                                style: const TextStyle(
                                    fontSize: 13, color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (claim.missingContext != null &&
                      claim.missingContext!.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.misleadingAmberLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.misleadingAmberBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.info_outline,
                                  size: 16, color: AppColors.misleadingAmber),
                              SizedBox(width: 6),
                              Text(
                                'Missing context:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.misleadingAmber,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            claim.missingContext!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (claim.sources.isNotEmpty) ...[
                    const Text(
                      'Sources:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...claim.sources.map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SourceCard(
                          source: s,
                          isContradicting: s.contradicts,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
