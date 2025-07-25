import 'package:simulasi_slot/utils/game_logic.dart';
import 'package:flutter/material.dart';
import 'package:simulasi_slot/utils/spin_preparer.dart';


class ProbabilitySettingsPage extends StatefulWidget {
  final double initialWinPercentage;
  final int initialMinSpinToWin;
  final Map<String, double> initialSymbolRates;
  final VoidCallback? onSettingsUpdated;

  const ProbabilitySettingsPage({
    Key? key,
    required this.initialWinPercentage,
    required this.initialMinSpinToWin,
    required this.initialSymbolRates,
    this.onSettingsUpdated,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ProbabilitySettingsPageState createState() => _ProbabilitySettingsPageState();
}

class _ProbabilitySettingsPageState extends State<ProbabilitySettingsPage> {
  late double _winPercentage;
  late int _minSpinToWin;
  late Map<String, double> _symbolRates;
  // late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _winPercentage = widget.initialWinPercentage;
    _minSpinToWin = widget.initialMinSpinToWin;
    _symbolRates = Map<String, double>.from(widget.initialSymbolRates);
  }
  void _resetToDefaultSettings() {
  setState(() {
    _winPercentage = 0.5;
    _minSpinToWin = 5;
    _symbolRates = {
      '🍒': 0.30, '🍋': 0.30, '💎': 0.10, '💰': 0.10,
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Hapus AppBar dari sini
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
            // Tombol kembali di bagian atas
            // Padding(
            //   padding: const EdgeInsets.only(bottom: 20),
            //   child: IconButton(
            //     icon: const Icon(Icons.arrow_back, size: 30),
            //     onPressed: () => Navigator.pop(context),
            //   ),
            // ),
            
            _buildSectionHeader('Persentase Kemenangan Umum'),
            _buildWinPercentageSetting(),
            
            const SizedBox(height: 10),
            _buildSectionHeader('Jumlah Spin Minimum untuk Menang'),
            _buildSpinSetting(),
            
            const SizedBox(height: 10),
            _buildSectionHeader('Persentase Kemunculan per Simbol'),
            ..._buildSymbolSettings(),
            
            // Tombol simpan di bagian bawah
            Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 20),
              child: Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save, size: 24),
                  label: const Text('SIMPAN', 
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade900,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
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
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
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
            const Text('Peluang kemenangan per spin setelah mencapai spin minimum'),
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
            const SizedBox(height: 8),
            const Text('Jumlah spin minimum sebelum mulai mendapatkan kemenangan'),
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
                  setState(() {
                    if (value == 1.0) {
        // Set simbol lain jadi 0.0
        _symbolRates.updateAll((key, _) => key == entry.key ? 1.0 : 0.0);
      } else {
                    _symbolRates[entry.key] = value;
                  }});
                },
              ),
              Text(
                '${(entry.value * 100).toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                '0% = tidak pernah muncul | 100% = selalu muncul',
                style: TextStyle(fontSize: 12, color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

 Future <void> _saveSettings() async {
    try {
      double totalProbability = _symbolRates.values.fold(0.0, (sum, rate) => sum + rate);
      int activeSymbolCount = _symbolRates.values.where((rate) => rate > 0).length;
    if (totalProbability <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Total probabilitas tidak boleh 0%!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    } 
    if (activeSymbolCount < 5){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimal 5 simbol harus memiliki probabilitas > 0%!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    final fullSymbols = _symbolRates.entries.where((e) => e.value == 1.0).toList();
    if (fullSymbols.length > 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hanya boleh ada 1 simbol dengan probabilitas 100%!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;  
    }
     // Buat objek settings baru
    final newSettings = GameSettings(
      winPercentage: _winPercentage,
      minSpinToWin: _minSpinToWin,
      symbolRates: _symbolRates,
    );
    
    // Simpan ke SharedPreferences
    await newSettings.saveToPrefs();
    GameLogic.updateSettings(newSettings);
    widget.onSettingsUpdated?.call(); 
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengaturan berhasil disimpan!'),
          duration: Duration(seconds: 2),
        ),
      );
    await Future.delayed(const Duration(milliseconds: 500));

    // Kembalikan ke halaman sebelumnya
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan pengaturan: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
    // Navigator.pop(context, newSettings);
  }
}