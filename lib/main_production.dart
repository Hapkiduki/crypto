import 'package:crypto/app/app.dart';
import 'package:crypto/bootstrap.dart';
import 'package:crypto/data/repositories/crypto_repository_impl.dart';
import 'package:crypto/domain/usecases/get_cryptocurrencies_usecase.dart';
import 'package:crypto/domain/usecases/subscribe_to_price_updates_usecase.dart';
import 'package:dio/dio.dart';

void main() {
  bootstrap(() {
    final dio = Dio();
    final repository = CryptoRepositoryImpl(dio);
    final getCryptocurrenciesUseCase = GetCryptocurrenciesUseCase(repository);
    final subscribeToPriceUpdatesUseCase = SubscribeToPriceUpdatesUseCase(repository);

    return App(
      getCryptocurrenciesUseCase: getCryptocurrenciesUseCase,
      subscribeToPriceUpdatesUseCase: subscribeToPriceUpdatesUseCase,
    );
  });
}
