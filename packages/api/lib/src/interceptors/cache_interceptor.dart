import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

class CacheInterceptor extends Interceptor {
  final CacheOptions cacheOptions = CacheOptions(
    store: MemCacheStore(),
    hitCacheOnErrorExcept: [401, 403],
    maxStale: const Duration(hours: 1),
    allowPostMethod: true,
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Apply cache options
    options.extra.addAll(<String, dynamic>{'cacheOptions': cacheOptions});
    super.onRequest(options, handler);
  }
}
