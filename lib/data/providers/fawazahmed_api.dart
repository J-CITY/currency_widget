import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/currency_rate.dart';
import 'currency_api_provider.dart';

class FawazahmedApi implements CurrencyApiProvider {
  @override
  String get name => 'fawazahmed0';

  @override
  Future<CurrencyRate> fetchRate(String baseCurrency, String targetCurrency) async {
    final base = baseCurrency.toLowerCase();
    final target = targetCurrency.toLowerCase();
    
    final response = await http.get(Uri.parse('https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/$base.json'));
    
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final rate = json[base][target].toDouble();
      return CurrencyRate(
        baseCurrency: baseCurrency,
        targetCurrency: targetCurrency,
        rate: rate,
        lastUpdated: DateTime.now(),
        apiName: name,
      );
    } else {
      throw Exception('Failed to load rate from Currency-API (fawazahmed0)');
    }
  }

  @override
  Future<Map<String, String>> fetchAvailableCurrencies() async {
    final response = await http.get(Uri.parse('https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies.json'));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      // API возвращает ключи в нижнем регистре, приводим к верхнему для единообразия
      return json.map((key, value) => MapEntry(key.toUpperCase(), value.toString()));
    } else {
      throw Exception('Failed to load currencies from FawazahmedApi');
    }
  }
}
