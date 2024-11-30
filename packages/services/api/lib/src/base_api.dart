import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:api/src/api_exceptions.dart';
import 'package:dio/dio.dart';

/// {@template base_api}
/// A base class for interacting with APIs using Dio.
///
/// This class provides common methods for making HTTP requests,
/// handling responses, and processing JSON data efficiently with isolates.
///
/// It simplifies the implementation of GET, POST, and PATCH requests,
/// while managing headers and query parameters seamlessly.
/// {@endtemplate}
mixin BaseApi {
  /// The Dio instance used for making HTTP requests.
  ///
  /// This should be initialized in the implementing class.
  Dio get dio;

  /// The default timeout for API requests.
  ///
  /// Override this to customize the timeout duration.
  Duration get timeout => const Duration(seconds: 30);

  /// The default headers included in every request.
  ///
  /// These can be overridden or extended using [getHeaders].
  Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json; charset=utf-8',
      };

  /// Combines default headers with custom headers.
  ///
  /// [headers] - Optional additional headers to include in the request.
  /// Returns a merged map of default and custom headers.
  Map<String, String> getHeaders([Map<String, String>? headers]) {
    return {
      ...defaultHeaders,
      if (headers != null) ...headers,
    };
  }

  /// {@template call_api}
  /// Makes an API call and handles its response.
  ///
  /// [caller] - A future representing the API request.
  /// [mapperFunction] - A function to map the response data to the desired type.
  /// [callBack] - An optional callback invoked with the response status code.
  ///
  /// Returns the mapped response data.
  /// Throws [NetworkException] for network-related errors or timeouts.
  /// {@endtemplate}
  Future<T> callApi<T>(
    Future<Response<T>> caller,
    T Function(dynamic data) mapperFunction, {
    Function? callBack,
  }) async {
    try {
      final response = await caller;
      if (callBack != null) {
        await callBack(response.statusCode);
      }
      return await manageResponse(response, mapperFunction);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode ?? 500;
      throw NetworkException.fromStatusCode(statusCode);
    } on SocketException {
      throw NetworkException(
        message: 'No internet connection',
        code: 'NO_INTERNET',
      );
    } on TimeoutException {
      throw NetworkException(
        message: 'Request timed out',
        code: 'TIMEOUT',
      );
    }
  }

  /// {@template get_body_async}
  /// Parses the response body asynchronously using isolates for efficient processing.
  ///
  /// [body] - The response body to parse.
  /// Returns the parsed body as a dynamic object.
  /// {@endtemplate}
  Future<dynamic> getBodyAsync(dynamic body) async {
    String bodyString;

    if (body is String) {
      bodyString = body;
    } else {
      bodyString = utf8.decode(body as List<int>);
    }

    return processJson(
      body: bodyString,
      processor: (Map<String, dynamic> message) {
        final sendPort = message['sendPort'] as SendPort;
        final body = message['body'] as String;

        try {
          sendPort.send(json.decode(body));
        } catch (_) {
          sendPort.send(body);
        }
      },
    );
  }

  /// {@template manage_response}
  /// Handles the API response and applies the mapping function to the data.
  ///
  /// [response] - The Dio response object.
  /// [mapperFunction] - A function to map the response data to the desired type.
  ///
  /// Returns the mapped response data.
  /// Throws [NetworkException] for unexpected status codes or parsing errors.
  /// {@endtemplate}
  Future<T> manageResponse<T>(
    Response<T> response,
    T Function(dynamic data) mapperFunction,
  ) async {
    final statusCode = response.statusCode ?? 500;

    if (statusCode >= 200 && statusCode < 300) {
      final dynamic body = await getBodyAsync(response.data);
      final result = await processJson(
        body: jsonEncode(body),
        processor: (Map<String, dynamic> message) {
          final sendPort = message['sendPort'] as SendPort;
          final body = message['body'];

          try {
            final result = mapperFunction(body);
            sendPort.send(result);
          } catch (_) {
            sendPort.send(null);
          }
        },
      );
      return result as T;
    } else {
      throw NetworkException.fromStatusCode(statusCode);
    }
  }

  /// {@template process_json}
  /// Processes JSON data in a separate isolate.
  ///
  /// [body] - The JSON string to parse.
  /// [processor] - A function to process the JSON data in the isolate.
  ///
  /// Returns the processed result.
  /// {@endtemplate}
  Future<dynamic> processJson({
    required String? body,
    required void Function(Map<String, Object?>) processor,
  }) async {
    final receivePort = ReceivePort();
    Isolate? isolate;

    try {
      isolate = await Isolate.spawn(
        processor,
        <String, Object?>{
          'body': body,
          'sendPort': receivePort.sendPort,
        },
      );

      return await receivePort.first;
    } finally {
      isolate?.kill();
    }
  }

  /// {@template get_api}
  /// Makes a GET request to the specified URL.
  ///
  /// [url] - The endpoint for the request.
  /// [mapperFunction] - A function to map the response data to the desired type.
  /// Optional parameters: [headers], [queryParameters], [options].
  ///
  /// Returns the mapped response data.
  /// {@endtemplate}
  Future<T> getApi<T>(
    String url,
    T Function(dynamic data) mapperFunction, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    headers = getHeaders(headers);
    final caller = dio
        .get<T>(
          url,
          queryParameters: queryParameters,
          options: options ?? Options(headers: headers),
        )
        .timeout(timeout);
    return callApi(caller, mapperFunction);
  }

  /// {@template post_api}
  /// Makes a POST request to the specified URL.
  ///
  /// [url] - The endpoint for the request.
  /// [mapperFunction] - A function to map the response data to the desired type.
  /// Optional parameters: [headers], [queryParameters], [options], [sendBody].
  ///
  /// Returns the mapped response data.
  /// {@endtemplate}
  Future<T> postApi<T>(
    String url,
    T Function(dynamic value) mapperFunction, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Options? options,
    Map<String, dynamic>? sendBody,
  }) async {
    headers = getHeaders(headers ?? {});
    final caller = dio
        .post<T>(
          url,
          queryParameters: queryParameters,
          options: options ??
              Options(
                headers: {
                  'Content-Type': 'application/json',
                  ...headers,
                },
              ),
          data: jsonEncode(sendBody),
        )
        .timeout(timeout);
    return callApi(caller, mapperFunction);
  }

  /// {@template patch_api}
  /// Makes a PATCH request to the specified URL.
  ///
  /// [url] - The endpoint for the request.
  /// [mapperFunction] - A function to map the response data to the desired type.
  /// Optional parameters: [headers], [queryParameters], [options], [sendBody].
  ///
  /// Returns the mapped response data.
  /// {@endtemplate}
  Future<T> patchApi<T>(
    String url,
    T Function(dynamic value) mapperFunction, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Options? options,
    Map<String, dynamic>? sendBody,
  }) async {
    headers = getHeaders(headers ?? {});
    final caller = dio
        .patch<T>(
          url,
          queryParameters: queryParameters,
          options: options ??
              Options(
                headers: {
                  'Content-Type': 'application/json',
                  ...headers,
                },
              ),
          data: jsonEncode(sendBody),
        )
        .timeout(timeout);
    return callApi(caller, mapperFunction);
  }
}
