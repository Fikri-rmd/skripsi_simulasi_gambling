import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WinLine {
  final String lineType;
  final String symbol;
  final int reward;
  final int? row;
  final int? col;
  final int? startRow;
  final int? endRow;
  final int? startCol;
  final int? endCol;
  final String? direction;

  WinLine({
    required this.lineType,
    required this.symbol,
    required this.reward,
    this.row,
    this.col,
    this.startRow,
    this.endRow,
    this.startCol,
    this.endCol,
    this.direction,
  });
}

class GameSettings {
  double winPercentage;
  int minSpinToWin;
  Map<String, double> symbolRates;

  GameSettings({
    required this.winPercentage,
    required this.minSpinToWin,
    required this.symbolRates,
  });

  void validateSymbolRates() {

    // Tetap validasi jika total > 0
  final total = symbolRates.values.fold(0.0, (sum, rate) => sum + rate);

  // Jika totalnya 0, itu error
  if (total == 0.0) {
    throw Exception("Symbol rates total must be > 0");
  }

    // Jika ada simbol 100%, jangan normalisasi
  // final hasFullSymbol = symbolRates.values.any((rate) => rate == 1.0);
  // if (hasFullSymbol) return;

  // final total = symbolRates.values.fold(0.0, (sum, rate) => sum + rate);
  // if (total != 1.0 && total > 0.0) {
  //   final newRates = <String, double>{};
  //   symbolRates.forEach((symbol, rate) {
  //     newRates[symbol] = rate / total;
  //   });
  //   symbolRates = newRates;
  // }
  }

  Future<void> saveToPrefs() async {
    validateSymbolRates();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('winPercentage', winPercentage);
    await prefs.setInt('minSpinToWin', minSpinToWin);
    
    for (var entry in symbolRates.entries) {
      await prefs.setDouble('symbol_${entry.key}', entry.value);
    }
  }

  static Future<GameSettings> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    double winPercentage = prefs.getDouble('winPercentage') ?? 0.5;
    int minSpinToWin = prefs.getInt('minSpinToWin') ?? 5;
    
    Map<String, double> defaultRates = {
      '🍒': 0.30, '🍋': 0.30, '💎': 0.10, '💰': 0.10,
      '🍊': 0.20,
    };
    
    Map<String, double> symbolRates = {};
    for (String symbol in defaultRates.keys) {
      symbolRates[symbol] = prefs.getDouble('symbol_$symbol') ?? defaultRates[symbol]!;
    }
    
    return GameSettings(
      winPercentage: winPercentage,
      minSpinToWin: minSpinToWin,
      symbolRates: symbolRates,
    )..validateSymbolRates();
  }

  GameSettings copyWith({
    double? winPercentage,
    int? minSpinToWin,
    Map<String, double>? symbolRates,
  }) {
    return GameSettings(
      winPercentage: winPercentage ?? this.winPercentage,
      minSpinToWin: minSpinToWin ?? this.minSpinToWin,
      symbolRates: symbolRates ?? Map.from(this.symbolRates),
    );
  }
}

class GameLogic {
  static final Random _random = Random();
  static GameSettings settings = GameSettings(
    winPercentage: 0.5,
    minSpinToWin: 5,
    symbolRates: {
      '🍒': 0.30, '🍋': 0.30, '💎': 0.10, '💰': 0.10,
      '🍊': 0.20,
    },
  )..validateSymbolRates();

  // Statistik win rate
  static int _totalSpins = 0;
  static int _totalWins = 0;

  static double get actualWinRate {
    if (_totalSpins == 0) return 0.0;
    return _totalWins / _totalSpins;
  }

  static void resetStats() {
    _totalSpins = 0;
    _totalWins = 0;
  }

  static void updateSettings(GameSettings newSettings) {
    settings = newSettings;
    settings.validateSymbolRates();
  }

  // Simbol dengan probabilitas 100%
  static String? _getFullRateSymbol() {
    for (var entry in settings.symbolRates.entries) {
      if (entry.value == 1.0) return entry.key;
    }
    return null;
  }

  // Simbol dengan probabilitas tertinggi
  static String _getHighestProbabilitySymbol() {
    return settings.symbolRates.entries.reduce((a, b) => 
        a.value > b.value ? a : b).key;
  }

