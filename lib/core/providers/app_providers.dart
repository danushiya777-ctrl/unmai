import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_service.dart';
import '../config/app_config.dart';
import '../models/investigation.dart';
import '../storage/history_storage.dart';

/// Language state notifier & provider
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() => const Locale('en');

  void setLocale(Locale newLocale) {
    state = newLocale;
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(() {
  return LocaleNotifier();
});

/// Demo data toggle notifier & provider (default: FALSE for real verification)
class DemoModeNotifier extends Notifier<bool> {
  @override
  bool build() => AppConfig.useDemoData;

  void setDemoMode(bool isDemo) {
    state = isDemo;
  }
}

final demoModeProvider = NotifierProvider<DemoModeNotifier, bool>(() {
  return DemoModeNotifier();
});

/// Server URL notifier & provider
class ServerUrlNotifier extends Notifier<String> {
  @override
  String build() => AppConfig.defaultBaseUrl();

  void setUrl(String newUrl) {
    state = newUrl.trim().isNotEmpty ? newUrl.trim() : AppConfig.defaultBaseUrl();
  }

  void reset() {
    state = AppConfig.defaultBaseUrl();
  }
}

final serverUrlProvider = NotifierProvider<ServerUrlNotifier, String>(() {
  return ServerUrlNotifier();
});

/// API Service Provider
final apiServiceProvider = Provider<ApiService>((ref) {
  final url = ref.watch(serverUrlProvider);
  return ApiService(baseUrl: url);
});

/// History Notifier & Provider
class HistoryNotifier extends Notifier<List<Investigation>> {
  @override
  List<Investigation> build() {
    return HistoryStorage.getAll();
  }

  void load() {
    state = HistoryStorage.getAll();
  }

  Future<void> add(Investigation item) async {
    await HistoryStorage.save(item);
    load();
  }

  Future<void> delete(String id) async {
    await HistoryStorage.delete(id);
    load();
  }

  Future<void> clearAll() async {
    await HistoryStorage.clear();
    state = [];
  }
}

final historyProvider =
    NotifierProvider<HistoryNotifier, List<Investigation>>(() {
  return HistoryNotifier();
});

/// Verify process state
class VerifyState {
  final bool isLoading;
  final int step; // 0: Reading, 1: Searching, 2: Checking media, 3: Result
  final Investigation? result;
  final String? errorMessage;

  const VerifyState({
    this.isLoading = false,
    this.step = 0,
    this.result,
    this.errorMessage,
  });

  VerifyState copyWith({
    bool? isLoading,
    int? step,
    Investigation? result,
    String? errorMessage,
  }) {
    return VerifyState(
      isLoading: isLoading ?? this.isLoading,
      step: step ?? this.step,
      result: result ?? this.result,
      errorMessage: errorMessage,
    );
  }
}

class VerifyNotifier extends Notifier<VerifyState> {
  @override
  VerifyState build() => const VerifyState();

  Future<Investigation?> verify({
    String? text,
    String? url,
    String? filePath,
    String? fileType,
  }) async {
    state = const VerifyState(isLoading: true, step: 0);

    // Step 0: Reading
    await Future.delayed(const Duration(milliseconds: 300));
    state = state.copyWith(step: 1);

    // Step 1: Searching sources
    await Future.delayed(const Duration(milliseconds: 400));
    state = state.copyWith(step: (filePath != null) ? 2 : 3);

    // Step 2: Checking media if file is present
    if (filePath != null) {
      await Future.delayed(const Duration(milliseconds: 400));
      state = state.copyWith(step: 3);
    }

    try {
      final isDemo = ref.read(demoModeProvider);
      final currentLocale = ref.read(localeProvider).languageCode;
      final service = ref.read(apiServiceProvider);

      final investigation = await service.verify(
        text: text,
        url: url,
        filePath: filePath,
        fileType: fileType,
        language: currentLocale,
        forceDemo: isDemo,
      );

      // Auto-save real results to local history
      await ref.read(historyProvider.notifier).add(investigation);

      state = VerifyState(
        isLoading: false,
        step: 3,
        result: investigation,
      );
      return investigation;
    } on SocketException catch (_) {
      state = const VerifyState(
        isLoading: false,
        errorMessage:
            'Could not connect to the verification server. If using a physical phone, set your computer IP (e.g. http://172.18.229.90:8000) or http://127.0.0.1:8000 in Settings.',
      );
      return null;
    } on TimeoutException catch (_) {
      state = const VerifyState(
        isLoading: false,
        errorMessage:
            'Verification request timed out. If running on a physical phone, set your PC IP (e.g. http://172.18.229.90:8000) or http://127.0.0.1:8000 in Settings.',
      );
      return null;
    } catch (e) {
      state = const VerifyState(
        isLoading: false,
        errorMessage:
            'Could not complete verification. Please check your connection or Server URL in Settings and try again.',
      );
      return null;
    }
  }

  void reset() {
    state = const VerifyState();
  }
}

final verifyProvider = NotifierProvider<VerifyNotifier, VerifyState>(() {
  return VerifyNotifier();
});
