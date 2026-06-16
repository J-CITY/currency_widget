import '../models/currency_rate.dart';
import '../providers/currency_api_provider.dart';
import '../providers/frankfurter_api.dart';
import '../providers/cbr_api.dart';
import '../providers/fawazahmed_api.dart';
import '../providers/exchangerate_api.dart';
import '../local/preferences_service.dart';

class CurrencyRepository {
  final PreferencesService _prefsService;
  final Map<String, CurrencyApiProvider> _providers = {};

  CurrencyRepository(this._prefsService) {
    _registerProvider(FrankfurterApi());
    _registerProvider(CbrApi());
    _registerProvider(FawazahmedApi());
    _registerProvider(ExchangeRateApi());
  }

  void _registerProvider(CurrencyApiProvider provider) {
    _providers[provider.name] = provider;
  }

  /// Скачивает курсы для всех настроенных пар
  Future<List<CurrencyRate>> fetchRatesForConfiguredPairs() async {
    final pairs = await _prefsService.getPairs();
    final cachedRates = await _prefsService.getRatesCache();
    final List<CurrencyRate> rates = [];

    for (var pair in pairs) {
      final provider = _providers[pair.apiName];
      if (provider != null) {
        // Находим старый кэш для этой пары
        final cached = cachedRates.where((r) => r.pairId == pair.id).firstOrNull;
        
        try {
          final rate = await provider.fetchRate(pair.baseCurrency, pair.targetCurrency);
          
          double? prevRate = cached?.previousRate;
          // Если курс изменился, сохраняем старый как previousRate
          if (cached != null && cached.rate != rate.rate) {
            prevRate = cached.rate;
          }
          
          rates.add(rate.copyWith(
            pairId: pair.id, 
            hasError: false,
            previousRate: prevRate,
          ));
        } catch (e) {
          print('Error fetching rate for ${pair.baseCurrency}-${pair.targetCurrency} via ${pair.apiName}: $e');
          rates.add(CurrencyRate(
            pairId: pair.id,
            baseCurrency: pair.baseCurrency,
            targetCurrency: pair.targetCurrency,
            rate: cached?.rate ?? 0.0,
            previousRate: cached?.previousRate,
            lastUpdated: cached?.lastUpdated ?? DateTime.now(),
            apiName: pair.apiName,
            hasError: true,
          ));
        }
      }
    }

    if (rates.isNotEmpty) {
      await _prefsService.saveRatesCache(rates); // Кэшируем новые данные
    }

    // Если ничего не удалось скачать, возвращаем кэш
    return rates.isNotEmpty ? rates : await _prefsService.getRatesCache();
  }

  Future<List<CurrencyRate>> getCachedRates() async {
    return await _prefsService.getRatesCache();
  }

  List<String> getAvailableProviders() {
    return _providers.keys.toList();
  }

  Future<void> testRate(String apiName, String baseCurrency, String targetCurrency) async {
    final provider = _providers[apiName];
    if (provider == null) throw Exception('Provider not found');
    await provider.fetchRate(baseCurrency, targetCurrency);
  }
}
