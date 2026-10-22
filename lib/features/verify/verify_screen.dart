import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/progress_steps.dart';
import '../../core/widgets/state_views.dart';
import '../result/result_screen.dart';

class VerifyScreen extends ConsumerStatefulWidget {
  final String? initialText;
  final String? initialFilePath;
  final String? initialFileType;

  const VerifyScreen({
    super.key,
    this.initialText,
    this.initialFilePath,
    this.initialFileType,
  });

  @override
  ConsumerState<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends ConsumerState<VerifyScreen> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String? _selectedFilePath;
  String? _selectedFileType; // 'image' or 'video'
  String? _validationError;

  @override
  void initState() {
    super.initState();
    if (widget.initialText != null && widget.initialText!.isNotEmpty) {
      _textController.text = widget.initialText!;
    }
    if (widget.initialFilePath != null) {
      _selectedFilePath = widget.initialFilePath;
      _selectedFileType = widget.initialFileType ?? 'image';
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.trim().isNotEmpty) {
      setState(() {
        _textController.text = data.text!.trim();
        _validationError = null;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Clipboard is empty.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final xFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2400,
        maxHeight: 2400,
      );
      if (xFile != null) {
        _validateAndSetFile(xFile.path, 'image');
      }
    } catch (_) {
      setState(() {
        _validationError = 'Could not select image. Please try again.';
      });
    }
  }

  Future<void> _pickVideo() async {
    try {
      final xFile = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );
      if (xFile != null) {
        _validateAndSetFile(xFile.path, 'video');
      }
    } catch (_) {
      setState(() {
        _validationError = 'Could not select video. Please try again.';
      });
    }
  }

  Future<void> _validateAndSetFile(String path, String type) async {
    final file = File(path);
    if (!await file.exists()) {
      setState(() {
        _validationError = 'File could not be found.';
      });
      return;
    }

    // Check size limit: 50MB
    final sizeInBytes = await file.length();
    if (sizeInBytes > 50 * 1024 * 1024) {
      setState(() {
        _validationError =
            'File exceeds 50MB limit. Please choose a smaller file.';
      });
      return;
    }

    // Check extension
    final ext = path.split('.').last.toLowerCase();
    if (type == 'image' && !['jpg', 'jpeg', 'png', 'webp'].contains(ext)) {
      setState(() {
        _validationError =
            'Unsupported image format. Please select JPG, PNG, or WEBP.';
      });
      return;
    }

    if (type == 'video' && !['mp4', 'mov', 'webm'].contains(ext)) {
      setState(() {
        _validationError =
            'Unsupported video format. Please select MP4 or WEBM.';
      });
      return;
    }

    setState(() {
      _selectedFilePath = path;
      _selectedFileType = type;
      _validationError = null;
    });
  }

  void _removeFile() {
    setState(() {
      _selectedFilePath = null;
      _selectedFileType = null;
      _validationError = null;
    });
  }

  Future<void> _handleVerify() async {
    final rawText = _textController.text.trim();
    final hasFile = _selectedFilePath != null && _selectedFilePath!.isNotEmpty;

    if (rawText.isEmpty && !hasFile) {
      setState(() {
        _validationError =
            'Please paste a message, enter a web link, or select a photo/video.';
      });
      return;
    }

    // If it looks like a URL, validate format
    String? validUrl;
    if (rawText.startsWith('http://') || rawText.startsWith('https://')) {
      final uri = Uri.tryParse(rawText);
      if (uri == null || !uri.hasAuthority) {
        setState(() {
          _validationError =
              'Please enter a complete and valid URL (e.g., https://example.com).';
        });
        return;
      }
      validUrl = rawText;
    }

    setState(() {
      _validationError = null;
    });

    final investigation = await ref.read(verifyProvider.notifier).verify(
          text: validUrl == null ? rawText : null,
          url: validUrl,
          filePath: _selectedFilePath,
          fileType: _selectedFileType,
        );

    if (investigation != null && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ResultScreen(investigation: investigation),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final verifyState = ref.watch(verifyProvider);
    final isDemo = ref.watch(demoModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const AppLogo(size: 32),
            const SizedBox(width: 10),
            const Text('Unmai'),
            if (isDemo) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Demo Mode',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Friendly headline (no AI buzzwords!)
              const Text(
                'Check before you share.',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Verify WhatsApp forwards, screenshots, images, videos, and news links in simple language.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // If currently verifying, show progress steps
              if (verifyState.isLoading) ...[
                ProgressSteps(currentStep: verifyState.step),
                const SizedBox(height: 24),
              ] else ...[
                // Main text input card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _textController,
                          maxLines: 5,
                          minLines: 3,
                          decoration: const InputDecoration(
                            hintText:
                                'Paste suspicious forward, message, claim, or news link here...',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                        const Divider(height: 20),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: _pasteFromClipboard,
                              icon: const Icon(Icons.paste_rounded, size: 16),
                              label: const Text('Paste from clipboard'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                textStyle: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (_textController.text.isNotEmpty)
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _textController.clear();
                                    _validationError = null;
                                  });
                                },
                                icon: const Icon(Icons.clear_rounded, size: 20),
                                tooltip: 'Clear text',
                                color: AppColors.textMuted,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Attached media preview if present
                if (_selectedFilePath != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _selectedFileType == 'video'
                                ? Icons.videocam_rounded
                                : Icons.image_rounded,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedFilePath!.split(Platform.pathSeparator).last,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _selectedFileType == 'video'
                                    ? 'Attached video'
                                    : 'Attached photo',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _removeFile,
                          icon: const Icon(Icons.close_rounded, size: 20),
                          color: AppColors.falseRed,
                          tooltip: 'Remove',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Media picker row
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.add_photo_alternate_outlined,
                            size: 18),
                        label: const Text('Add Photo'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickVideo,
                        icon: const Icon(Icons.video_library_outlined, size: 18),
                        label: const Text('Add Video'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Validation / Error banner
                if (_validationError != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.falseRedLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.falseRedBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 18,
                          color: AppColors.falseRed,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _validationError!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.falseRed,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (verifyState.errorMessage != null) ...[
                  ErrorState(
                    message: verifyState.errorMessage!,
                    onRetry: _handleVerify,
                  ),
                  const SizedBox(height: 16),
                ],

                // Large "Verify now" action button
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _handleVerify,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shield_rounded, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Verify now',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Quick Demo Rehearsal Links
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.lightbulb_outline_rounded,
                              size: 18, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text(
                            'Quick Rehearsal Examples',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _textController.text =
                                'Breaking: Terrible explosion reported at the city central train station just minutes ago! Share immediately.';
                            _selectedFilePath = 'assets/images/demo_fire.jpg';
                            _selectedFileType = 'image';
                            _validationError = null;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Icon(Icons.arrow_forward_ios_rounded,
                                  size: 12, color: AppColors.falseRed),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Example 1: Recycled disaster photo (False)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 12),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _textController.text =
                                'Health department announces free nationwide HPV vaccination campaign for adolescent girls aged 9 to 14 at public clinics.';
                            _selectedFilePath = null;
                            _selectedFileType = null;
                            _validationError = null;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Icon(Icons.arrow_forward_ios_rounded,
                                  size: 12, color: AppColors.trueGreen),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Example 2: Official health announcement (True)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
