import 'package:dio/dio.dart';
import 'package:api/src/base_api.dart';
import 'package:api/src/dio_manager.dart';
import 'package:api/src/common_api_methods.dart';

abstract class Server1Service with BaseApi, CommonApiMethods {
  Server1Service() : dio = DioManager.getDio('server1');

  @override
  final Dio dio;

  String get resourcePath;

  @override
  String getUrl(String path) => '$resourcePath/$path';
}

abstract class Server2Service with BaseApi, CommonApiMethods {
  Server2Service() : dio = DioManager.getDio('server2');

  @override
  final Dio dio;

  String get resourcePath;

  @override
  String getUrl(String path) => '$resourcePath/$path';
}
