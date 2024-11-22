import 'package:crypto/data/models/cryptocurrency.dart';
import 'package:crypto/data/models/price.dart';
import 'package:crypto/data/repositories/crypto_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class CryptoRepositoryImpl implements CryptoRepository {
  CryptoRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<Cryptocurrency>> getCryptocurrencies() async {
    final response = await _dio.get<List<dynamic>>(
      'https://api.coingecko.com/api/v3/coins/markets',
      queryParameters: {
        'vs_currency': 'usd',
        'order': 'market_cap_desc',
        'per_page': 20,
        'page': 1,
        'sparkline': false,
      },
    );

    final data = response.data;

    if (data == null) {
      throw Exception('Failed to load cryptocurrencies');
    }

    return data.map((json) => Cryptocurrency.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Stream<Price> subscribeToPriceUpdates(List<String> cryptoIds) async* {
    while (true) {
      debugPrint('Precios actualizados');
      final response = await _dio.get<Map<String, dynamic>>(
        'https://api.coingecko.com/api/v3/simple/price',
        queryParameters: {
          'ids': cryptoIds.join(','),
          'vs_currencies': 'usd',
          'include_24hr_change': 'true',
        },
      );

      final data = response.data;

      if (data == null) {
        throw Exception('Failed to load price data');
      }

      for (final id in cryptoIds) {
        if (data.containsKey(id)) {
          final priceData = data[id];

          if (priceData != null && priceData is Map<String, dynamic>) {
            yield Price.fromJson(id, priceData);
          }
        }
      }

      await Future<void>.delayed(const Duration(seconds: 10));
    }
  }
}