  // Untuk kemenangan, gunakan simbol khusus
  static String getSymbolForWin() {
    final fullSymbol = _getFullRateSymbol();
    return fullSymbol ?? _getHighestProbabilitySymbol();
  }

  // Generate simbol dengan mempertimbangkan probabilitas
  static String getRandomSymbol() {
    final fullSymbol = _getFullRateSymbol();
    final filteredRates = (fullSymbol != null
      ? (Map<String, double>.from(settings.symbolRates)
          ..removeWhere((key, _) => key == fullSymbol))
      : settings.symbolRates);


    double totalWeight = filteredRates.values.fold(0.0, (sum, w) => sum + w);
    double randomNumber = _random.nextDouble() * totalWeight;
    double cumulative = 0.0;
    
    for (var entry in filteredRates.entries) {
      cumulative += entry.value;
      if (randomNumber < cumulative) {
        return entry.key;
      }
    }
    
    return filteredRates.keys.first;
  }

  // Hitung probabilitas yang disesuaikan
  static bool shouldWin(int spinCount) {
    if (settings.winPercentage == 0.0) return false;
    if (spinCount < settings.minSpinToWin) return false;
    
    final adjustedProbability = _calculateAdjustedProbability();
    return _random.nextDouble() < adjustedProbability;
  }

  static double _calculateAdjustedProbability() {
    final highProbSymbol = _getHighestProbabilitySymbol();
    final highProbRate = settings.symbolRates[highProbSymbol]!;
    final boostFactor = pow(highProbRate, 2).clamp(1.0, 1.5);
    
    return settings.winPercentage * boostFactor;
  }

  // Generate grid simbol
  static List<List<String>> generateSymbols({int spinCount = 0}) {
  bool isWin = shouldWin(spinCount);
  final fullSymbol = _getFullRateSymbol();

  if (isWin && fullSymbol != null) {
    return generateForcedWinGridWithSymbol(fullSymbol);
  }

  return List.generate(4, (row) {
    return List.generate(4, (col) => getRandomSymbol());
  });
}
  static List<List<String>> generateForcedWinGridWithSymbol(String symbol) {
  List<List<String>> grid = List.generate(4, (row) {
    return List.generate(4, (col) => getRandomSymbol());
  });

  final rand = _random.nextInt(10);
  String type;
  int pos;

  if (rand < 4) {
    type = 'horizontal';
    pos = _random.nextInt(4);
  } else if (rand < 8) {
    type = 'vertical';
    pos = _random.nextInt(4);
  } else {
    type = 'diagonal';
    pos = _random.nextInt(2); // 0: main, 1: anti
  }

  final pattern = generateForcedWinPattern(symbol, type, pos);

  // Replace winning line only
  switch (type) {
    case 'horizontal':
      grid[pos] = List.filled(4, symbol);
      break;
    case 'vertical':
      for (int r = 0; r < 4; r++) {
        grid[r][pos] = symbol;
      }
      break;
    case 'diagonal':
      if (pos == 0) {
        for (int i = 0; i < 4; i++) grid[i][i] = symbol;
      } else {
        for (int i = 0; i < 4; i++) grid[i][3 - i] = symbol;
      }
      break;
  }

  return grid;
}


  static List<List<String>> generateGuaranteedWinGridForFullRateSymbol(String symbol) {
  final rand = _random.nextInt(10);
  late String type;
  int pos;

  if (rand < 4) {
    type = 'horizontal';
    pos = _random.nextInt(4);
  } else if (rand < 8) {
    type = 'vertical';
    pos = _random.nextInt(4);
  } else {
    type = 'diagonal';
    pos = _random.nextInt(2); // 0=main, 1=anti
  }

  return generateForcedWinPattern(symbol, type, pos);
}

