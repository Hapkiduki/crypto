import 'package:api/src/api_exceptions.dart';
import 'package:dio/dio.dart';

class MagicInterceptor extends Interceptor {
  MagicInterceptor(
    this.innerDio, {
    this.tokenRefreshFunction,
    this.errorHandlerFunction,
    this.isAuthenticated,
  });

  final Dio innerDio;

  final Future<List<String>?> Function()? tokenRefreshFunction;

  final void Function(String message)? errorHandlerFunction;

  final bool Function()? isAuthenticated;

  DateTime? lastRetryAttempt;

  bool shouldRetry() {
    final now = DateTime.now();
    if (lastRetryAttempt != null && now.difference(lastRetryAttempt!).inSeconds < 5) {
      return false;
    }
    lastRetryAttempt = now;
    return true;
  }

  Future<Response<dynamic>?> _retry(RequestOptions requestOptions) async {
    if (tokenRefreshFunction == null) {
      return null;
    }
    var refreshedTokens = await tokenRefreshFunction!();

    if (refreshedTokens == null || refreshedTokens.length < 2) {
      return null;
    }

    innerDio.options.headers['Authentication'] = refreshedTokens[0];
    innerDio.options.headers['Authorization'] = refreshedTokens[1];

    final options = Options(
      method: requestOptions.method,
      headers: innerDio.options.headers,
    );

    return innerDio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final hasToken = isAuthenticated != null && isAuthenticated!();
    final isTokenExpired = err.response?.statusCode == 401 && err.response?.data['message'] == 'Your token has expired. Please refresh it.';

    if (isTokenExpired && hasToken) {
      try {
        if (!shouldRetry()) {
          await Future<void>.delayed(const Duration(seconds: 3));
        }
        final refreshedResponse = await _retry(err.requestOptions);
        if (refreshedResponse != null) {
          return handler.resolve(refreshedResponse);
        } else {
          handler.reject(
            DioException(
              requestOptions: err.requestOptions,
              response: err.response,
              type: DioExceptionType.badResponse,
              error: NetworkException(
                message: 'Failed to refresh token',
                statusCode: err.response?.statusCode,
                code: 'TOKEN_REFRESH_FAILED',
              ),
            ),
          );
          return;
        }
      } catch (e) {
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            response: err.response,
            type: DioExceptionType.badResponse,
            error: NetworkException(
              message: 'Failed to refresh token',
              statusCode: err.response?.statusCode,
              code: 'TOKEN_REFRESH_FAILED',
            ),
          ),
        );
        return;
      }
    } else {
      final statusCode = err.response?.statusCode ?? 500;

      final errorMessage = err.response?.data['message']?.toString() ?? 'Unknown error';

      final networkException = NetworkException(
        message: errorMessage,
        statusCode: statusCode,
        code: 'NETWORK_ERROR',
      );

      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          type: DioExceptionType.badResponse,
          error: networkException,
        ),
      );
    }
  }
}
