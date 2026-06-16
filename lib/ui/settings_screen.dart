import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../l10n/app_localizations.dart';
import '../data/local/preferences_service.dart';
import '../services/background_task.dart';
import '../data/repositories/currency_repository.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _prefs = PreferencesService();
  int _intervalMinutes = 720;
  String _theme = 'system';
  bool _isLoading = true;

  Color _customBg = const Color(0xFF212121);
  Color _customPrimary = const Color(0xFFFFFFFF);
  Color _customSecondary = const Color(0xFFAAAAAA);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final minutes = await _prefs.getUpdateInterval();
    final theme = await _prefs.getWidgetTheme();
    final customColors = await _prefs.getCustomColors();
    
    setState(() {
      _intervalMinutes = minutes;
      _theme = theme;
      _customBg = Color(customColors['bg']!);
      _customPrimary = Color(customColors['primary']!);
      _customSecondary = Color(customColors['secondary']!);
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final minutes = _intervalMinutes;
    await _prefs.saveUpdateInterval(minutes);
    await _prefs.saveWidgetTheme(_theme);
    
    if (_theme == 'custom') {
      await _prefs.saveCustomColors(
        bgColor: _customBg.value,
        primaryText: _customPrimary.value,
        secondaryText: _customSecondary.value,
      );
    }
    
    // Перезапускаем фоновую задачу с новым интервалом
    await BackgroundTaskService.scheduleUpdate(minutes);

    // Обновляем виджет, чтобы применить тему
    final repo = CurrencyRepository(_prefs);
    final rates = await repo.getCachedRates();
    await BackgroundTaskService.updateWidgetData(
      rates, 
      theme: _theme,
      title: AppLocalizations.of(context)!.ratesTitle,
      emptyMessage: AppLocalizations.of(context)!.widgetWaitingData,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.settingsSaved(minutes))),
      );
      Navigator.pop(context);
    }
  }

  void _pickColor(BuildContext context, Color currentColor, ValueChanged<Color> onColorChanged) {
    showDialog(
      context: context,
      builder: (context) {
        Color tempColor = currentColor;
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.pickColor),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: tempColor,
              onColorChanged: (color) => tempColor = color,
              enableAlpha: false,
              displayThumbColor: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.saveButton),
              onPressed: () {
                onColorChanged(tempColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settingsTitle)),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppLocalizations.of(context)!.updateFrequency,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.updateInBackground(_intervalMinutes),
                    style: TextStyle(color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<int>(
                    value: _intervalMinutes,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: [15, 30, 60, 120, 360, 720, 1440].map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(AppLocalizations.of(context)!.minutesLabel(value)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _intervalMinutes = val);
                    },
                  ),
                  const SizedBox(height: 32),
                  Text(
                    AppLocalizations.of(context)!.widgetTheme,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _theme,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: [
                      DropdownMenuItem(value: 'system', child: Text(AppLocalizations.of(context)!.themeSystem)),
                      DropdownMenuItem(value: 'dark', child: Text(AppLocalizations.of(context)!.themeDark)),
                      DropdownMenuItem(value: 'light', child: Text(AppLocalizations.of(context)!.themeLight)),
                      DropdownMenuItem(value: 'custom', child: Text(AppLocalizations.of(context)!.themeCustom)),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _theme = val);
                    },
                  ),
                  
                  if (_theme == 'custom') ...[
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(AppLocalizations.of(context)!.customBgColor),
                      trailing: CircleAvatar(backgroundColor: _customBg),
                      onTap: () => _pickColor(context, _customBg, (c) => setState(() => _customBg = c)),
                    ),
                    ListTile(
                      title: Text(AppLocalizations.of(context)!.customPrimaryColor),
                      trailing: CircleAvatar(backgroundColor: _customPrimary),
                      onTap: () => _pickColor(context, _customPrimary, (c) => setState(() => _customPrimary = c)),
                    ),
                    ListTile(
                      title: Text(AppLocalizations.of(context)!.customSecondaryColor),
                      trailing: CircleAvatar(backgroundColor: _customSecondary),
                      onTap: () => _pickColor(context, _customSecondary, (c) => setState(() => _customSecondary = c)),
                    ),
                  ],

                  const SizedBox(height: 32),
                  Text(
                    AppLocalizations.of(context)!.developer,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Daniil Glushchenko'),
                    subtitle: const Text('daniil.glushchenko1995@gmail.com'),
                    trailing: const Icon(Icons.copy, size: 20),
                    onTap: () {
                      Clipboard.setData(const ClipboardData(text: 'daniil.glushchenko1995@gmail.com'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context)!.emailCopied)),
                      );
                    },
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _saveSettings,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(AppLocalizations.of(context)!.saveButton, style: const TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
    );
  }
}
