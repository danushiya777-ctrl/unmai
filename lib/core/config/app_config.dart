import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConfig {
  /// Default demo data flag: FALSE for real-world live verification by default
  static const bool useDemoData = false;

  /// Default API endpoint for local development
  static String defaultBaseUrl() {
    if (kIsWeb) return 'http://127.0.0.1:8000';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://127.0.0.1:8000';
  }

  /// Request timeout durations
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 35);
}
