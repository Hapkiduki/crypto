import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';

/// Interceptor to log HTTP requests and responses.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logRequest(options);
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    _logResponse(response);
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logError(err);
    super.onError(err, handler);
  }

  void _logRequest(RequestOptions options) {
    log('*** HTTP REQUEST ***');
    log('URI: ${options.uri}');
    log('Method: ${options.method}');
    if (options.headers.isNotEmpty) {
      log('Headers: ${_formatJson(options.headers)}');
    }
    if (options.queryParameters.isNotEmpty) {
      log('Query Parameters: ${_formatJson(options.queryParameters)}');
    }
    if (options.data != null) {
      log('Body: ${_formatJson(options.data)}');
    }
    log('********************');
  }

  void _logResponse(Response<dynamic> response) {
    log('*** HTTP RESPONSE ***');
    log('URI: ${response.requestOptions.uri}');
    log('Status Code: ${response.statusCode}');
    if (response.headers.map.isNotEmpty) {
      log('Headers: ${_formatJson(response.headers.map)}');
    }
    if (response.data != null) {
      log('Body: ${_formatJson(response.data)}');
    }
    log('*********************');
  }

  void _logError(DioException err) {
    log('*** HTTP ERROR ***');
    log('URI: ${err.requestOptions.uri}');
    log('Error: ${err.error}');
    if (err.response != null) {
      log('Status Code: ${err.response?.statusCode}');
      if (err.response?.data != null) {
        log('Error Body: ${_formatJson(err.response?.data)}');
      }
    }
    log('*******************');
  }

  String _formatJson(dynamic data) {
    try {
      if (data is String) {
        final decoded = jsonDecode(data);
        return const JsonEncoder.withIndent('  ').convert(decoded);
      } else if (data is Map || data is List) {
        return const JsonEncoder.withIndent('  ').convert(data);
      } else {
        return data.toString();
      }
    } catch (_) {
      return data.toString();
    }
  }
}
