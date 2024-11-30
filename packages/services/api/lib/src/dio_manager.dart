import 'package:dio/dio.dart';

class DioManager {
  DioManager._();

  static final Map<String, Dio> _dioInstances = {};

  static void registerDio(String key, Dio dio) {
    _dioInstances[key] = dio;
  }

  static Dio getDio(String key) {
    if (!_dioInstances.containsKey(key)) {
      throw Exception('No Dio instance registered for key: $key');
    }
    return _dioInstances[key]!;
  }
}

void setupDioInstances() {
  // Configuración para el servidor 1
  final dioServer1 = Dio(
    BaseOptions(baseUrl: 'https://api.server1.com'),
  );
  // Agrega interceptores y configuración específica para el servidor 1
  dioServer1.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      // Interceptor para el servidor 1
      return handler.next(options);
    },
  ));
  DioManager.registerDio('server1', dioServer1);

  // Configuración para el servidor 2
  final dioServer2 = Dio(
    BaseOptions(baseUrl: 'https://api.server2.com'),
  );
  // Agrega interceptores y configuración específica para el servidor 2
  dioServer2.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      // Interceptor para el servidor 2
      return handler.next(options);
    },
  ));
  DioManager.registerDio('server2', dioServer2);

  // Puedes agregar tantas instancias como servidores tengas
}
