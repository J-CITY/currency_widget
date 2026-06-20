import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/currency_rate.dart';
import 'currency_api_provider.dart';

class ExchangeRateApi implements CurrencyApiProvider {
  @override
  String get name => 'exchangerate';

  @override
  Future<CurrencyRate> fetchRate(String baseCurrency, String targetCurrency) async {
    // Используем открытый эндпоинт без ключа
    final response = await http.get(Uri.parse('https://open.er-api.com/v6/latest/$baseCurrency')).timeout(const Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        final rate = json['rates'][targetCurrency].toDouble();
        return CurrencyRate(
          baseCurrency: baseCurrency,
          targetCurrency: targetCurrency,
          rate: rate,
          lastUpdated: DateTime.now(),
          apiName: name,
        );
      } else {
        throw Exception('API returned error: ${json['error-type']}');
      }
    } else {
      throw Exception('Failed to load rate from ExchangeRate-API');
    }
  }

  @override
  Future<Map<String, String>> fetchAvailableCurrencies() async {
    final response = await http.get(Uri.parse('https://open.er-api.com/v6/latest/USD')).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        final rates = json['rates'] as Map<String, dynamic>;
        // Бесплатный эндпоинт не отдает полные имена, поэтому используем сами коды
        return rates.map((key, _) => MapEntry(key, key));
      } else {
        throw Exception('API returned error: ${json['error-type']}');
      }
    } else {
      throw Exception('Failed to load currencies from ExchangeRate-API');
    }
  }
}
