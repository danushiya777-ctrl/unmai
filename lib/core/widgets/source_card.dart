import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/investigation.dart';
import '../theme/app_theme.dart';

class SourceCard extends StatelessWidget {
  final EvidenceSource source;
  final bool isContradicting;

  const SourceCard({
    super.key,
    required this.source,
    this.isContradicting = false,
  });

  Future<void> _openLink(BuildContext context) async {
    final rawUrl = source.url.trim();
    if (rawUrl.isEmpty) return;

    // Strict safety check: only http or https
    final uri = Uri.tryParse(rawUrl);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid web link.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open external link.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open link in browser.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = isContradicting
        ? AppColors.falseRed
        : AppColors.trueGreen;
    final badgeBg = isContradicting
        ? AppColors.falseRedLight
        : AppColors.trueGreenLight;

    return Card(
      child: InkWell(
        onTap: source.url.isNotEmpty ? () => _openLink(context) : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: badgeColor.withAlpha(50)),
                    ),
                    child: Text(
                      source.sourceType,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: badgeColor,
                      ),
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width - 160,
                    ),
                    child: Text(
                      source.publisher,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (source.publishedDate != null &&
                      source.publishedDate!.isNotEmpty)
                    Text(
                      source.publishedDate!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                source.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
                softWrap: true,
              ),
              if (source.summary.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  source.summary,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  softWrap: true,
                ),
              ],
              if (source.url.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View source',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.open_in_new_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
