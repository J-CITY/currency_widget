import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/currency_rate.dart';
import 'currency_api_provider.dart';

class FrankfurterApi implements CurrencyApiProvider {
  @override
  String get name => 'frankfurter';

  @override
  Future<CurrencyRate> fetchRate(String baseCurrency, String targetCurrency) async {
    final response = await http.get(Uri.parse('https://api.frankfurter.app/latest?from=$baseCurrency&to=$targetCurrency'));
    
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final rate = json['rates'][targetCurrency].toDouble();
      return CurrencyRate(
        baseCurrency: baseCurrency,
        targetCurrency: targetCurrency,
        rate: rate,
        lastUpdated: DateTime.now(),
        apiName: name,
      );
    } else {
      throw Exception('Failed to load rate from Frankfurter API');
    }
  }

  @override
  Future<Map<String, String>> fetchAvailableCurrencies() async {
    final response = await http.get(Uri.parse('https://api.frankfurter.app/currencies'));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return json.map((key, value) => MapEntry(key, value.toString()));
    } else {
      throw Exception('Failed to load currencies from Frankfurter');
    }
  }
}
