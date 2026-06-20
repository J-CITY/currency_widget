import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../data/local/preferences_service.dart';
import '../data/models/currency_pair.dart';
import '../data/repositories/currency_repository.dart';

class AddPairScreen extends StatefulWidget {
  final CurrencyPair? pairToEdit;

  const AddPairScreen({super.key, this.pairToEdit});

  @override
  State<AddPairScreen> createState() => _AddPairScreenState();
}

class _AddPairScreenState extends State<AddPairScreen> {
  TextEditingController? _baseFieldController;
  TextEditingController? _targetFieldController;
  final _repository = CurrencyRepository(PreferencesService());
  final _prefs = PreferencesService();

  String _selectedApi = 'fawazahmed0';
  List<String> _apis = [];
  bool _isLoading = false;
  
  Map<String, String> _currenciesDict = {};
  bool _isLoadingDict = false;

  @override
  void initState() {
    super.initState();
    _apis = _repository.getAvailableProviders();
    if (widget.pairToEdit != null) {
      if (_apis.contains(widget.pairToEdit!.apiName)) {
        _selectedApi = widget.pairToEdit!.apiName;
      } else if (_apis.isNotEmpty) {
        _selectedApi = _apis.first;
      }
    } else if (_apis.isNotEmpty) {
      _selectedApi = _apis.first;
    }
    _loadDictionary();
  }

  Future<void> _loadDictionary() async {
    setState(() => _isLoadingDict = true);
    try {
      final dict = await _repository.fetchAvailableCurrencies(_selectedApi);
      if (mounted) setState(() => _currenciesDict = dict);
    } catch (e) {
      // Игнорируем ошибку словаря, пользователь сможет ввести вручную
    } finally {
      if (mounted) setState(() => _isLoadingDict = false);
    }
  }

  Future<void> _savePair() async {
    final base = _baseFieldController?.text.trim().toUpperCase() ?? '';
    final target = _targetFieldController?.text.trim().toUpperCase() ?? '';

    if (base.isEmpty || target.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.enterBothCurrencies),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Валидация перед сохранением
      await _repository.testRate(_selectedApi, base, target);

      final newPair = CurrencyPair(
        id:
            widget.pairToEdit?.id ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        baseCurrency: base,
        targetCurrency: target,
        apiName: _selectedApi,
      );

      final currentPairs = await _prefs.getPairs();

      if (widget.pairToEdit != null) {
        final index = currentPairs.indexWhere(
          (p) => p.id == widget.pairToEdit!.id,
        );
        if (index != -1) {
          currentPairs[index] = newPair;
        } else {
          currentPairs.add(newPair);
        }
      } else {
        currentPairs.add(newPair);
      }

      await _prefs.savePairs(currentPairs);

      if (mounted) {
        Navigator.pop(
          context,
          true,
        ); // Возвращаем true, чтобы обновить главный экран
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.saveError(e.toString())),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildAutocomplete(
    String label, 
    String? initialValue, 
    void Function(TextEditingController) onControllerCreated,
  ) {
    return Autocomplete<MapEntry<String, String>>(
      initialValue: TextEditingValue(text: initialValue ?? ''),
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<MapEntry<String, String>>.empty();
        }
        final query = textEditingValue.text.toLowerCase();
        return _currenciesDict.entries.where((entry) {
          return entry.key.toLowerCase().contains(query) || 
                 entry.value.toLowerCase().contains(query);
        });
      },
      displayStringForOption: (MapEntry<String, String> option) => option.key,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        onControllerCreated(controller);
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.attach_money),
            suffixIcon: _isLoadingDict 
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  ) 
                : null,
          ),
          textCapitalization: TextCapitalization.characters,
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 250, maxWidth: 300),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    title: Text(option.key),
                    subtitle: Text(option.value),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.addRateTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAutocomplete(
              AppLocalizations.of(context)!.baseCurrencyLabel,
              widget.pairToEdit?.baseCurrency,
              (controller) => _baseFieldController = controller,
            ),
            const SizedBox(height: 16),
            _buildAutocomplete(
              AppLocalizations.of(context)!.targetCurrencyLabel,
              widget.pairToEdit?.targetCurrency,
              (controller) => _targetFieldController = controller,
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _selectedApi,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.dataSourceLabel,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.cloud_download),
              ),
              items: _apis.map((api) {
                return DropdownMenuItem(value: api, child: Text(api));
              }).toList(),
              onChanged: (val) {
                if (val != null && val != _selectedApi) {
                  setState(() {
                    _selectedApi = val;
                    _currenciesDict.clear();
                  });
                  _loadDictionary();
                }
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _savePair,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Text(
                      AppLocalizations.of(context)!.savePairButton,
                      style: const TextStyle(fontSize: 18),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
