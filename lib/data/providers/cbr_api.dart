import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/currency_rate.dart';
import 'currency_api_provider.dart';

class CbrApi implements CurrencyApiProvider {
  @override
  String get name => 'cbr';

  @override
  Future<CurrencyRate> fetchRate(String baseCurrency, String targetCurrency) async {
    final response = await http.get(Uri.parse('https://www.cbr-xml-daily.ru/daily_json.js'));
    
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final valutes = json['Valute'] as Map<String, dynamic>;
      
      double getRateToRub(String code) {
        if (code == 'RUB') return 1.0;
        if (!valutes.containsKey(code)) throw Exception('Currency $code not found in CBR');
        final data = valutes[code];
        final value = data['Value'] as num;
        final nominal = data['Nominal'] as num;
        return value.toDouble() / nominal.toDouble();
      }

      final baseToRub = getRateToRub(baseCurrency);
      final targetToRub = getRateToRub(targetCurrency);
      
      // Расчет кросс-курса через рубль
      // Пример: USD -> RUB (baseToRub = 90, targetToRub = 1) => 90 / 1 = 90
      // Пример: EUR -> USD (baseToRub = 100, targetToRub = 90) => 100 / 90 = 1.11
      final rate = baseToRub / targetToRub;

      return CurrencyRate(
        baseCurrency: baseCurrency,
        targetCurrency: targetCurrency,
        rate: rate,
        lastUpdated: DateTime.now(),
        apiName: name,
      );
    } else {
      throw Exception('Failed to load rate from CBR API');
    }
  }
}
