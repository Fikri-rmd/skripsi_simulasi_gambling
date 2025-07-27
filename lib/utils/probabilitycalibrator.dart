// probability_calibrator.dart
import 'dart:math';
import 'package:simulasi_slot/utils/game_logic.dart';

class ProbabilityCalibrator {
  final int _windowSize;
  final List<bool> _spinResults = [];
  final Random _random = Random();
  double _targetWinRate;
  int _minSpinToWin;

  ProbabilityCalibrator({
    required double targetWinRate,
    required int minSpinToWin,
    int windowSize = 100,
  })  : _targetWinRate = targetWinRate,
        _minSpinToWin = minSpinToWin,
        _windowSize = windowSize;

  // Update kalibrasi berdasarkan hasil spin terbaru
  void update(bool won) {
    _spinResults.add(won);
    if (_spinResults.length > _windowSize) {
      _spinResults.removeAt(0);
    }
  }

  // Hitung win rate aktual
  double get actualWinRate {
    if (_spinResults.isEmpty) return 0.0;
    final wins = _spinResults.where((w) => w).length;
    return wins / _spinResults.length;
  }

  // Perbaiki probabilitas untuk spin berikutnya
  bool shouldWinNextSpin(int spinCount) {
    // Jangan beri kemenangan jika belum mencapai spin minimum
    if (spinCount < _minSpinToWin) return false;
    
    final actual = actualWinRate;
    final target = _targetWinRate;
    
    // Jika win rate aktual terlalu rendah, tingkatkan kemungkinan menang
    if (actual < target - 0.05) {
      return _random.nextDouble() < (target + 0.1);
    } 
    // Jika win rate aktual terlalu tinggi, turunkan kemungkinan menang
    else if (actual > target + 0.05) {
      return _random.nextDouble() < (target - 0.1);
    }
    
    // Pertahankan probabilitas target
    return _random.nextDouble() < target;
  }

  // Pilih simbol dengan probabilitas tertinggi untuk kemenangan
  String getHighProbabilitySymbol() {
    var highestRate = 0.0;
    String? bestSymbol;
    
    GameLogic.settings.symbolRates.forEach((symbol, rate) {
      if (rate > highestRate) {
        highestRate = rate;
        bestSymbol = symbol;
      }
    });
    
    return bestSymbol ?? GameLogic.settings.symbols.first;
  }

  // Update settings dari GameLogic
  void updateSettings(GameSettings settings) {
    _targetWinRate = settings.winPercentage;
    _minSpinToWin = settings.minSpinToWin;
  }
}