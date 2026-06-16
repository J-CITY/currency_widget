// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CurrencyRate';

  @override
  String get ratesTitle => 'Currency Rates';

  @override
  String get add => 'Add';

  @override
  String get noTrackedCurrencies => 'No tracked currencies\nPress + to add';

  @override
  String apiAndUpdated(String apiName, String date) {
    return 'API: $apiName\nUpdated: $date';
  }

  @override
  String get enterBothCurrencies => 'Enter both currencies';

  @override
  String get pairAlreadyTracked => 'This pair is already tracked';

  @override
  String saveError(String error) {
    return 'Save error: $error';
  }

  @override
  String get addRateTitle => 'Add Rate';

  @override
  String get baseCurrencyLabel => 'Base Currency (e.g., USD)';

  @override
  String get targetCurrencyLabel => 'Target Currency (e.g., RUB)';

  @override
  String get dataSourceLabel => 'Data Source (API)';

  @override
  String get savePairButton => 'Save Pair';

  @override
  String get settingsTitle => 'Settings';

  @override
  String settingsSaved(int minutes) {
    return 'Settings saved. Interval: $minutes min.';
  }

  @override
  String get updateFrequency => 'Widget Update Frequency';

  @override
  String updateInBackground(int minutes) {
    return 'Rates will be updated in the background every $minutes min.';
  }

  @override
  String minutesLabel(int minutes) {
    return '$minutes minutes';
  }

  @override
  String settingsSavedHours(int hours) {
    return 'Settings saved. Interval: $hours hr.';
  }

  @override
  String updateInBackgroundHours(int hours) {
    return 'Rates will be updated in the background every $hours hr.';
  }

  @override
  String hoursLabel(int hours) {
    return '$hours hr.';
  }

  @override
  String get saveButton => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get rateError => 'Error loading rate';

  @override
  String get widgetWaitingData => 'Waiting for data...';

  @override
  String get widgetTheme => 'Widget Theme';

  @override
  String get themeSystem => 'System (Material You)';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get themeCustom => 'Custom';

  @override
  String get customBgColor => 'Background Color';

  @override
  String get customPrimaryColor => 'Primary Text Color';

  @override
  String get customSecondaryColor => 'Secondary Text Color';

  @override
  String get pickColor => 'Pick a color';

  @override
  String get developer => 'Developer';

  @override
  String get emailCopied => 'Email copied to clipboard';
}
