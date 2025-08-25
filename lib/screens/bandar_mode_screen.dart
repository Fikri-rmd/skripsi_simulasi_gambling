import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:simulasi_slot/utils/game_logic.dart';

class BandarModeScreen extends StatefulWidget {
  const BandarModeScreen({super.key});

  @override
  State<BandarModeScreen> createState() => _BandarModeScreenState();
}

class _BandarModeScreenState extends State<BandarModeScreen> {
  bool _isSimulating = false;
  double _casinoProfit = 0;
  double _playerBalance = 1000;
  final List<FlSpot> _casinoData = [const FlSpot(0, 0)];
  final List<FlSpot> _playerData = [const FlSpot(0, 1000)];
  int _spinCount = 0;

  Future<void> _runSimulation() async {
    setState(() {
      _isSimulating = true;
      _casinoProfit = 0;
      _playerBalance = 1000;
      _casinoData.clear();
      _playerData.clear();
      _casinoData.add(const FlSpot(0, 0));
      _playerData.add(const FlSpot(0, 1000));
      _spinCount = 0;
    });

    for (int i = 1; i <= 500; i++) {
      if (!mounted) return;
      _playerBalance -= 10;
      _casinoProfit += 10;
      _spinCount++;

      final grid = GameLogic.generateSymbols();
      final winLines = GameLogic.checkWinLines(grid);

      if (winLines.isNotEmpty) {
        int totalReward = winLines.fold(0, (sum, line) => sum + line.reward);
        _playerBalance += totalReward;
        _casinoProfit -= totalReward;
      }
      if (i % 20 == 0) {
        setState(() {
          _casinoData.add(FlSpot(i.toDouble(), _casinoProfit));
          _playerData.add(FlSpot(i.toDouble(), max(0, _playerBalance)));
        });
        await Future.delayed(const Duration(milliseconds: 10));
      }
      
      if (_playerBalance <= 0) break;
    }

    setState(() {
      _casinoData.add(FlSpot(_spinCount.toDouble(), _casinoProfit));
      _playerData.add(FlSpot(_spinCount.toDouble(), max(0, _playerBalance)));
      _isSimulating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Simulasi Mode Admin (Bandar)',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Lihat bagaimana keuntungan Admin(bandar) selalu naik dan saldo pemain (simulasi) selalu turun dalam jangka panjang.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 1.5,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _casinoData,
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: _playerData,
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Text('Keuntungan Admin(bandar)', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    Text('${_casinoProfit.toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  children: [
                    const Text('Saldo Pemain', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    Text('${_playerBalance.toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _isSimulating ? null : _runSimulation,
              icon: const Icon(Icons.play_arrow),
              label: Text(_isSimulating ? 'Mensimulasikan...' : 'Mulai 500 Spin Cepat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}