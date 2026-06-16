class CurrencyRate {
  final String pairId;
  final String baseCurrency;
  final String targetCurrency;
  final double rate;
  final double? previousRate;
  final DateTime lastUpdated;
  final String apiName;
  final bool hasError;

  const CurrencyRate({
    this.pairId = '',
    required this.baseCurrency,
    required this.targetCurrency,
    required this.rate,
    this.previousRate,
    required this.lastUpdated,
    required this.apiName,
    this.hasError = false,
  });

  Map<String, dynamic> toJson() => {
        'pairId': pairId,
        'baseCurrency': baseCurrency,
        'targetCurrency': targetCurrency,
        'rate': rate,
        'previousRate': previousRate,
        'lastUpdated': lastUpdated.toIso8601String(),
        'apiName': apiName,
        'hasError': hasError,
      };

  factory CurrencyRate.fromJson(Map<String, dynamic> json) => CurrencyRate(
        pairId: json['pairId'] ?? '',
        baseCurrency: json['baseCurrency'],
        targetCurrency: json['targetCurrency'],
        rate: json['rate'].toDouble(),
        previousRate: json['previousRate']?.toDouble(),
        lastUpdated: DateTime.parse(json['lastUpdated']),
        apiName: json['apiName'],
        hasError: json['hasError'] ?? false,
      );

  CurrencyRate copyWith({
    String? pairId,
    double? previousRate,
    bool? hasError,
  }) {
    return CurrencyRate(
      pairId: pairId ?? this.pairId,
      baseCurrency: baseCurrency,
      targetCurrency: targetCurrency,
      rate: rate,
      previousRate: previousRate ?? this.previousRate,
      lastUpdated: lastUpdated,
      apiName: apiName,
      hasError: hasError ?? this.hasError,
    );
  }
}
