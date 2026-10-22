import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/share_intent_service.dart';
import '../../core/theme/app_theme.dart';
import '../history/history_screen.dart';
import '../settings/settings_screen.dart';
import '../verify/verify_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;

  // Shared content passed in from WhatsApp or external share
  String? _sharedText;
  String? _sharedFilePath;
  String? _sharedFileType;
  int _verifyKeyCount = 0;

  @override
  void initState() {
    super.initState();
    _initShareIntentListener();
  }

  void _initShareIntentListener() {
    ShareIntentService.listen((content) {
      if (!mounted) return;
      setState(() {
        _currentIndex = 0; // Switch to Verify tab immediately
        _sharedText = content.text;
        _sharedFilePath = content.filePath;
        _sharedFileType = content.fileType;
        _verifyKeyCount++; // Force reload verify screen with shared input
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Received shared content for verification.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  void dispose() {
    ShareIntentService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          VerifyScreen(
            key: ValueKey('verify_$_verifyKeyCount'),
            initialText: _sharedText,
            initialFilePath: _sharedFilePath,
            initialFileType: _sharedFileType,
          ),
          const HistoryScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield_rounded, color: AppColors.primary),
            label: 'Verify',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history_rounded, color: AppColors.primary),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune_rounded, color: AppColors.primary),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
