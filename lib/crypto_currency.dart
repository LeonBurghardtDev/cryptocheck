/// CryptoCurrency class
class CryptoCurrency {
  final String id; // unique id of the cryptocurrency != symbol
  final String name;
  final String symbol;
  final double price;
  final String iconUrl;

  CryptoCurrency({
    required this.id,
    required this.name,
    required this.symbol,
    required this.price,
    required this.iconUrl,
  });

  /// factory constructor to create a CryptoCurrency object from a JSON object returned by the Coingecko API
  factory CryptoCurrency.fromJson(Map<String, dynamic> json) {
    return CryptoCurrency(
      id: json['id'],
      name: json['name'],
      symbol: json['symbol'],
      price: json['current_price'].toDouble(),
      iconUrl: json['image'],
    );
  }
}
