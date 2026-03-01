import 'package:dio/dio.dart';
import 'api_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ApiResponse — wraps the standard backend envelope: { success, message, data }
// Also handles flat responses like: { success, sid, country, ... }
// ─────────────────────────────────────────────────────────────────────────────
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  const ApiResponse({required this.success, required this.message, this.data});
}

// ─────────────────────────────────────────────────────────────────────────────
// ApiService — central Dio-based HTTP helper.
//
// Responsibilities:
//  1. Reads base URL from ApiConfig.baseUrl — NEVER from feature code.
//  2. Interceptor attaches ngrok bypass header + JSON Content-Type on every
//     request automatically.
//  3. Applies configurable timeouts.
//  4. Decodes the response envelope (supports both nested and flat shapes).
//  5. Returns ApiResponse so callers only deal with structured data.
//
// Backend response shapes handled:
//  A) Standard envelope: { "success": true, "message": "...", "data": { ... } }
//     → data = json['data']
//  B) Flat response (IVR, Emergency): { "success": true, "sid": "...", ... }
//     → data = entire json map (so view models can read data['sid'], etc.)
//  C) Flat response (Passport scan):  { "country": "India", "confidence": 0.8 }
//     → treated as success=true, data = entire json map
// ─────────────────────────────────────────────────────────────────────────────
class ApiService {
  static final Dio _dio = _buildDio();

  static Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 90),
        sendTimeout: const Duration(seconds: 30),
        responseType: ResponseType.json,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      ),
    );

    return dio;
  }

  // ── POST ─────────────────────────────────────────────────────────────────────
  static Future<ApiResponse<Map<String, dynamic>>> post(
    String path,
    Map<String, dynamic> body, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: body,
        options: Options(receiveTimeout: timeout, sendTimeout: timeout),
      );
      return _decode(response.data, response.statusCode ?? 500);
    } on DioException catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: _friendlyDioError(e),
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Unexpected error: ${e.toString()}',
      );
    }
  }

  // ── GET ──────────────────────────────────────────────────────────────────────
  static Future<ApiResponse<Map<String, dynamic>>> get(
    String path, {
    Duration timeout = const Duration(seconds: 15),
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        options: Options(receiveTimeout: timeout),
      );
      return _decode(response.data, response.statusCode ?? 500);
    } on DioException catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: _friendlyDioError(e),
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Unexpected error: ${e.toString()}',
      );
    }
  }

  // ── POST multipart (for file uploads, e.g. passport scan) ───────────────────
  static Future<ApiResponse<Map<String, dynamic>>> postMultipart(
    String path,
    String fieldName,
    List<int> fileBytes,
    String fileName, {
    Duration timeout = const Duration(seconds: 60),
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: MultipartFile.fromBytes(fileBytes, filename: fileName),
      });

      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          receiveTimeout: timeout,
          sendTimeout: timeout,
          headers: {
            'ngrok-skip-browser-warning': 'true',
          },
        ),
      );
      return _decode(response.data, response.statusCode ?? 500);
    } on DioException catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: _friendlyDioError(e),
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Unexpected error: ${e.toString()}',
      );
    }
  }

  // ── Response decoder ──────────────────────────────────────────────────────────
  // Handles three backend response shapes:
  //   A) { success, message, data: { ... } }  — standard envelope
  //   B) { success, message, sid, ... }        — flat (IVR / Emergency)
  //   C) { country, confidence, ... }          — flat no-envelope (Passport scan)
  static ApiResponse<Map<String, dynamic>> _decode(
    dynamic responseData,
    int statusCode,
  ) {
    try {
      final json = responseData as Map<String, dynamic>;

      // Determine success
      final bool success;
      if (json.containsKey('success')) {
        success = json['success'] as bool? ?? false;
      } else {
        // No 'success' key (e.g. raw passport scan response) — treat as
        // success when HTTP 200, error otherwise
        success = statusCode >= 200 && statusCode < 300;
      }

      // Determine message
      final message =
          json['message'] as String? ??
          json['error'] as String? ??
          (success ? 'OK' : 'Unknown error');

      // Determine data payload:
      //   A) Prefer the nested 'data' key when present
      //   B) Otherwise use the entire json as the data map (flat response)
      final Map<String, dynamic> data =
          (json['data'] as Map<String, dynamic>?) ?? json;

      return ApiResponse(success: success, message: message, data: data);
    } catch (_) {
      return ApiResponse(
        success: false,
        message: 'Could not parse server response (HTTP $statusCode)',
      );
    }
  }

  // ── Dio Error humaniser ───────────────────────────────────────────────────────
  static String _friendlyDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Request timed out. Please check your connection.';

      case DioExceptionType.connectionError:
        return 'Cannot reach the server. Check your internet connection.';

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        if (statusCode == 429) {
          return 'Too many requests. Please wait a moment and try again.';
        }
        if (statusCode == 400) {
          final data = e.response?.data;
          if (data is Map) {
            return data['message'] as String? ??
                data['error'] as String? ??
                'Bad request. Please check your inputs.';
          }
          return 'Bad request. Please check your inputs.';
        }
        if (statusCode == 422) {
          return 'Could not process the image. Please try a clearer photo.';
        }
        return 'Server error (HTTP $statusCode). Please try again.';

      case DioExceptionType.cancel:
        return 'Request was cancelled.';

      default:
        return 'Network error. Please try again.';
    }
  }
}
