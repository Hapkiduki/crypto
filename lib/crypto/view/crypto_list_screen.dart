import 'package:core/core.dart';
import 'package:crypto/crypto/viewmodels/crypto_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CryptoListScreen extends StatefulWidget {
  const CryptoListScreen({Key? key}) : super(key: key);

  @override
  _CryptoListScreenState createState() => _CryptoListScreenState();
}

class _CryptoListScreenState extends State<CryptoListScreen> {
  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<CryptoViewModel>(context, listen: false);
    viewModel.addListener(_handleError);
  }

  @override
  void dispose() {
    final viewModel = Provider.of<CryptoViewModel>(context, listen: false);
    viewModel.removeListener(_handleError);
    super.dispose();
  }

  void _handleError() {
    final viewModel = Provider.of<CryptoViewModel>(context, listen: false);

    if (viewModel.errorMessage != null) {
      final snackBar = SnackBar(
        content: Text(
          viewModel.errorMessage!,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () {
            viewModel.clearError();
            viewModel.getCryptocurrenciesCommand.execute(NoParams());
          },
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      viewModel.clearError(); // Clear error after showing the snackbar
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CryptoViewModel>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crypto Prices'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        centerTitle: true,
        elevation: 4,
      ),
      body: AnimatedBuilder(
        animation: viewModel,
        builder: (context, child) {
          if (viewModel.cryptocurrencies.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
                childAspectRatio: 3 / 4,
              ),
              itemCount: viewModel.cryptocurrencies.length,
              itemBuilder: (context, index) {
                final crypto = viewModel.cryptocurrencies[index];
                final price = viewModel.prices[crypto.id];

                return _CryptoCard(
                  name: crypto.name,
                  symbol: crypto.symbol,
                  imageUrl: crypto.imageUrl,
                  price: price?.currentPrice,
                  change: price?.priceChangePercentage24h,
                  colorScheme: colorScheme,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _CryptoCard extends StatelessWidget {
  const _CryptoCard({
    Key? key,
    required this.name,
    required this.symbol,
    required this.imageUrl,
    this.price,
    this.change,
    required this.colorScheme,
  }) : super(key: key);

  final String name;
  final String symbol;
  final String imageUrl;
  final double? price;
  final double? change;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final changeColor = change != null ? (change! >= 0 ? colorScheme.primary : colorScheme.error) : colorScheme.onSurface;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: colorScheme.primary, // Puedes usar cualquier color aquí
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.network(
                  imageUrl,
                  height: 50,
                  width: 50,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, size: 50, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                symbol.toUpperCase(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const Spacer(),
              Text(
                price != null ? '\$${price?.toStringAsFixed(2)}' : 'N/A',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (change != null)
                Text(
                  '${change!.toStringAsFixed(2)}%',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: changeColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
