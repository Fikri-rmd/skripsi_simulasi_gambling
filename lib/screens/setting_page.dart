import 'package:flutter/material.dart';
import 'package:firebase_auth101/app_styles.dart';
import 'package:firebase_auth101/size_config.dart';

class ProbabilitySettingsPage2 extends StatefulWidget {
  const ProbabilitySettingsPage2({super.key});

  @override
  _ProbabilitySettingsPageState createState() => _ProbabilitySettingsPageState();
}

class _ProbabilitySettingsPageState extends State<ProbabilitySettingsPage2> {
  // 1. Persentase kemenangan umum
  double _winPercentage = 0.5;
  
  // 2. Jumlah spin minimum untuk menang
  int _minSpinToWin = 5;
  
  // 3. Persentase kemenangan per simbol
  Map<String, double> _symbolWinRates = {
    '🍒': 0.25,
    '🍋': 0.20,
    '💎': 0.15,
    '💰': 0.10,
    '🍊': 0.10,
    '🔔': 0.08,
    '🎲': 0.07,
    '🥇': 0.03,
    '🍇': 0.02,
  };

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengaturan Probabilitas',
            style: kRalewayBold.copyWith(color: kWhite)),
        backgroundColor: kBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: kWhite),
            onPressed: _saveSettings,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Pengaturan Persentase Kemenangan Umum
            _buildSectionHeader('Persentase Kemenangan Umum'),
            _buildWinPercentageSetting(),
            
            SizedBox(height: SizeConfig.blockSizeVertical! * 3),
            
            // 2. Pengaturan Jumlah Spin Minimum untuk Menang
            _buildSectionHeader('Jumlah Spin Minimum untuk Menang'),
            _buildSpinSetting(),
            
            SizedBox(height: SizeConfig.blockSizeVertical! * 3),
            
            // 3. Pengaturan Persentase Kemenangan per Simbol
            _buildSectionHeader('Persentase Kemenangan per Simbol'),
            ..._buildSymbolSettings(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: SizeConfig.blockSizeVertical! * 1.5),
      child: Text(title,
          style: kRalewayBold.copyWith(
              fontSize: SizeConfig.blockSizeHorizontal! * 4.5,
              color: kBlue)),
    );
  }

  // 1. Widget untuk pengaturan persentase kemenangan umum
  Widget _buildWinPercentageSetting() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 4),
        child: Column(
          children: [
            Slider(
              value: _winPercentage,
              min: 0.0,
              max: 1.0,
              divisions: 20,
              label: '${(_winPercentage * 100).toStringAsFixed(0)}%',
              onChanged: (value) {
                setState(() {
                  _winPercentage = value;
                });
              },
              activeColor: kBlue,
            ),
            Text(
              '${(_winPercentage * 100).toStringAsFixed(0)}% peluang kemenangan per spin',
              style: kRalewayRegular,
            ),
          ],
        ),
      ),
    );
  }

  // 2. Widget untuk pengaturan spin minimum
  Widget _buildSpinSetting() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 4),
        child: Column(
          children: [
            Slider(
              value: _minSpinToWin.toDouble(),
              min: 1,
              max: 20,
              divisions: 19,
              label: '$_minSpinToWin Spin',
              onChanged: (value) {
                setState(() {
                  _minSpinToWin = value.toInt();
                });
              },
              activeColor: kBlue,
            ),
            Text(
              'Minimum $_minSpinToWin spin untuk mendapatkan kemenangan',
              style: kRalewayRegular,
            ),
          ],
        ),
      ),
    );
  }

  // 3. Widget untuk pengaturan persentase per simbol
  List<Widget> _buildSymbolSettings() {
    return _symbolWinRates.entries.map((entry) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical! * 2),
        child: Padding(
          padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 4),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${entry.key} : ${(entry.value * 100).toStringAsFixed(1)}%',
                    style: kRalewayMedium.copyWith(fontSize: 18),
                  ),
                  IconButton(
                    icon: Icon(Icons.tune),
                    onPressed: () => _showSymbolSettingsDialog(entry.key),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  void _showSymbolSettingsDialog(String symbol) {
    TextEditingController controller = TextEditingController(
      text: (_symbolWinRates[symbol]! * 100).toStringAsFixed(1),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Atur Persentase $symbol'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            suffixText: '%',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              final value = double.tryParse(controller.text) ?? 0.0;
              if (value >= 0 && value <= 100) {
                setState(() {
                  _symbolWinRates[symbol] = value / 100;
                });
              }
              Navigator.pop(context);
            },
            child: Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: Icon(Icons.check_circle, color: Colors.green, size: 40),
          title: Text(
            'Berhasil Disimpan',
            style: kRalewayBold.copyWith(
              fontSize: SizeConfig.blockSizeHorizontal! * 4.5,
              color: kBlue,
            ),
          ),
          content: Text(
            'Pengaturan probabilitas telah berhasil diperbarui',
            style: kRalewayMedium.copyWith(
              fontSize: SizeConfig.blockSizeHorizontal! * 4,
            ),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Mengerti',
                style: kRalewayMedium.copyWith(
                  color: kBlue,
                  fontSize: SizeConfig.blockSizeHorizontal! * 4,
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        );
      },
    );
  }
}