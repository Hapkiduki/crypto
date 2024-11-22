import 'package:core/core.dart';
import 'package:crypto/data/models/cryptocurrency.dart';
import 'package:crypto/data/models/price.dart';
import 'package:crypto/domain/usecases/get_cryptocurrencies_usecase.dart';
import 'package:crypto/domain/usecases/subscribe_to_price_updates_usecase.dart';
import 'package:flutter/foundation.dart';

class CryptoViewModel extends ChangeNotifier {
  CryptoViewModel({
    required GetCryptocurrenciesUseCase getCryptocurrenciesUseCase,
    required SubscribeToPriceUpdatesUseCase subscribeToPriceUpdatesUseCase,
  })  : _getCryptocurrenciesUseCase = getCryptocurrenciesUseCase,
        _subscribeToPriceUpdatesUseCase = subscribeToPriceUpdatesUseCase {
    getCryptocurrenciesCommand = Command<List<Cryptocurrency>, NoParams>(
      _getCryptocurrencies,
    );
    priceUpdatesCommand = StreamCommand<Price, List<String>>(
      _subscribeToPriceUpdates,
    );

    // Start the initialization process
    _initialize();
  }

  final GetCryptocurrenciesUseCase _getCryptocurrenciesUseCase;
  final SubscribeToPriceUpdatesUseCase _subscribeToPriceUpdatesUseCase;

  late final Command<List<Cryptocurrency>, NoParams> getCryptocurrenciesCommand;
  late final StreamCommand<Price, List<String>> priceUpdatesCommand;

  List<Cryptocurrency> cryptocurrencies = [];
  Map<String, Price> prices = {};

  /// Holds any error message that occurs during operations
  String? errorMessage;

  /// Initializes the ViewModel by fetching cryptocurrencies and starting price updates
  Future<void> _initialize() async {
    await getCryptocurrenciesCommand.execute(NoParams());
    final result = getCryptocurrenciesCommand.result.value;

    if (result is Success<List<Cryptocurrency>>) {
      // Cryptocurrencies are already updated in _getCryptocurrencies
      // Start streaming price updates
      final cryptoIds = cryptocurrencies.map((c) => c.id).toList();
      priceUpdatesCommand.start(cryptoIds);
      priceUpdatesCommand.latestResult.addListener(_onPriceUpdate);
    } else if (result is Error<List<Cryptocurrency>>) {
      // Handle error by setting the error message
      errorMessage = result.failure.message;
      notifyListeners();
    }
  }

  /// Fetches the list of cryptocurrencies
  Future<Result<List<Cryptocurrency>>> _getCryptocurrencies(NoParams params) async {
    final result = await _getCryptocurrenciesUseCase(params);
    result.fold(
      (data) {
        cryptocurrencies = data;
        errorMessage = null; // Clear any previous errors
        notifyListeners();
      },
      (failure) {
        // Handle failure by setting the error message
        errorMessage = failure.message;
        notifyListeners();
      },
    );
    return result;
  }

  /// Subscribes to price updates for the given list of cryptocurrency IDs
  Stream<Result<Price>> _subscribeToPriceUpdates(List<String> cryptoIds) {
    return _subscribeToPriceUpdatesUseCase(cryptoIds);
  }

  /// Handles new price updates or errors from the priceUpdatesCommand
  void _onPriceUpdate() {
    final result = priceUpdatesCommand.latestResult.value;
    if (result != null) {
      result.fold(
        (price) {
          prices[price.cryptoId] = price;
          errorMessage = null; // Clear any previous errors
          notifyListeners();
        },
        (failure) {
          // Handle error by setting the error message
          errorMessage = failure.message;
          notifyListeners();
        },
      );
    }
  }

  /// Clears the current error message and notifies listeners
  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    priceUpdatesCommand.dispose();
    super.dispose();
  }
}
