import 'package:firebase_auth101/utils/game_logic.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProbabilitySettingsPage extends StatefulWidget {
  final double initialWinPercentage;
  final int initialMinSpinToWin;
  final Map<String, double> initialSymbolRates;

  const ProbabilitySettingsPage({
    Key? key,
    required this.initialWinPercentage,
    required this.initialMinSpinToWin,
    required this.initialSymbolRates,
  }) : super(key: key);

  @override
  _ProbabilitySettingsPageState createState() => _ProbabilitySettingsPageState();
}

class _ProbabilitySettingsPageState extends State<ProbabilitySettingsPage> {
  late double _winPercentage;
  late int _minSpinToWin;
  late Map<String, double> _symbolRates;

  @override
  void initState() {
    super.initState();
    _winPercentage = widget.initialWinPercentage;
    _minSpinToWin = widget.initialMinSpinToWin;
    _symbolRates = Map<String, double>.from(widget.initialSymbolRates);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade900,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Persentase Kemenangan Umum'),
            _buildWinPercentageSetting(),
            
            const SizedBox(height: 20),
            _buildSectionHeader('Jumlah Spin Minimum untuk Menang'),
            _buildSpinSetting(),
            
            const SizedBox(height: 20),
            _buildSectionHeader('Persentase Kemenangan per Simbol'),
            ..._buildSymbolSettings(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      ),
    );
  }

  Widget _buildWinPercentageSetting() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Slider(
              value: _winPercentage,
              min: 0.0,
              max: 1.0,
              divisions: 100,
              label: '${(_winPercentage * 100).toStringAsFixed(1)}%',
              onChanged: (value) {
                setState(() {
                  _winPercentage = value;
                });
              },
              activeColor: Colors.red,
            ),
            Text('Peluang kemenangan per spin setelah mencapai spin minimum'),
            SizedBox(height: 10),
            Text(
              '${(_winPercentage * 100).toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpinSetting() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Slider(
              value: _minSpinToWin.toDouble(),
              min: 1,
              max: 50,
              divisions: 49,
              label: '$_minSpinToWin',
              onChanged: (value) {
                setState(() {
                  _minSpinToWin = value.toInt();
                });
              },
              activeColor: Colors.red,
            ),
            Text('Jumlah spin minimum sebelum mulai mendapatkan kemenangan'),
          SizedBox(height: 10),
          Text(
            '$_minSpinToWin Spin',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          ],
        ),
      ),
    );
  }

List<Widget> _buildSymbolSettings() {
    return _symbolRates.entries.map((entry) {
      return Card(
        // ... desain sama ...
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                entry.key,
                style: TextStyle(fontSize: 36),
              ),
              SizedBox(height: 10),
              Text(
                'Probabilitas Muncul',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Slider(
                value: entry.value,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                label: '${(entry.value * 100).toStringAsFixed(1)}%',
                onChanged: (value) {
                  setState(() {
                    _symbolRates[entry.key] = value;
                  });
                },
              ),
              Text(
                '${(entry.value * 100).toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                '0% = tidak pernah muncul | 100% = selalu muncul',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }).toList();
}
  void _showSymbolSettingsDialog(String symbol) {
    TextEditingController controller = TextEditingController(
      text: (_symbolRates[symbol]! * 100).toStringAsFixed(1),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Atur Persentase $symbol'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            suffixText: '%',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              final value = double.tryParse(controller.text) ?? 0.0;
              if (value >= 0 && value <= 100) {
                setState(() {
                  _symbolRates[symbol] = value / 100;
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _saveSettings() async {
    // Buat objek settings baru
    final newSettings = GameSettings(
      winPercentage: _winPercentage,
      minSpinToWin: _minSpinToWin,
      symbolRates: _symbolRates,
    );
    
    // Simpan ke SharedPreferences
    await newSettings.saveToPrefs();
    
    // Kembalikan ke halaman sebelumnya
    Navigator.pop(context, newSettings);
  }
}

