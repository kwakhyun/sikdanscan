import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/api_constants.dart';

class ApiService {
  ApiService({Dio? dio}) : _dio = dio ?? Dio(_baseOptions) {
    if (dio == null) {
      _configureInterceptors();
    }
  }

  final Dio _dio;

  static final _baseOptions = BaseOptions(
    connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
    receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
    headers: {'Content-Type': 'application/json'},
  );

  void _configureInterceptors() {
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestHeader: false,
          requestBody: false,
          responseHeader: false,
          responseBody: false,
          logPrint: (obj) => debugPrint(obj.toString()),
        ),
      );
    }

    _dio.interceptors.add(RetryInterceptor(dio: _dio));

    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          final apiError = _handleError(error);
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: apiError,
              type: error.type,
              response: error.response,
            ),
          );
        },
      ),
    );
  }

  void close() {
    _dio.close(force: true);
  }

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String baseUrl,
    String path, {
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? headers,
  }) async {
    return _dio.get<T>(
      '$baseUrl$path',
      queryParameters: queryParams,
      options: Options(headers: headers),
    );
  }

  Future<Response<T>> post<T>(
    String baseUrl,
    String path, {
    dynamic data,
    Map<String, dynamic>? headers,
  }) async {
    return _dio.post<T>(
      '$baseUrl$path',
      data: data,
      options: Options(headers: headers),
    );
  }

  ApiError _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiError(
          message: '네트워크 연결 시간이 초과되었습니다. 다시 시도해주세요.',
          code: 'TIMEOUT',
        );
      case DioExceptionType.connectionError:
        return ApiError(message: '인터넷 연결을 확인해주세요.', code: 'NO_CONNECTION');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          return ApiError(
            message: 'API 인증에 실패했습니다. API 키를 확인해주세요.',
            code: 'UNAUTHORIZED',
          );
        }
        if (statusCode == 429) {
          return ApiError(
            message: '요청이 너무 많습니다. 잠시 후 다시 시도해주세요.',
            code: 'RATE_LIMIT',
          );
        }
        return ApiError(
          message: '서버 오류가 발생했습니다. (코드: $statusCode)',
          code: 'SERVER_ERROR',
        );
      default:
        return ApiError(message: '알 수 없는 오류가 발생했습니다.', code: 'UNKNOWN');
    }
  }
}

class RetryInterceptor extends Interceptor {
  final Dio dio;

  RetryInterceptor({required this.dio});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;

    if (statusCode == 429) {
      final responseBody = err.response?.data?.toString() ?? '';
      if (responseBody.contains('insufficient_quota')) {
        return handler.next(err);
      }
    }

    final shouldRetry =
        retryCount < ApiConstants.maxRetries &&
        (statusCode == 429 || (statusCode != null && statusCode >= 500));

    if (shouldRetry) {
      final delay = ApiConstants.retryDelayMs * (1 << retryCount);
      if (kDebugMode) {
        debugPrint(
          'API 재시도 ${retryCount + 1}/${ApiConstants.maxRetries} (${delay}ms 후)',
        );
      }
      await Future.delayed(Duration(milliseconds: delay));

      err.requestOptions.extra['retryCount'] = retryCount + 1;

      try {
        final response = await dio.fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }

    return handler.next(err);
  }
}

class ApiError {
  final String message;
  final String code;

  ApiError({required this.message, required this.code});

  @override
  String toString() => 'ApiError($code): $message';
}
