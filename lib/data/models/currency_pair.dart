class CurrencyPair {
  final String id;
  final String baseCurrency;
  final String targetCurrency;
  final String apiName;

  const CurrencyPair({
    required this.id,
    required this.baseCurrency,
    required this.targetCurrency,
    required this.apiName,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'baseCurrency': baseCurrency,
        'targetCurrency': targetCurrency,
        'apiName': apiName,
      };

  factory CurrencyPair.fromJson(Map<String, dynamic> json) => CurrencyPair(
        id: json['id'] ?? DateTime.now().microsecondsSinceEpoch.toString(),
        baseCurrency: json['baseCurrency'],
        targetCurrency: json['targetCurrency'],
        apiName: json['apiName'],
      );

  // Для уникальности в коллекциях (Set)
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrencyPair &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
