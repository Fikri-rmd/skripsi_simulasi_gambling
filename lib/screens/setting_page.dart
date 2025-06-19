import 'package:firebase_auth101/providers/game_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProbabilitySettingsPage extends StatefulWidget {
  const ProbabilitySettingsPage({super.key});

  @override
  State<ProbabilitySettingsPage> createState() => _ProbabilitySettingsPageState();
}

class _ProbabilitySettingsPageState extends State<ProbabilitySettingsPage> 
  with TickerProviderStateMixin{
  late List<Map<String, dynamic>> _editedProbabilities;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<GameSettingsProvider>(context, listen: false);
    _editedProbabilities = provider.symbolProbabilities.map((e) => 
      {'symbol': e['symbol'], 'weight': e['weight'].toDouble()}).toList();
  }

  double get _totalWeight => _editedProbabilities.fold(
    0.0, 
    (sum, item) => sum + item['weight']
  );

  void _saveSettings() {
    final newProbabilities = _editedProbabilities.map((e) => 
      {'symbol': e['symbol'], 'weight': e['weight'].round()}).toList();
    
    Provider.of<GameSettingsProvider>(context, listen: false)
      .updateProbabilities(newProbabilities);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Probability Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Adjust Symbol Probabilities', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: _editedProbabilities.length,
                itemBuilder: (context, index) {
                  final symbol = _editedProbabilities[index];
                  final percentage = _totalWeight == 0 ? 0 : 
                    (symbol['weight'] / _totalWeight * 100);

                  return ListTile(
                    title: Text(symbol['symbol'], 
                      style: const TextStyle(fontSize: 24)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Slider(
                          value: symbol['weight'],
                          min: 0,
                          max: 100,
                          divisions: 100,
                          label: symbol['weight'].round().toString(),
                          onChanged: (value) => setState(() => 
                            symbol['weight'] = value),
                        ),
                        Text('Probability: ${percentage.toStringAsFixed(1)}%'),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}