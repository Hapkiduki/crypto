import 'package:crypto/data/models/cryptocurrency.dart';
import 'package:crypto/data/models/price.dart';

abstract interface class CryptoRepository {
  Future<List<Cryptocurrency>> getCryptocurrencies();
  Stream<Price> subscribeToPriceUpdates(List<String> cryptoIds);
}
