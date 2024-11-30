import 'package:api/src/interceptors/interceptors.dart';
import 'package:dio/dio.dart';

typedef TokenProvider = Future<String?> Function();

class DioProvider {
  static Dio? _dio;

  static String? _token;
  static bool Function()? _isAuthenticated;

  static void initialize({
    required String baseUrl,
    TokenProvider? tokenProvider,
    Future<List<String>?> Function()? tokenRefreshFunction,
    dynamic Function(String message)? errorHandlerFunction,
    bool Function()? isAuthenticated,
  }) {
    if (_dio != null) {
      return;
    }

    _isAuthenticated = isAuthenticated;

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    _dio!.interceptors.add(LoggingInterceptor());
    _dio!.interceptors.add(TokenInterceptor(() async => _token, _isAuthenticated));
    _dio!.interceptors.add(CacheInterceptor());
    _dio!.interceptors.add(MagicInterceptor(
      _dio!,
      tokenRefreshFunction: tokenRefreshFunction,
      errorHandlerFunction: errorHandlerFunction,
      isAuthenticated: isAuthenticated,
    ));
  }

  static Dio get dio {
    if (_dio == null) {
      throw Exception('DioProvider has not been initialized. Call DioProvider.initialize() before using it.');
    }
    return _dio!;
  }

  static void updateToken(String token) {
    _token = token;

    _dio!.interceptors.removeWhere(
      (interceptor) => interceptor is TokenInterceptor,
    );
    _dio!.interceptors.add(
      TokenInterceptor(() async => _token, _isAuthenticated),
    );
  }

  static bool isAuthenticated() {
    return _isAuthenticated?.call() ?? false;
  }
}
