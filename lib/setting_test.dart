import 'package:flutter/material.dart';
import 'app_styles.dart';
import 'size_config.dart';

class ProbabilitySettingsPage2 extends StatefulWidget {
  const ProbabilitySettingsPage2({super.key});

  @override
  _ProbabilitySettingsPageState createState() => _ProbabilitySettingsPageState();
}

class _ProbabilitySettingsPageState extends State<ProbabilitySettingsPage2> {
  double _minProbability = 0.3;
  double _maxProbability = 0.7;
  bool _enableAutoAdjust = true;
  double _threshold = 0.5;
  double _sensitivity = 0.8;
  int _minSpinToWin = 5;
  Map<String, double> _symbolWinRates = {
    '🍒': 0.25,
    '🍋': 0.20,
    '💎': 0.15,
    '💰': 0.10,
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
            _buildSectionHeader('Rentang Probabilitas Umum'),
            _buildRangeSlider(),
            
            SizedBox(height: SizeConfig.blockSizeVertical! * 3),
            _buildSectionHeader('Jumlah Spin Minimum untuk Menang'),
            _buildSpinSetting(),
            
            SizedBox(height: SizeConfig.blockSizeVertical! * 3),
            _buildSectionHeader('Persentase Kemenangan per Simbol'),
            ..._buildSymbolSettings(),
            
            SizedBox(height: SizeConfig.blockSizeVertical! * 3),
            _buildSectionHeader('Pengaturan Lanjutan'),
            _buildToggleSwitch(),
            _buildThresholdSetting(),
            _buildSensitivitySetting(),
            
            SizedBox(height: SizeConfig.blockSizeVertical! * 2),
            _buildInfoMessage(),
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

  Widget _buildRangeSlider() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 4),
        child: Column(
          children: [
            RangeSlider(
              values: RangeValues(_minProbability, _maxProbability),
              min: 0.0,
              max: 1.0,
              divisions: 20,
              labels: RangeLabels(
                'Min: ${(_minProbability * 100).toStringAsFixed(0)}%',
                'Max: ${(_maxProbability * 100).toStringAsFixed(0)}%',
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  _minProbability = values.start;
                  _maxProbability = values.end;
                });
              },
              activeColor: kBlue,
              inactiveColor: Colors.grey[200],
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _buildToggleSwitch() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Penyesuaian Otomatis',
                style: kRalewayMedium.copyWith(
                    fontSize: SizeConfig.blockSizeHorizontal! * 4)),
            Switch(
              value: _enableAutoAdjust,
              onChanged: (value) => setState(() => _enableAutoAdjust = value),
              activeColor: kWhite,
              activeTrackColor: kBlue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThresholdSetting() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ambang Batas Kemenangan',
                style: kRalewayMedium.copyWith(
                    fontSize: SizeConfig.blockSizeHorizontal! * 4)),
            Slider(
              value: _threshold,
              min: 0.0,
              max: 1.0,
              divisions: 20,
              label: '${(_threshold * 100).toStringAsFixed(0)}%',
              onChanged: (value) => setState(() => _threshold = value),
              activeColor: _getThresholdColor(_threshold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensitivitySetting() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sensitivitas Mesin',
                      style: kRalewayMedium.copyWith(fontSize: 16)),
                  Text('(Semakin tinggi semakin sering menang)',
                      style: kRalewayRegular.copyWith(color: Colors.grey)),
                ],
              ),
            ),
            SizedBox(width: SizeConfig.blockSizeHorizontal! * 4),
            Container(
              width: SizeConfig.blockSizeHorizontal! * 20,
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  suffixText: '%',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(
                    text: '${(_sensitivity * 100).toStringAsFixed(0)}'),
                onChanged: (value) {
                  final parsed = double.tryParse(value);
                  if (parsed != null && parsed >= 0 && parsed <= 100) {
                    setState(() => _sensitivity = parsed / 100);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoMessage() {
    return Container(
      padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 4),
      decoration: BoxDecoration(
        color: kBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(Icons.info, color: kBlue),
          SizedBox(width: SizeConfig.blockSizeHorizontal! * 3),
          Expanded(
            child: Text(
              'Pengaturan sensitivitas tinggi dapat meningkatkan frekuensi kemenangan palsu',
              style: kRalewayRegular.copyWith(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Color _getThresholdColor(double value) {
    if (value < 0.3) return Colors.green;
    if (value < 0.6) return Colors.orange;
    return Colors.red;
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
      ));
    },
  );
}
}