import 'package:flutter/material.dart';
import '../../core/models/investigation.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/verdict_banner.dart';

class CorrectionCardWidget extends StatelessWidget {
  final Investigation investigation;

  const CorrectionCardWidget({
    super.key,
    required this.investigation,
  });

  @override
  Widget build(BuildContext context) {
    final verdict = investigation.verdict;
    final color = AppColors.verdictColor(verdict);
    final isTrue = verdict == VerdictType.true_;

    String? primarySource;
    if (isTrue && investigation.confirmedSources.isNotEmpty) {
      primarySource = investigation.confirmedSources.first.publisher;
    } else if (investigation.contradictingSources.isNotEmpty) {
      primarySource = investigation.contradictingSources.first.publisher;
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 360),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Unmai branding
          Row(
            children: [
              const AppLogo(size: 26),
              const SizedBox(width: 8),
              const Text(
                'Unmai',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              const Spacer(),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Checked before sharing',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Verdict Banner
          VerdictBanner(verdict: verdict, isLarge: true),
          const SizedBox(height: 14),

          // One-line plain-language reason
          Text(
            investigation.oneSentenceReason,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // Denominator/Evidence attribution
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(
                  isTrue ? Icons.verified_rounded : Icons.info_outline_rounded,
                  size: 18,
                  color: color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    primarySource != null
                        ? (isTrue
                            ? 'Confirmed by: $primarySource'
                            : 'Debunked by: $primarySource')
                        : 'Verified against authoritative public records',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Footer tag
          const Center(
            child: Text(
              'Checked with Unmai • Simple Fact-Checking for Everyone',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
