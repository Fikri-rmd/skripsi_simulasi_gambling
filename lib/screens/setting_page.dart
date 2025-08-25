import 'package:flutter/material.dart';
import 'package:simulasi_slot/utils/game_logic.dart';

class ProbabilitySettingsPage extends StatefulWidget {
  final double initialWinPercentage;
  final int initialMinSpinToWin;
  final Map<String, double> initialSymbolRates;
  final VoidCallback? onSettingsUpdated;
  final VoidCallback? onSaveAndSwitchToSlot;

  const ProbabilitySettingsPage({
    Key? key,
    required this.initialWinPercentage,
    required this.initialMinSpinToWin,
    required this.initialSymbolRates,
    this.onSettingsUpdated,
    this.onSaveAndSwitchToSlot,
  }) : super(key: key);

  @override
  _ProbabilitySettingsPageState createState() =>
      _ProbabilitySettingsPageState();
}

class _ProbabilitySettingsPageState extends State<ProbabilitySettingsPage> {
  late double _winPercentage;
  late int _minSpinToWin;
  late Map<String, double> _symbolRates;

  final Map<String, int> symbolRewards = {
    '🍒': 3,
    '🍋': 4,
    '🍊': 5,
    '💎': 10,
    '💰': 15,
  };
  @override
  void initState() {
    super.initState();
    _winPercentage = widget.initialWinPercentage;
    _minSpinToWin = widget.initialMinSpinToWin;
    _symbolRates = Map<String, double>.from(widget.initialSymbolRates);
  }

  double get _totalSymbolRate =>
      _symbolRates.values.fold(0.0, (a, b) => a + b);

