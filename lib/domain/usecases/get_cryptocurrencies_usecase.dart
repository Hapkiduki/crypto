import 'package:core/core.dart';
import 'package:crypto/data/models/cryptocurrency.dart';
import 'package:crypto/data/repositories/crypto_repository.dart';

class GetCryptocurrenciesUseCase implements BaseUseCase<List<Cryptocurrency>, NoParams> {
  GetCryptocurrenciesUseCase(this.repository);

  final CryptoRepository repository;

  @override
  Future<Result<List<Cryptocurrency>>> call(NoParams params) async {
    try {
      final cryptocurrencies = await repository.getCryptocurrencies();
      return Success(cryptocurrencies);
    } catch (e, s) {
      return Error(
        Failure(
          message: 'Failed to get cryptocurrencies',
          exception: e,
          stackTrace: s,
        ),
      );
    }
  }
}
