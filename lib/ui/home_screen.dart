import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../data/local/preferences_service.dart';
import '../data/repositories/currency_repository.dart';
import '../data/models/currency_rate.dart';
import '../data/models/currency_pair.dart';
import 'add_pair_screen.dart';
import 'settings_screen.dart';
import '../services/background_task.dart';
import '../config/features.dart';
import 'widgets/ad_banner.dart';

const Set<String> _availableCurrencyIcons = {
  'RUB',
  'USD',
  'CNY',
  'EUR',
  'KZT',
  'JPY',
  'BYN',
  'UZS',
  'TRY',
  'BTC',
};

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repository = CurrencyRepository(PreferencesService());
  List<CurrencyRate> _rates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRates();
  }

  Future<void> _loadRates() async {
    setState(() => _isLoading = true);
    final rates = await _repository.fetchRatesForConfiguredPairs();

    if (mounted) {
      BackgroundTaskService.updateWidgetData(
        rates,
        title: AppLocalizations.of(context)!.ratesTitle,
        emptyMessage: AppLocalizations.of(context)!.widgetWaitingData,
      );
    }

    setState(() {
      _rates = rates;
      _isLoading = false;
    });
  }

  Future<void> _deletePair(String pairId) async {
    final prefs = PreferencesService();
    final pairs = await prefs.getPairs();
    pairs.removeWhere((p) => p.id == pairId);
    await prefs.savePairs(pairs);
    _loadRates();
  }

  Future<void> _saveNewOrder() async {
    final prefs = PreferencesService();
    final pairs = await prefs.getPairs();
    
    final newPairsOrder = <CurrencyPair>[];
    for (var rate in _rates) {
      final pairIndex = pairs.indexWhere((p) => p.id == rate.pairId);
      if (pairIndex != -1) {
        newPairsOrder.add(pairs[pairIndex]);
      }
    }
    
    await prefs.savePairs(newPairsOrder);
    
    if (mounted) {
      BackgroundTaskService.updateWidgetData(
        _rates,
        title: AppLocalizations.of(context)!.ratesTitle,
        emptyMessage: AppLocalizations.of(context)!.widgetWaitingData,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.ratesTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _rates.isEmpty
          ? _buildEmptyState()
          : _buildRatesList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPairScreen()),
          );
          if (result == true) {
            _loadRates();
          }
        },
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context)!.add),
      ),
      bottomNavigationBar: FeatureFlags.enableBannerAds
          ? const AdBannerWidget()
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.currency_exchange,
            size: 64,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noTrackedCurrencies,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildRatesList() {
    return RefreshIndicator(
      onRefresh: _loadRates,
      child: ReorderableListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _rates.length,
        onReorder: (oldIndex, newIndex) {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          setState(() {
            final rate = _rates.removeAt(oldIndex);
            _rates.insert(newIndex, rate);
          });
          _saveNewOrder();
        },
        itemBuilder: (context, index) {
          final rate = _rates[index];
          return Card(
            key: ValueKey(rate.pairId),
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              leading: CircleAvatar(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                child: ClipOval(
                  child: _availableCurrencyIcons.contains(rate.baseCurrency)
                      ? Image.asset(
                          'assets/icon/${rate.baseCurrency}.png',
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        )
                      : Text(
                          rate.baseCurrency.substring(0, 2).toUpperCase(),
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              title: Text(
                '${rate.baseCurrency.toUpperCase()} → ${rate.targetCurrency.toUpperCase()}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Text(
                AppLocalizations.of(
                  context,
                )!.apiAndUpdated(rate.apiName, _formatDate(rate.lastUpdated)),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (rate.hasError)
                    Tooltip(
                      message: AppLocalizations.of(context)!.rateError,
                      child: const Icon(Icons.error_outline, color: Colors.red),
                    )
                  else
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${rate.rate > 10000 ? rate.rate.toStringAsFixed(0) : (rate.rate > 100 ? rate.rate.toStringAsFixed(2) : rate.rate.toStringAsFixed(4))} ${_getCurrencySymbol(rate.targetCurrency)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        if (rate.previousRate != null &&
                            (rate.rate - rate.previousRate!).abs() > 0.00001)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${(rate.rate - rate.previousRate!) > 0 ? "+" : ""}${(rate.rate - rate.previousRate!).toStringAsFixed(4)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: (rate.rate - rate.previousRate!) > 0
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                (rate.rate - rate.previousRate!) > 0
                                    ? Icons.arrow_outward
                                    : Icons.arrow_downward,
                                size: 14,
                                color: (rate.rate - rate.previousRate!) > 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ],
                          )
                        else
                          const Text(
                            '—',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        final prefs = PreferencesService();
                        final pairs = await prefs.getPairs();
                        final pairToEdit = pairs.firstWhere(
                          (p) => p.id == rate.pairId,
                        );
                        if (mounted) {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AddPairScreen(pairToEdit: pairToEdit),
                            ),
                          );
                          if (result == true) _loadRates();
                        }
                      } else if (value == 'delete') {
                        _deletePair(rate.pairId);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text(AppLocalizations.of(context)!.edit),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(AppLocalizations.of(context)!.delete),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getCurrencySymbol(String code) {
    switch (code.toUpperCase()) {
      case 'USD':
        return r'$';
      case 'EUR':
        return '€';
      case 'RUB':
        return '₽';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'CNY':
        return '¥';
      case 'KRW':
        return '₩';
      case 'INR':
        return '₹';
      case 'BRL':
        return r'R$';
      case 'TRY':
        return '₺';
      case 'KZT':
        return '₸';
      default:
        return code;
    }
  }
}
