import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'CurrencyRate'**
  String get appTitle;

  /// No description provided for @ratesTitle.
  ///
  /// In en, this message translates to:
  /// **'Currency Rates'**
  String get ratesTitle;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @noTrackedCurrencies.
  ///
  /// In en, this message translates to:
  /// **'No tracked currencies\nPress + to add'**
  String get noTrackedCurrencies;

  /// No description provided for @apiAndUpdated.
  ///
  /// In en, this message translates to:
  /// **'API: {apiName}\nUpdated: {date}'**
  String apiAndUpdated(String apiName, String date);

  /// No description provided for @enterBothCurrencies.
  ///
  /// In en, this message translates to:
  /// **'Enter both currencies'**
  String get enterBothCurrencies;

  /// No description provided for @pairAlreadyTracked.
  ///
  /// In en, this message translates to:
  /// **'This pair is already tracked'**
  String get pairAlreadyTracked;

  /// No description provided for @saveError.
  ///
  /// In en, this message translates to:
  /// **'Save error: {error}'**
  String saveError(String error);

  /// No description provided for @addRateTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Rate'**
  String get addRateTitle;

  /// No description provided for @baseCurrencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Base Currency (e.g., USD)'**
  String get baseCurrencyLabel;

  /// No description provided for @targetCurrencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Target Currency (e.g., RUB)'**
  String get targetCurrencyLabel;

  /// No description provided for @dataSourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Data Source (API)'**
  String get dataSourceLabel;

  /// No description provided for @savePairButton.
  ///
  /// In en, this message translates to:
  /// **'Save Pair'**
  String get savePairButton;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved. Interval: {minutes} min.'**
  String settingsSaved(int minutes);

  /// No description provided for @updateFrequency.
  ///
  /// In en, this message translates to:
  /// **'Widget Update Frequency'**
  String get updateFrequency;

  /// No description provided for @updateInBackground.
  ///
  /// In en, this message translates to:
  /// **'Rates will be updated in the background every {minutes} min.'**
  String updateInBackground(int minutes);

  /// No description provided for @minutesLabel.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes'**
  String minutesLabel(int minutes);

  /// No description provided for @settingsSavedHours.
  ///
  /// In en, this message translates to:
  /// **'Settings saved. Interval: {hours} hr.'**
  String settingsSavedHours(int hours);

  /// No description provided for @updateInBackgroundHours.
  ///
  /// In en, this message translates to:
  /// **'Rates will be updated in the background every {hours} hr.'**
  String updateInBackgroundHours(int hours);

  /// No description provided for @hoursLabel.
  ///
  /// In en, this message translates to:
  /// **'{hours} hr.'**
  String hoursLabel(int hours);

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @rateError.
  ///
  /// In en, this message translates to:
  /// **'Error loading rate'**
  String get rateError;

  /// No description provided for @widgetWaitingData.
  ///
  /// In en, this message translates to:
  /// **'Waiting for data...'**
  String get widgetWaitingData;

  /// No description provided for @widgetTheme.
  ///
  /// In en, this message translates to:
  /// **'Widget Theme'**
  String get widgetTheme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System (Material You)'**
  String get themeSystem;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get themeCustom;

  /// No description provided for @customBgColor.
  ///
  /// In en, this message translates to:
  /// **'Background Color'**
  String get customBgColor;

  /// No description provided for @customPrimaryColor.
  ///
  /// In en, this message translates to:
  /// **'Primary Text Color'**
  String get customPrimaryColor;

  /// No description provided for @customSecondaryColor.
  ///
  /// In en, this message translates to:
  /// **'Secondary Text Color'**
  String get customSecondaryColor;

  /// No description provided for @pickColor.
  ///
  /// In en, this message translates to:
  /// **'Pick a color'**
  String get pickColor;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @emailCopied.
  ///
  /// In en, this message translates to:
  /// **'Email copied to clipboard'**
  String get emailCopied;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
