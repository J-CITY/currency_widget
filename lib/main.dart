import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'services/background_task.dart';
import 'ui/home_screen.dart';
import 'config/features.dart';

import 'package:home_widget/home_widget.dart';
import 'data/local/preferences_service.dart';
import 'data/repositories/currency_repository.dart';

@pragma('vm:entry-point')
Future<void> backgroundCallback(Uri? uri) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (uri?.host == 'update') {
    try {
      await HomeWidget.saveWidgetData<bool>('is_updating', true);
      await HomeWidget.updateWidget(name: 'CurrencyWidgetProvider', iOSName: 'CurrencyWidget');

      final prefsService = PreferencesService();
      final repository = CurrencyRepository(prefsService);
      final rates = await repository.fetchRatesForConfiguredPairs();
      
      if (rates.isNotEmpty) {
        await BackgroundTaskService.updateWidgetData(rates);
      }
    } catch (e) {
      print('Background update error: $e');
    } finally {
      await HomeWidget.saveWidgetData<bool>('is_updating', false);
      await HomeWidget.updateWidget(name: 'CurrencyWidgetProvider', iOSName: 'CurrencyWidget');
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BackgroundTaskService.initialize();
  HomeWidget.registerBackgroundCallback(backgroundCallback);
  
  if (FeatureFlags.enableBannerAds) {
    await MobileAds.instance.initialize();
  }
  
  runApp(const CurrencyWidgetApp());
}

class CurrencyWidgetApp extends StatelessWidget {
  const CurrencyWidgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;

        if (lightDynamic != null && darkDynamic != null) {
          lightColorScheme = lightDynamic.harmonized();
          darkColorScheme = darkDynamic.harmonized();
        } else {
          lightColorScheme = ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          );
          darkColorScheme = ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          );
        }

        return MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: lightColorScheme,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: darkColorScheme,
            useMaterial3: true,
          ),
          themeMode: ThemeMode.system,
          home: const HomeScreen(),
        );
      },
    );
  }
}
