import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/currency_pair.dart';
import '../models/currency_rate.dart';

class PreferencesService {
  static const String _pairsKey = 'selected_currency_pairs';
  static const String _ratesCacheKey = 'rates_cache';
  static const String _intervalKey = 'update_interval_minutes';
  static const String _themeKey = 'widget_theme';
  static const String _customBgColorKey = 'custom_bg_color';
  static const String _customPrimaryTextKey = 'custom_primary_text';
  static const String _customSecondaryTextKey = 'custom_secondary_text';

  String _getDictKey(String apiName) => 'currencies_dict_$apiName';

  Future<void> saveCurrenciesDictionary(String apiName, Map<String, String> dict) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_getDictKey(apiName), jsonEncode(dict));
  }

  Future<Map<String, String>?> getCurrenciesDictionary(String apiName) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_getDictKey(apiName));
    if (jsonString == null) return null;
    try {
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      return decoded.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      return null;
    }
  }

  Future<void> savePairs(List<CurrencyPair> pairs) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(pairs.map((p) => p.toJson()).toList());
    await prefs.setString(_pairsKey, jsonString);
  }

  Future<List<CurrencyPair>> getPairs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_pairsKey);
    if (jsonString == null) return [];
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => CurrencyPair.fromJson(json)).toList();
  }

  Future<void> saveRatesCache(List<CurrencyRate> rates) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(rates.map((r) => r.toJson()).toList());
    await prefs.setString(_ratesCacheKey, jsonString);
  }

  Future<List<CurrencyRate>> getRatesCache() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_ratesCacheKey);
    if (jsonString == null) return [];
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => CurrencyRate.fromJson(json)).toList();
  }

  Future<void> saveUpdateInterval(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_intervalKey, minutes);
  }

  Future<int> getUpdateInterval() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_intervalKey) ?? 720; // По умолчанию 12 часов (720 мин)
  }

  Future<void> saveWidgetTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme);
  }

  Future<String> getWidgetTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? 'system';
  }

  Future<void> saveCustomColors({
    required int bgColor,
    required int primaryText,
    required int secondaryText,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_customBgColorKey, bgColor);
    await prefs.setInt(_customPrimaryTextKey, primaryText);
    await prefs.setInt(_customSecondaryTextKey, secondaryText);
  }

  Future<Map<String, int>> getCustomColors() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'bg': prefs.getInt(_customBgColorKey) ?? 0xFF212121,
      'primary': prefs.getInt(_customPrimaryTextKey) ?? 0xFFFFFFFF,
      'secondary': prefs.getInt(_customSecondaryTextKey) ?? 0xFFAAAAAA,
    };
  }
}
