import 'package:api/src/dio_provider.dart';
import 'package:dio/dio.dart';

class TokenInterceptor extends Interceptor {
  const TokenInterceptor(this.tokenProvider, this.isAuthenticated);

  final TokenProvider? tokenProvider;
  final bool Function()? isAuthenticated;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (isAuthenticated?.call() ?? false) {
      final token = await tokenProvider!();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    return handler.next(options);
  }
}
