import 'package:commandy/commandy.dart';
import 'package:crypto/crypto/viewmodels/crypto_viewmodel.dart';
import 'package:crypto/data/models/cryptocurrency.dart';
import 'package:crypto/data/models/price.dart';
import 'package:flutter/material.dart';

class CryptoListScreen extends StatelessWidget {
  const CryptoListScreen({
    required this.viewModel,
    Key? key,
  }) : super(key: key);

  final CryptoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CommandListener(
      listeners: [
        CommandListenerConfig(
          command: viewModel.getCryptocurrenciesCommand,
          listener: (context, result) {
            if (result is FailureResult<List<Cryptocurrency>>) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    result.failure.message,
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  action: SnackBarAction(
                    label: 'Retry',
                    textColor: Colors.white,
                    onPressed: () {
                      viewModel.getCryptocurrenciesCommand.execute(const NoParams());
                    },
                  ),
                ),
              );
            }
          },
        ),
        CommandListenerConfig(
          command: viewModel.priceUpdatesCommand,
          listener: (context, result) {
            if (result is FailureResult<Price>) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    result.failure.message,
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
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
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
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
      ),
    );
  }
}

class _CryptoCard extends StatelessWidget {
  const _CryptoCard({
    required this.name,
    required this.symbol,
    required this.imageUrl,
    required this.colorScheme,
    Key? key,
    this.price,
    this.change,
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
          color: colorScheme.primary,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.network(
                  imageUrl,
                  height: 50,
                  width: 50,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.error,
                    size: 50,
                    color: Colors.grey,
                  ),
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
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
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
