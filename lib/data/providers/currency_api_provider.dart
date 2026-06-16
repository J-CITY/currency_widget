import '../models/currency_rate.dart';

abstract class CurrencyApiProvider {
  /// Имя провайдера (например, 'cbr', 'frankfurter')
  String get name;
  
  /// Получает курс для конкретной пары валют
  Future<CurrencyRate> fetchRate(String baseCurrency, String targetCurrency);
}
