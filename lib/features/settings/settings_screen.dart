import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../core/api/api_client.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_logo.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final isDemo = ref.watch(demoModeProvider);
    final serverUrl = ref.watch(serverUrlProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // App Identity Header
            const Center(
              child: Column(
                children: [
                  AppLogo(size: 64, showText: true, showTagline: true),
                  SizedBox(height: 20),
                ],
              ),
            ),

            // Language Selector Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.language_rounded,
                            size: 20, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text(
                          'Language',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('English'),
                          selected: currentLocale.languageCode == 'en',
                          onSelected: (val) {
                            if (val) {
                              ref
                                  .read(localeProvider.notifier)
                                  .setLocale(const Locale('en'));
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('தமிழ் (Tamil)'),
                          selected: currentLocale.languageCode == 'ta',
                          onSelected: (val) {
                            if (val) {
                              ref
                                  .read(localeProvider.notifier)
                                  .setLocale(const Locale('ta'));
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('हिन्दी (Hindi)'),
                          selected: currentLocale.languageCode == 'hi',
                          onSelected: (val) {
                            if (val) {
                              ref
                                  .read(localeProvider.notifier)
                                  .setLocale(const Locale('hi'));
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Demo Mode Switch
            Card(
              child: SwitchListTile(
                value: isDemo,
                onChanged: (val) {
                  ref.read(demoModeProvider.notifier).setDemoMode(val);
                },
                activeTrackColor: AppColors.primary,
                title: const Text(
                  'Demo Mode',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: const Text(
                  'When enabled, verifies with realistic sample reports. Turn off to connect to your live verification backend.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Backend Server URL Configuration
            Card(
              child: ListTile(
                leading: const Icon(Icons.dns_outlined, color: AppColors.primary),
                title: const Text(
                  'Backend Server URL',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  serverUrl,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.wifi_tethering_rounded, size: 20),
                      tooltip: 'Test Connection',
                      onPressed: () => _testServerConnection(context, serverUrl),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      tooltip: 'Edit Server URL',
                      onPressed: () => _editServerUrl(context, ref, serverUrl),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // How Unmai decides Explainer
            Card(
              child: ExpansionTile(
                leading: const Icon(Icons.psychology_alt_outlined,
                    color: AppColors.primary),
                title: const Text(
                  'How Unmai decides',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: const Text(
                  'Transparent, evidence-based methodology',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
                childrenPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: const [
                  Text(
                    '1. Claim Extraction: We isolate specific factual assertions rather than general opinions.\n\n'
                    '2. Evidence Search: We look for existing debunks and records from certified fact-checkers, official gazettes, and reputable news archives.\n\n'
                    '3. Neutral Comparison: We match each claim only against retrieved evidence. We never invent percentages or confidence scores.\n\n'
                    '4. Honest Unverified Status: If dependable evidence is missing, we clearly tell you "Can\'t verify" rather than guessing.',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Privacy Note
            Card(
              child: ExpansionTile(
                leading: const Icon(Icons.lock_outline_rounded,
                    color: AppColors.primary),
                title: const Text(
                  'Privacy note',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: const Text(
                  'What is stored locally vs. sent to the server',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
                childrenPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: const [
                  Text(
                    '• Stored locally on your phone:\n'
                    'Your entire history of past investigations and your language settings remain stored on your device only.\n\n'
                    '• Sent to the server for analysis:\n'
                    'Only the specific text snippet, link, photo, or video you choose to verify is submitted to perform the fact-check retrieval.\n\n'
                    '• What we never do:\n'
                    'We do not require phone numbers, track your personal identity, or sell your search history to advertisers.',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // App Version Info
            Card(
              child: ListTile(
                leading: const Icon(Icons.info_outline_rounded,
                    color: AppColors.textSecondary),
                title: const Text(
                  'App Version',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                trailing: const Text(
                  '1.0.0 (Unmai)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _testServerConnection(BuildContext context, String serverUrl) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Testing connection to $serverUrl...'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );

    try {
      final res = await http.get(Uri.parse('$serverUrl/')).timeout(
            const Duration(seconds: 4),
          );
      if (context.mounted) {
        if (res.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.trueGreen,
              content: Text('Backend connection successful! Server is online.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.misleadingAmber,
              content: Text('Server responded with HTTP ${res.statusCode}.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.falseRed,
            content: Text('Could not connect to $serverUrl. Make sure the backend is running.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _editServerUrl(BuildContext context, WidgetRef ref, String currentUrl) async {
    final controller = TextEditingController(text: currentUrl);
    final updated = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Backend Server URL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the address of your Unmai verification backend:',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: ApiClient.defaultBaseUrl(),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(serverUrlProvider.notifier).reset();
              Navigator.of(ctx).pop();
            },
            child: const Text('Reset Default'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (updated != null && updated.isNotEmpty) {
      ref.read(serverUrlProvider.notifier).setUrl(updated);
    }
  }
}
