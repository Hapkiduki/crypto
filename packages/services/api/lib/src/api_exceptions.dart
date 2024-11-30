sealed class AppException implements Exception {
  const AppException({required this.message, this.code});

  final String message;
  final String? code;
}

final class NetworkException extends AppException {
  NetworkException({required super.message, this.statusCode, super.code});

  final int? statusCode;

  factory NetworkException.fromStatusCode(int statusCode) {
    return switch (statusCode) {
      /// 4xx (Client Errors):
      /// 400 Bad Request: The request contains incorrect syntax.
      400 => NetworkException(
          message: 'Bad request',
          statusCode: statusCode,
          code: 'BAD_REQUEST',
        ),

      // 401 Unauthorized: Authentication required.
      401 => NetworkException(
          message: 'Unauthorized',
          statusCode: statusCode,
          code: 'UNAUTHORIZED',
        ),

      // 403 Forbidden: You do not have permission to access the resource.
      403 => NetworkException(
          message: 'Forbidden',
          statusCode: statusCode,
          code: 'FORBIDDEN',
        ),

      // 404 Not Found: The requested resource does not exist.
      404 => NetworkException(
          message: 'Not Found',
          statusCode: statusCode,
          code: 'NOT_FOUND',
        ),

      // 405 Method Not Allowed: The HTTP method used is not allowed for the resource.
      405 => NetworkException(
          message: 'Method Not Allowed',
          statusCode: statusCode,
          code: 'METHOD_NOT_ALLOWED',
        ),
      //422 Unprocessable Entity: The request is valid but the server cannot process it.
      422 => NetworkException(
          message: 'Unprocessable Entity',
          statusCode: statusCode,
          code: 'UNPROCESSABLE_ENTITY',
        ),

      ///5xx (Server Errors):
      ///500 Internal Server Error: An internal server error occurred.
      500 => NetworkException(
          message: 'Internal Server Error',
          statusCode: statusCode,
          code: 'SERVER_ERROR',
        ),

      //502 Bad Gateway: The server received an invalid response from an upstream
      // server.
      502 => NetworkException(
          message: 'Bad Gateway',
          statusCode: statusCode,
          code: 'BAD_GATEWAY',
        ),
      //503 Service Unavailable: The server is temporarily unavailable.
      503 => NetworkException(
          message: 'Service Unavailable',
          statusCode: statusCode,
          code: 'SERVICE_UNAVAILABLE',
        ),

      /// 504 Gateway Timeout: The upstream server did not respond in time.
      504 => NetworkException(
          message: 'Gateway Timeout',
          statusCode: statusCode,
          code: 'GATEWAY_TIMEOUT',
        ),
      _ => NetworkException(
          message: 'message',
          statusCode: statusCode,
          code: 'NETWORK_ERROR',
        ),
    };
  }
}
