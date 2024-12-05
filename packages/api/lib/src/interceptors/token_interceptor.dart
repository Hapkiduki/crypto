import 'package:dio/dio.dart';

typedef AuthenticationTokenProvider = Future<String?> Function();
typedef AuthorizationTokenProvider = Future<String?> Function();

class TokenInterceptor extends Interceptor {
  const TokenInterceptor({
    required this.authenticationTokenProvider,
    required this.authorizationTokenProvider,
  });

  final AuthenticationTokenProvider authenticationTokenProvider;
  final AuthorizationTokenProvider authorizationTokenProvider;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final authToken = await authenticationTokenProvider();
    final authorizationToken = await authorizationTokenProvider();

    if (authToken != null) {
      options.headers['Authentication'] = authToken;
    }
    if (authorizationToken != null) {
      options.headers['Authorization'] = authorizationToken;
    }

    return handler.next(options);
  }
}
