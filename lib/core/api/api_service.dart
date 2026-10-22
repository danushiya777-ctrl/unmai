import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/demo_data.dart';
import '../models/investigation.dart';

class ApiService {
  final Dio _dio;
  final String baseUrl;

  ApiService({
    String? baseUrl,
    Dio? dio,
  })  : baseUrl = baseUrl ?? AppConfig.defaultBaseUrl(),
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ?? AppConfig.defaultBaseUrl(),
                connectTimeout: AppConfig.connectTimeout,
                receiveTimeout: AppConfig.receiveTimeout,
                headers: {
                  'Accept': 'application/json',
                },
              ),
            );

  /// Verify text, URL, image, or video against live backend
  Future<Investigation> verify({
    String? text,
    String? url,
    String? filePath,
    String? fileType,
    String language = 'en',
    bool forceDemo = false,
  }) async {
    // Rehearsal demo mode if explicitly toggled on in settings
    if (forceDemo) {
      await Future.delayed(const Duration(milliseconds: 1400));
      if (fileType == 'image' || (text != null && text.contains('train'))) {
        return DemoData.falsePhotoReport;
      }
      return DemoData.trueGovReport;
    }

    try {
      Response response;

      // Multipart upload for images or videos
      if (filePath != null && filePath.isNotEmpty) {
        final fileName = filePath.split(Platform.pathSeparator).last;
        final formData = FormData.fromMap({
          'language': language,
          if (text != null && text.isNotEmpty) 'text': text,
          if (url != null && url.isNotEmpty) 'url': url,
          'file': await MultipartFile.fromFile(filePath, filename: fileName),
        });

        response = await _dio.post(
          '/verify',
          data: formData,
        );
      } else {
        // JSON payload for text claims and news links
        response = await _dio.post(
          '/verify',
          data: {
            'text': text ?? '',
            'url': url ?? '',
            'language': language,
          },
          options: Options(contentType: Headers.jsonContentType),
        );
      }

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final Map<String, dynamic> data =
            response.data is Map<String, dynamic>
                ? response.data as Map<String, dynamic>
                : Map<String, dynamic>.from(response.data as Map);
        return Investigation.fromJson(data);
      } else {
        throw HttpException(
            'Server responded with HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw TimeoutException(
            'Verification request timed out. Please try again.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw SocketException(
            'Could not connect to $baseUrl. Please verify the backend is running or update the URL in Settings.');
      } else if (e.response != null) {
        final detail = e.response?.data is Map
            ? e.response?.data['detail']
            : null;
        throw HttpException(
            detail ?? 'Server error (HTTP ${e.response?.statusCode})');
      } else {
        throw HttpException(
            e.message ?? 'An unexpected network error occurred.');
      }
    }
  }

  /// Health check call
  Future<bool> checkHealth() async {
    try {
      final res = await _dio.get('/health');
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
