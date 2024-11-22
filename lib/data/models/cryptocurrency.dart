class Cryptocurrency {
  Cryptocurrency({
    required this.id,
    required this.name,
    required this.symbol,
    required this.imageUrl,
  });

  factory Cryptocurrency.fromJson(Map<String, dynamic> json) {
    if (json
        case {
          'id': final String id,
          'name': final String name,
          'symbol': final String symbol,
          'image': final String imageUrl,
        }) {
      return Cryptocurrency(
        id: id,
        name: name,
        symbol: symbol,
        imageUrl: imageUrl,
      );
    }

    throw const FormatException('Invalid JSON structure for Cryptocurrency');
  }

  final String id;
  final String name;
  final String symbol;
  final String imageUrl;
}
