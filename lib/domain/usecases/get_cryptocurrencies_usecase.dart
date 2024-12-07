import 'package:commandy/commandy.dart';

import 'package:crypto/data/models/cryptocurrency.dart';
import 'package:crypto/data/repositories/crypto_repository.dart';
import 'package:crypto/domain/usecases/base_use_case.dart';

class GetCryptocurrenciesUseCase implements BaseUseCase<List<Cryptocurrency>, NoParams> {
  GetCryptocurrenciesUseCase(this.repository);

  final CryptoRepository repository;

  @override
  Future<Result<List<Cryptocurrency>>> call(NoParams params) async {
    try {
      final cryptocurrencies = await repository.getCryptocurrencies();
      return Success(cryptocurrencies);
    } catch (e, s) {
      return FailureResult(
        Failure(
          message: 'Failed to get cryptocurrencies',
          exception: e,
          stackTrace: s,
        ),
      );
    }
  }
}
