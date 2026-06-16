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
  final _baseController = TextEditingController();
  final _targetController = TextEditingController();
  final _repository = CurrencyRepository(PreferencesService());
  final _prefs = PreferencesService();

  String _selectedApi = 'fawazahmed0';
  List<String> _apis = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _apis = _repository.getAvailableProviders();
    if (widget.pairToEdit != null) {
      _baseController.text = widget.pairToEdit!.baseCurrency;
      _targetController.text = widget.pairToEdit!.targetCurrency;
      if (_apis.contains(widget.pairToEdit!.apiName)) {
        _selectedApi = widget.pairToEdit!.apiName;
      } else if (_apis.isNotEmpty) {
        _selectedApi = _apis.first;
      }
    } else if (_apis.isNotEmpty) {
      _selectedApi = _apis.first;
    }
  }

  Future<void> _savePair() async {
    final base = _baseController.text.trim().toUpperCase();
    final target = _targetController.text.trim().toUpperCase();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.addRateTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _baseController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.baseCurrencyLabel,
                border: const OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _targetController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.targetCurrencyLabel,
                border: const OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _selectedApi,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.dataSourceLabel,
                border: const OutlineInputBorder(),
                prefixIcon: Icon(Icons.cloud_download),
              ),
              items: _apis.map((api) {
                return DropdownMenuItem(value: api, child: Text(api));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedApi = val);
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _savePair,
              style: ElevatedButton.styleFrom(
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
