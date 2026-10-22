import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class SharedContent {
  final String? text;
  final String? filePath;
  final String? fileType; // 'image', 'video', 'file'

  SharedContent({this.text, this.filePath, this.fileType});
}

class ShareIntentService {
  static StreamSubscription? _intentSub;

  /// Initialize listener for shared content while app is open or opened from background
  static void listen(void Function(SharedContent content) onShared) {
    if (kIsWeb) return;

    try {
      _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen(
        (List<SharedMediaFile> value) {
          if (value.isNotEmpty) {
            final first = value.first;
            _handleSharedFile(first, onShared);
          }
        },
        onError: (err) {
          debugPrint('Error listening to share intent: $err');
        },
      );

      // Handle intent that caused the app to open initially
      ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> value) {
        if (value.isNotEmpty) {
          final first = value.first;
          _handleSharedFile(first, onShared);
          ReceiveSharingIntent.instance.reset();
        }
      });
    } catch (e) {
      debugPrint('Share intent initialization failed: $e');
    }
  }

  static void _handleSharedFile(
    SharedMediaFile file,
    void Function(SharedContent content) onShared,
  ) {
    final path = file.path;
    final type = file.type;

    if (type == SharedMediaType.text || type == SharedMediaType.url) {
      onShared(SharedContent(text: path));
    } else if (type == SharedMediaType.image) {
      onShared(SharedContent(filePath: path, fileType: 'image'));
    } else if (type == SharedMediaType.video) {
      onShared(SharedContent(filePath: path, fileType: 'video'));
    } else {
      // Fallback detection from extension
      final ext = path.split('.').last.toLowerCase();
      if (['jpg', 'jpeg', 'png', 'webp'].contains(ext)) {
        onShared(SharedContent(filePath: path, fileType: 'image'));
      } else if (['mp4', 'mov', 'webm'].contains(ext)) {
        onShared(SharedContent(filePath: path, fileType: 'video'));
      } else {
        onShared(SharedContent(text: path));
      }
    }
  }

  static void dispose() {
    _intentSub?.cancel();
  }
}
