import 'package:api/src/base_api.dart';
import 'package:api/src/dio_provider.dart';
import 'package:dio/dio.dart';

/// {@template api_service}
/// A base service class for interacting with specific API resources.
///
/// This class extends the [BaseApi] mixin to provide common functionality
/// such as HTTP methods and response handling. Each specific API service
/// should inherit from this class and define its own [resourcePath].
///
/// Example:
/// ```dart
/// class UserService extends ApiService {
///   @override
///   String get resourcePath => 'users';
/// }
/// ```
/// {@endtemplate}
abstract class ApiService with BaseApi {
  /// Creates an instance of [ApiService] with the given [Dio] instance.
  ApiService({
    Dio? dioInstance,
  }) : dio = dioInstance ?? DioProvider.dio;

  /// The path of the API resource.
  String get resourcePath;

  /// The Dio instance used for HTTP requests.
  @override
  final Dio dio;

  /// Builds the full endpoint URL for the given [path].
  String getUrl(String path) => '$resourcePath/$path';

  /// Fetches a list of items from the API.
  ///
  /// [queryParameters] - Optional query parameters to filter the results.
  /// [headers] - Optional headers for the request.
  /// Returns a list of items as dynamic objects.
  Future<List<dynamic>> fetchList({
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    return getApi<List<dynamic>>(
      getUrl(''),
      (data) => data as List<dynamic>,
      queryParameters: queryParameters,
      headers: headers,
    );
  }

  /// Fetches a single item by its [id].
  ///
  /// [id] - The identifier of the item to fetch.
  /// [headers] - Optional headers for the request.
  /// Returns the item as a dynamic object.
  Future<dynamic> fetchById({
    required String id,
    Map<String, String>? headers,
  }) async {
    return getApi<dynamic>(
      getUrl(id),
      (data) => data,
      headers: headers,
    );
  }

  /// Creates a new item on the API.
  ///
  /// [body] - The data to send in the request body.
  /// [headers] - Optional headers for the request.
  /// Returns the created item as a dynamic object.
  Future<dynamic> create({
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    return postApi<dynamic>(
      getUrl(''),
      (data) => data,
      sendBody: body,
      headers: headers,
    );
  }

  /// Updates an existing item by its [id].
  ///
  /// [id] - The identifier of the item to update.
  /// [body] - The data to send in the request body.
  /// [headers] - Optional headers for the request.
  /// Returns the updated item as a dynamic object.
  Future<dynamic> update({
    required String id,
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    return patchApi<dynamic>(
      getUrl(id),
      (data) => data,
      sendBody: body,
      headers: headers,
    );
  }
}