  void _resetToDefaultSettings() {
    setState(() {
      _winPercentage = 0.2;
      _minSpinToWin = 5;
      _symbolRates = {
        '🍒': 0.25, '🍋': 0.25, '💎': 0.15, '💰': 0.15,
        '🍊': 0.20,
      };
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengaturan telah di-reset ke default.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

void _adjustSymbolRates(String changedKey, double newValue) {
  setState(() {
    final double oldValue = _symbolRates[changedKey]!;
    int budgetInChunks = ((oldValue - newValue) / 0.05).round();
    if (budgetInChunks == 0) return;
    _symbolRates[changedKey] = newValue;
    List<String> candidates;
    if (budgetInChunks > 0) { 
      candidates = _symbolRates.keys
          .where((k) => k != changedKey && _symbolRates[k]! < 1.0)
          .toList();
      candidates.sort((a, b) => _symbolRates[a]!.compareTo(_symbolRates[b]!));
    } else { 
      candidates = _symbolRates.keys
          .where((k) => k != changedKey && _symbolRates[k]! > 0.0)
          .toList();
      candidates.sort((a, b) => _symbolRates[b]!.compareTo(_symbolRates[a]!));
    }

    if (candidates.isEmpty) return; 

    int chunksToDistribute = budgetInChunks.abs();
    for (int i = 0; i < chunksToDistribute; i++) {
      String keyToAdjust = candidates[i % candidates.length];
      
      double change = (budgetInChunks > 0) ? 0.05 : -0.05;
      _symbolRates[keyToAdjust] = (_symbolRates[keyToAdjust]! + change).clamp(0.0, 1.0);
    }

    final double currentSum = _symbolRates.values.fold(0.0, (a, b) => a + b);
    if ((currentSum - 1.0).abs() > 0.001) {
       String? maxKey;
       double maxValue = -1;
       _symbolRates.forEach((key, value) {
         if (value > maxValue) {
           maxValue = value;
           maxKey = key;
         }
       });
       if(maxKey != null) {
          _symbolRates[maxKey!] = (_symbolRates[maxKey]! + (1.0 - currentSum));
       }
    }
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'PERINGATAN: Dalam judi sungguhan, Anda TIDAK BISA mengubah pengaturan ini. '
                'Kasino selalu mengatur mesin untuk menguntungkan mereka (RTP < 100%). '
                'Simulasi ini hanya untuk menunjukkan bagaimana pemain selalu dirugikan dalam jangka panjang.',
                style: TextStyle(color: Colors.red, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionHeader('Persentase Kemenangan Umum'),
            _buildWinPercentageSetting(),
            const SizedBox(height: 10),
            _buildSectionHeader('Jumlah Spin Minimum untuk Menang'),
            _buildSpinSetting(),
            const SizedBox(height: 10),
            _buildSectionHeader('Persentase Kemunculan per Simbol'),
            _buildTotalProbabilityIndicator(),
            ..._buildSymbolSettings(),
            Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 20),
              child: Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save, size: 24),
                  label: const Text('SIMPAN',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade900,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 24),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _saveSettings,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.restore, size: 24),
                  label: const Text(
                    'RESET',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _resetToDefaultSettings,
                ),
              ),
            ),
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

  Widget _buildTotalProbabilityIndicator() {
    final total = _totalSymbolRate;
    final isTotalValid = (total - 1.0).abs() < 0.001;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isTotalValid ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isTotalValid ? Colors.green.shade300 : Colors.red.shade300,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Probabilitas:',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isTotalValid
                    ? Colors.green.shade800
                    : Colors.red.shade800),
          ),
          Text(
            '${(total * 100).toStringAsFixed(0)}%',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isTotalValid
                    ? Colors.green.shade800
                    : Colors.red.shade800),
          ),
        ],
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
              divisions: 20,
              label: '${(_winPercentage * 100).toStringAsFixed(1)}%',
              onChanged: (value) {
                setState(() {
                  _winPercentage = value;
                });
              },
              activeColor: Colors.red,
            ),
            const SizedBox(height: 8),
            const Text(
                'Peluang kemenangan per spin setelah mencapai spin minimum'),
            const SizedBox(height: 10),
            Text(
              '${(_winPercentage * 100).toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
              min: 0,
              max: 25,
              divisions: 25,
              label: '$_minSpinToWin',
              onChanged: (value) {
                setState(() {
                  _minSpinToWin = value.toInt();
                });
              },
              activeColor: Colors.red,
            ),
            const SizedBox(height: 8),
            const Text(
                'Jumlah spin minimum sebelum mulai mendapatkan kemenangan'),
            const SizedBox(height: 10),
            Text(
              '$_minSpinToWin Spin',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSymbolSettings() {
    return _symbolRates.entries.map((entry) {
      return Card(
        margin: const EdgeInsets.only(bottom: 10),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Text(
                entry.key,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 5),
              const Text(
                'Probabilitas Muncul',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Slider(
                activeColor: Colors.red,
                value: entry.value,
                min: 0.0,
                max: 1.0,
                divisions: 20,
                label: '${(entry.value * 100).toStringAsFixed(1)}%',
                onChanged: (value) {
                  _adjustSymbolRates(entry.key, value);
                },
              ),
              Text(
                '${(entry.value * 100).toStringAsFixed(1)}%',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Future<void> _showValidationDialog(String message) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pengaturan Tidak Valid'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('MENGERTI',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.red)),
          )
        ],
      ),
    );
  }

  Future<void> _saveSettings() async {
    final totalProbability = _totalSymbolRate;
    if ((totalProbability - 1.0).abs() > 0.001) {
      _showValidationDialog(
          'Total probabilitas semua simbol harus tepat 100%. Saat ini totalnya adalah ${(totalProbability * 100).toStringAsFixed(0)}%.');
      return;
    }
    final activeSymbols = _symbolRates.values.where((v) => v > 0).length;
    if (_winPercentage < 1.0 && activeSymbols < 2) {
      _showValidationDialog(
          'Pengaturan tidak valid: Mustahil menghasilkan kekalahan jika hanya ada satu simbol aktif. Naikkan persentase kemenangan menjadi 100% atau aktifkan simbol kedua.');
      return;
    }

    try {
      final newSettings = GameSettings(
        winPercentage: _winPercentage,
        minSpinToWin: _minSpinToWin,
        symbolRates: _symbolRates,
      );

      await newSettings.saveToPrefs();
      GameLogic.updateSettings(newSettings);
      Future.microtask(() {
        widget.onSettingsUpdated?.call();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengaturan berhasil disimpan!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      widget.onSaveAndSwitchToSlot?.call();
    } catch (e) {
      final errorMessage = e.toString().replaceAll("Exception: ", "");
      _showValidationDialog(errorMessage);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan pengaturan: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}