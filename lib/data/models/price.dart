class Price {
  Price({
    required this.cryptoId,
    required this.currentPrice,
    required this.priceChangePercentage24h,
  });

  factory Price.fromJson(String id, Map<String, dynamic> json) {
    final currentPrice = switch (json['usd']) {
      final num value => value.toDouble(),
      final String value => double.tryParse(value) ?? 0.0,
      _ => 0.0,
    };

    final priceChangePercentage24h = switch (json['usd_24h_change']) {
      final num value => value.toDouble(),
      final String value => double.tryParse(value) ?? 0.0,
      _ => 0.0,
    };

    return Price(
      cryptoId: id,
      currentPrice: currentPrice,
      priceChangePercentage24h: priceChangePercentage24h,
    );
  }

  final String cryptoId;
  final double currentPrice;
  final double priceChangePercentage24h;
}
