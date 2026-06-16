// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'CurrencyRate';

  @override
  String get ratesTitle => 'Курсы валют';

  @override
  String get add => 'Добавить';

  @override
  String get noTrackedCurrencies =>
      'Нет отслеживаемых валют\nНажмите + чтобы добавить';

  @override
  String apiAndUpdated(String apiName, String date) {
    return 'API: $apiName\nОбновлено: $date';
  }

  @override
  String get enterBothCurrencies => 'Введите обе валюты';

  @override
  String get pairAlreadyTracked => 'Эта пара уже отслеживается';

  @override
  String saveError(String error) {
    return 'Ошибка сохранения: $error';
  }

  @override
  String get addRateTitle => 'Добавить курс';

  @override
  String get baseCurrencyLabel => 'Базовая валюта (например, USD)';

  @override
  String get targetCurrencyLabel => 'Целевая валюта (например, RUB)';

  @override
  String get dataSourceLabel => 'Источник данных (API)';

  @override
  String get savePairButton => 'Сохранить пару';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String settingsSaved(int minutes) {
    return 'Настройки сохранены. Интервал: $minutes мин.';
  }

  @override
  String get updateFrequency => 'Частота обновления виджета';

  @override
  String updateInBackground(int minutes) {
    return 'Курсы будут обновляться в фоне каждые $minutes мин.';
  }

  @override
  String minutesLabel(int minutes) {
    return '$minutes мин.';
  }

  @override
  String settingsSavedHours(int hours) {
    return 'Настройки сохранены. Интервал: $hours ч.';
  }

  @override
  String updateInBackgroundHours(int hours) {
    return 'Курсы будут обновляться в фоне каждые $hours ч.';
  }

  @override
  String hoursLabel(int hours) {
    return '$hours ч.';
  }

  @override
  String get saveButton => 'Сохранить';

  @override
  String get edit => 'Редактировать';

  @override
  String get delete => 'Удалить';

  @override
  String get rateError => 'Ошибка загрузки';

  @override
  String get widgetWaitingData => 'Ожидание данных...';

  @override
  String get widgetTheme => 'Оформление виджета';

  @override
  String get themeSystem => 'Системное (Material You)';

  @override
  String get themeDark => 'Темное';

  @override
  String get themeLight => 'Светлое';

  @override
  String get themeCustom => 'Пользовательское';

  @override
  String get customBgColor => 'Цвет фона';

  @override
  String get customPrimaryColor => 'Основной текст';

  @override
  String get customSecondaryColor => 'Вторичный текст';

  @override
  String get pickColor => 'Выберите цвет';

  @override
  String get developer => 'Разработчик';

  @override
  String get emailCopied => 'Email скопирован в буфер обмена';
}
