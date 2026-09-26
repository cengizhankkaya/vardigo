import 'package:dio/dio.dart';

import '../error/exceptions/api_exception.dart';
import 'api_config.dart';

/// Talks to the backend and unwraps its `{ ok, data | error }` envelope.
/// Every failure becomes an [ApiException].
class ApiClient {
  ApiClient(ApiConfig config, {String? Function()? token, Dio? dio})
    : _token = token ?? (() => null),
      _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 10),
              sendTimeout: const Duration(seconds: 10),
            ),
          ) {
    _dio.options.baseUrl = config.baseUrl;
  }

  final Dio _dio;
  final String? Function() _token;

  Future<Object?> get(String path, {Map<String, Object?>? query}) => _send(
    () => _dio.get<Object?>(path, queryParameters: query, options: _options()),
  );

  Future<Object?> post(String path, {Object? body}) =>
      _send(() => _dio.post<Object?>(path, data: body, options: _options()));

  Options _options() {
    final token = _token();
    return Options(
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    );
  }

  Future<Object?> _send(Future<Response<Object?>> Function() request) async {
    try {
      return _unwrap((await request()).data, null);
    } on DioException catch (error) {
      throw _fromDio(error);
    }
  }

  static Object? _unwrap(Object? body, int? statusCode) {
    if (body is Map && body['ok'] == true) return body['data'];
    throw _errorFrom(body, statusCode);
  }

  /// Reads `{ ok: false, error: { code, message } }`; anything else is a bad response.
  static ApiException _errorFrom(Object? body, int? statusCode) {
    final error = body is Map ? body['error'] : null;
    if (error is Map && error['code'] is String) {
      return ApiException(
        code: error['code'] as String,
        message: '${error['message'] ?? ''}',
        statusCode: statusCode,
      );
    }
    return ApiException(
      code: ApiException.badResponse,
      message: '',
      statusCode: statusCode,
    );
  }

  static ApiException _fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const ApiException(code: ApiException.timeout, message: '');
      case DioExceptionType.badResponse:
        return _errorFrom(error.response?.data, error.response?.statusCode);
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
        return const ApiException(code: ApiException.network, message: '');
    }
  }
}