  // Cek pola kemenangan
  static List<WinLine> checkWinLines(List<List<String>> grid) {
    List<WinLine> winLines = [];
    final baseRewards = {
      '🍒': 3, '🍋': 4, '💎': 10, '💰': 15,
      '🍊': 5,
    };
    
    // Horizontal
    for (int row = 0; row < 4; row++) {
      String symbol = grid[row][0];
      if (symbol == '🎰') continue;
      bool win = true;
      for (int col = 1; col < 4; col++) {
        if (grid[row][col] != symbol) {
          win = false;
          break;
        }
      }
      if (win) {
        winLines.add(WinLine(
          lineType: 'horizontal',
          row: row,
          symbol: symbol,
          reward: baseRewards[symbol]! * 4,
        ));
      }
    }
   
    // Vertical
    for (int col = 0; col < 4; col++) {
      String symbol = grid[0][col];
      if (symbol == '🎰') continue;
      bool win = true;
      for (int row = 1; row < 4; row++) {
        if (grid[row][col] != symbol) {
          win = false;
          break;
        }
      }
      if (win) {
        winLines.add(WinLine(
          lineType: 'vertical',
          col: col,
          symbol: symbol,
          reward: baseRewards[symbol]! * 4,
        ));
      }
    }
    
    // Diagonal (top-left to bottom-right)
    String mainDiagSymbol = grid[0][0];
    bool mainDiagWin = mainDiagSymbol != '🎰';
    for (int i = 1; i < 4; i++) {
      if (grid[i][i] != mainDiagSymbol) {
        mainDiagWin = false;
        break;
      }
    }
    if (mainDiagWin) {
      winLines.add(WinLine(
        lineType: 'diagonal',
        symbol: mainDiagSymbol,
        direction: 'down-right',
        reward: baseRewards[mainDiagSymbol]! * 4,
      ));
    }
    
    // Diagonal (top-right to bottom-left)
    String antiDiagSymbol = grid[0][3];
    bool antiDiagWin = antiDiagSymbol != '🎰';
    for (int i = 1; i < 4; i++) {
      if (grid[i][3-i] != antiDiagSymbol) {
        antiDiagWin = false;
        break;
      }
    }
    if (antiDiagWin) {
      winLines.add(WinLine(
        lineType: 'diagonal',
        symbol: antiDiagSymbol,
        direction: 'down-left',
        reward: baseRewards[antiDiagSymbol]! * 4,
      ));
    }
    
    return winLines;
  }

  // Untuk memaksa kemenangan dengan pola tertentu
  static List<List<String>> generateForcedWinPattern(
    String winSymbol,
    String winType,
    int position,
  ) {
    final newGrid = List.generate(4, (row) => List.generate(4, (col) => getRandomSymbol()));

    switch (winType) {
      case 'horizontal':
        for (int col = 0; col < 4; col++) {
          newGrid[position][col] = winSymbol;
        }
        break;
      case 'vertical':
        for (int row = 0; row < 4; row++) {
          newGrid[row][position] = winSymbol;
        }
        break;
      case 'diagonal':
        if (position == 0) {
          for (int i = 0; i < 4; i++) {
            newGrid[i][i] = winSymbol;
          }
        } else {
          for (int i = 0; i < 4; i++) {
            newGrid[i][3 - i] = winSymbol;
          }
        }
        break;
    }
    
    return newGrid;
  }

  // Warna latar untuk simbol
  static Color getSymbolColor(String symbol) {
    switch (symbol) {
      case '🍒': return Colors.pink.shade100;
      case '🍋': return Colors.yellow.shade100;
      case '💎': return Colors.blue.shade100;
      case '💰': return Colors.green.shade100;
      case '🍊': return Colors.orange.shade100;
      // case '🔔': return Colors.amber.shade100;
      // case '🎲': return Colors.deepPurple.shade100;
      // case '🥇': return Colors.amber.shade300;
      // case '🍇': return Colors.purple.shade100;
      default: return Colors.grey.shade200;
    }
  }

  // Update statistik setelah spin
  static void updateStats(bool won) {
    _totalSpins++;
    if (won) _totalWins++;
  }

  static void resetSettings() {
    settings = GameSettings(
      winPercentage: 0.5,
      minSpinToWin: 5,
      symbolRates: {
        '🍒': 0.30, '🍋': 0.30, '💎': 0.10, '💰': 0.10,
      '🍊': 0.20,
      },
    )..validateSymbolRates();
  }

  // Helper untuk UI
  static bool isInForceWinPattern(int row, int col, String? winType, int? position) {
    if (winType == null || position == null) return false;

    switch (winType) {
      case 'horizontal':
        return row == position;
      case 'vertical':
        return col == position;
      case 'diagonal':
        if (position == 0) return row == col;
        return row + col == 3;
      default:
        return false;
    }
  }
}                     