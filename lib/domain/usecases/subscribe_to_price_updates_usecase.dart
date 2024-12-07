import 'package:commandy/commandy.dart';
import 'package:crypto/data/models/price.dart';
import 'package:crypto/data/repositories/crypto_repository.dart';
import 'package:crypto/domain/usecases/base_use_case.dart';
import 'package:flutter/foundation.dart';

class SubscribeToPriceUpdatesUseCase implements StreamUseCase<Price, List<String>> {
  SubscribeToPriceUpdatesUseCase(this.repository);

  final CryptoRepository repository;

  @override
  Stream<Result<Price>> call(List<String> cryptoIds) async* {
    try {
      await for (final price in repository.subscribeToPriceUpdates(cryptoIds)) {
        yield Success(price);
      }
    } catch (e, s) {
      debugPrint('Error en los precios: $e');
      yield FailureResult(
        Failure(
          message: 'Failed to subscribe to price updates',
          exception: e,
          stackTrace: s,
        ),
      );
    }
  }
}
