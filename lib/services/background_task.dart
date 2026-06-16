import 'dart:convert';
import 'package:workmanager/workmanager.dart';
import 'package:home_widget/home_widget.dart';
import '../data/local/preferences_service.dart';
import '../data/repositories/currency_repository.dart';
import '../data/models/currency_rate.dart';

const String backgroundTaskKey = "update_currency_rates_task";
const String appWidgetName = "CurrencyWidgetProvider"; // Имя класса виджета в Android

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final prefsService = PreferencesService();
      final repository = CurrencyRepository(prefsService);

      // Запрашиваем новые данные
      final rates = await repository.fetchRatesForConfiguredPairs();

      if (rates.isNotEmpty) {
        await BackgroundTaskService.updateWidgetData(rates);
      }
    } catch (e) {
      print('Background task error: $e');
      return Future.value(false);
    }
    
    return Future.value(true);
  });
}

class BackgroundTaskService {
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true, // Логирование в режиме отладки
    );
  }

  static Future<void> updateWidgetData(List<CurrencyRate> rates, {String? theme, String? title, String? emptyMessage}) async {
    final ratesJson = jsonEncode(rates.map((r) => r.toJson()).toList());
    await HomeWidget.saveWidgetData<String>('rates_data', ratesJson);
    
    final prefs = PreferencesService();
    final currentTheme = theme ?? await prefs.getWidgetTheme();
    await HomeWidget.saveWidgetData<String>('widget_theme', currentTheme);

    if (currentTheme == 'custom') {
      final customColors = await prefs.getCustomColors();
      await HomeWidget.saveWidgetData<String>('custom_bg', '#${customColors['bg']!.toRadixString(16).padLeft(8, '0')}');
      await HomeWidget.saveWidgetData<String>('custom_primary', '#${customColors['primary']!.toRadixString(16).padLeft(8, '0')}');
      await HomeWidget.saveWidgetData<String>('custom_secondary', '#${customColors['secondary']!.toRadixString(16).padLeft(8, '0')}');
    }

    if (title != null) {
      await HomeWidget.saveWidgetData<String>('title', title);
    }
    if (emptyMessage != null) {
      await HomeWidget.saveWidgetData<String>('empty_message', emptyMessage);
    }

    final now = DateTime.now();
    final updateTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    await HomeWidget.saveWidgetData<String>('update_time', updateTime);

    await HomeWidget.saveWidgetData<bool>('is_updating', false);
    await HomeWidget.updateWidget(name: appWidgetName);
  }

  static Future<void> scheduleUpdate(int minutes) async {
    await Workmanager().cancelAll();
    
    // В Android WorkManager минимальный интервал 15 минут.
    final safeMinutes = minutes < 15 ? 15 : minutes;

    await Workmanager().registerPeriodicTask(
      "1",
      backgroundTaskKey,
      frequency: Duration(minutes: safeMinutes),
      constraints: Constraints(
        networkType: NetworkType.connected, // Обновлять только при наличии интернета
      ),
    );
  }
}
