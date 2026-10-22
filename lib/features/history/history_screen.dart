import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/investigation.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/state_views.dart';
import '../../core/widgets/verdict_banner.dart';
import '../result/result_screen.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  VerdictType? _selectedVerdictFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _contentTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'image':
        return Icons.image_rounded;
      case 'video':
        return Icons.videocam_rounded;
      case 'url':
        return Icons.link_rounded;
      default:
        return Icons.chat_bubble_outline_rounded;
    }
  }

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Future<void> _confirmDelete(Investigation item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete from history?'),
        content: const Text(
            'This saved report will be permanently removed from your device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.falseRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(historyProvider.notifier).delete(item.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allHistory = ref.watch(historyProvider);
    final query = _searchController.text.trim().toLowerCase();

    final filtered = allHistory.where((item) {
      final matchesQuery = query.isEmpty ||
          item.content.toLowerCase().contains(query) ||
          item.oneSentenceReason.toLowerCase().contains(query);

      final matchesFilter = _selectedVerdictFilter == null ||
          item.verdict == _selectedVerdictFilter;

      return matchesQuery && matchesFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          if (allHistory.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear history',
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear all history?'),
                    content: const Text(
                        'All saved checks will be deleted from your phone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.falseRed,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Clear all'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await ref.read(historyProvider.notifier).clearAll();
                }
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search previous checks...',
                  prefixIcon:
                      const Icon(Icons.search_rounded, color: AppColors.textMuted),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                            });
                          },
                        )
                      : null,
                ),
              ),
            ),

            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: _selectedVerdictFilter == null,
                    onSelected: (val) {
                      setState(() {
                        _selectedVerdictFilter = null;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('True'),
                    selected: _selectedVerdictFilter == VerdictType.true_,
                    selectedColor: AppColors.trueGreenLight,
                    onSelected: (val) {
                      setState(() {
                        _selectedVerdictFilter =
                            val ? VerdictType.true_ : null;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('False'),
                    selected: _selectedVerdictFilter == VerdictType.false_,
                    selectedColor: AppColors.falseRedLight,
                    onSelected: (val) {
                      setState(() {
                        _selectedVerdictFilter =
                            val ? VerdictType.false_ : null;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Misleading'),
                    selected: _selectedVerdictFilter == VerdictType.misleading,
                    selectedColor: AppColors.misleadingAmberLight,
                    onSelected: (val) {
                      setState(() {
                        _selectedVerdictFilter =
                            val ? VerdictType.misleading : null;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text("Can't verify"),
                    selected: _selectedVerdictFilter == VerdictType.unverified,
                    selectedColor: AppColors.unverifiedSlateLight,
                    onSelected: (val) {
                      setState(() {
                        _selectedVerdictFilter =
                            val ? VerdictType.unverified : null;
                      });
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 12),

            // List of history items
            Expanded(
              child: filtered.isEmpty
                  ? EmptyState(
                      icon: Icons.history_rounded,
                      title: allHistory.isEmpty
                          ? 'No checks yet'
                          : 'No matching checks',
                      subtitle: allHistory.isEmpty
                          ? 'Suspicious messages and media you verify will be saved here on your device.'
                          : 'Try adjusting your search query or filter chip.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      itemCount: filtered.length,
                      separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                      itemBuilder: (ctx, index) {
                        final item = filtered[index];
                        return Card(
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (ctx) =>
                                      ResultScreen(investigation: item),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      _contentTypeIcon(item.contentType),
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            VerdictBanner(
                                              verdict: item.verdict,
                                              isLarge: false,
                                            ),
                                            const Spacer(),
                                            Text(
                                              _formatDate(item.createdAt),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          item.content,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                            height: 1.35,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item.oneSentenceReason,
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            color: AppColors.textSecondary,
                                            height: 1.3,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      size: 18,
                                      color: AppColors.textMuted,
                                    ),
                                    onPressed: () => _confirmDelete(item),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
