import 'package:crypto/crypto/view/crypto_list_screen.dart';
import 'package:crypto/crypto/viewmodels/crypto_viewmodel.dart';
import 'package:crypto/domain/usecases/get_cryptocurrencies_usecase.dart';
import 'package:crypto/domain/usecases/subscribe_to_price_updates_usecase.dart';
import 'package:crypto/l10n/l10n.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  const App({
    required GetCryptocurrenciesUseCase getCryptocurrenciesUseCase,
    required SubscribeToPriceUpdatesUseCase subscribeToPriceUpdatesUseCase,
    super.key,
  })  : _getCryptocurrenciesUseCase = getCryptocurrenciesUseCase,
        _subscribeToPriceUpdatesUseCase = subscribeToPriceUpdatesUseCase;

  final GetCryptocurrenciesUseCase _getCryptocurrenciesUseCase;
  final SubscribeToPriceUpdatesUseCase _subscribeToPriceUpdatesUseCase;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => CryptoViewModel(
            getCryptocurrenciesUseCase: _getCryptocurrenciesUseCase,
            subscribeToPriceUpdatesUseCase: _subscribeToPriceUpdatesUseCase,
          ),
        ),
      ],
      child: DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) => MaterialApp(
          theme: ThemeData(
            colorScheme: lightDynamic,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: darkDynamic,
            useMaterial3: true,
          ),
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const CryptoListScreen(),
        ),
      ),
    );
  }
}
