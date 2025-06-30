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
  double winPercentage;  // Persentase kemenangan umum
  int minSpinToWin;      // Spin minimum untuk mulai memberikan kemenangan
  Map<String, double> symbolRates; // Probabilitas munculnya simbol

  GameSettings({
    required this.winPercentage,
    required this.minSpinToWin,
    required this.symbolRates,
  });

  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('winPercentage', winPercentage);
    await prefs.setInt('minSpinToWin', minSpinToWin);
    
    // Simpan setiap simbol
    for (var entry in symbolRates.entries) {
      await prefs.setDouble('symbol_${entry.key}', entry.value);
    }
  }

  static Future<GameSettings> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    double winPercentage = prefs.getDouble('winPercentage') ?? 0.5;
    int minSpinToWin = prefs.getInt('minSpinToWin') ?? 5;
    
    // Default rates
    Map<String, double> defaultRates = {
      '🍒': 0.40,
      '🍋': 0.30,
      '💎': 0.10,
      '💰': 0.10,
      '🍊': 0.30,
      '🔔': 0.25,
      '🎲': 0.30,
      '🥇': 0.25,
      '🍇': 0.35,
    };
    
    Map<String, double> symbolRates = {};
    for (String symbol in defaultRates.keys) {
      symbolRates[symbol] = prefs.getDouble('symbol_$symbol') ?? defaultRates[symbol]!;
    }
    
    return GameSettings(
      winPercentage: winPercentage,
      minSpinToWin: minSpinToWin,
      symbolRates: symbolRates,
    );
  }
}

class GameLogic {
  static final Random _random = Random();
  static GameSettings settings = GameSettings(
    winPercentage: 0.5,
    minSpinToWin: 5,
    symbolRates: {
      '🍒': 0.30,
      '🍋': 0.30,
      '💎': 0.10,
      '💰': 0.10,
      '🍊': 0.15,
      '🔔': 0.20,
      '🎲': 0.25,
      '🥇': 0.30,
      '🍇': 0.30,
    },
  );


  static List<WinLine> checkWinLines(List<List<String>> grid) {
    List<WinLine> winLines = [];
    final baseRewards = {
      '🍒': 3,
      '🍋': 4,
      '💎': 10,
      '💰': 15,
      '🍊': 5,
      '🔔': 6,
      '🎲': 7,
      '🥇': 8,
      '🍇': 9,
    };
    // Cek garis horizontal
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
   
    // Cek garis vertikal (4 simbol)
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
    
    // Cek diagonal utama (kiri atas ke kanan bawah)
    String mainDiagSymbol = grid[0][0];
    bool mainDiagWin = mainDiagSymbol != '🎰';
    // bool mainDiagWin = true;
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
    
    // Cek diagonal sekunder (kanan atas ke kiri bawah)
    String antiDiagSymbol = grid[0][3];
    bool antiDiagWin = antiDiagSymbol != '🎰';
    if (antiDiagWin){
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
  }
  return winLines;
}
  

  // Update settings
  static void updateSettings(GameSettings newSettings) {
    settings = newSettings;
  }

  // Get random symbol berdasarkan probabilitas
  static String getRandomSymbol() {
    // Hanya gunakan simbol dengan persentase >0%
    Map<String, double> activeSymbols = {};
    settings.symbolRates.forEach((symbol, rate) {
      if (rate > 0) {
        activeSymbols[symbol] = rate;
      }});
    
    // Hitung total weight
    double totalWeight = settings.symbolRates.values.fold(0.0, (sum, weight) => sum + weight);
    
    double randomNumber = _random.nextDouble() * totalWeight;
    double cumulative = 0.0;
    if (totalWeight <= 0) {
      return '🎰'; // Simbol default
    }
    
    for (var entry in settings.symbolRates.entries) {
      cumulative += entry.value;
      if (randomNumber < cumulative) {
        return entry.key;
      }
    }
    return '🎰'; 
    // return settings.symbolRates.keys.first;
  }
  static List<List<String>> generateForcedWinPattern(
    List<List<String>> currentRows,
    String winSymbol,
    String winType,
    int position
  ) {
    final newRows = currentRows.map((row) => List<String>.from(row)).toList();

    switch (winType) {
      case 'horizontal':
        for (int col = 0; col < 4; col++) {
          newRows[position][col] = winSymbol;
        }
        break;
      case 'vertical':
        for (int row = 0; row < 4; row++) {
          newRows[row][position] = winSymbol;
        }
        break;
      case 'diagonal':
        if (position == 0) { // Down-right diagonal
          for (int i = 0; i < 4; i++) {
            newRows[i][i] = winSymbol;
          }
        } else { // Down-left diagonal
          for (int i = 0; i < 4; i++) {
            newRows[i][3 - i] = winSymbol;
          }
        }
        break;
    }
    return newRows;
  }
  static List<List<String>> generateSymbols() {
    return List.generate(4, (row) {
      return List.generate(4, (col) {
        String symbol;
        int attempt = 0;
        do{
          symbol = getRandomSymbol();
          attempt++;
          // Batasi percobaan untuk menghindari loop tak berujung
          if (attempt > 50) return '🎰'; 
        } while(!_isSymbolAllowed(symbol));
        return symbol;
      }
      // } => getRandomSymbol());
   );});
  }

  static bool _isSymbolAllowed(String symbol) {
    // Dapatkan batas maksimum untuk simbol ini
    final maxCount = _getMaxCountForSymbol(symbol);
    
    // Jika tidak ada batas, selalu diizinkan
    if (maxCount == null) return true;
    
  
    return true; // Implementasi nyata memerlukan state management
    
    
  }
  static int? _getMaxCountForSymbol(String symbol) {
    // Batas maksimum kemunculan berdasarkan kombinasi pemenang
    final Map<String, int> maxCounts = {
      '🍒': 6,
      '🍋': 5,
      '💎': 4,
      '💰': 3,
      '🍊': 5,
      '🔔': 5,
      '🎲': 5,
      '🥇': 5,
      '🍇': 5,
    };
    
    return maxCounts[symbol];
  }


  // Cek apakah spin ini menghasilkan kemenangan
  static bool shouldWin(int spinCount) {
    // Jika winPercentage 0%, tidak pernah menang
    if (settings.winPercentage == 0.0) return false;
    // Hanya berpeluang menang jika sudah mencapai spin minimum
    if (spinCount < settings.minSpinToWin) return false;
    
    return _random.nextDouble() < settings.winPercentage;
  }
  

  static Color getSymbolColor(String symbol) {
    switch (symbol) {
      case '🍒': return Colors.pink.shade100;
      case '🍋': return Colors.yellow.shade100;
      case '💎': return Colors.blue.shade100;
      case '💰': return Colors.green.shade100;
      case '🍊': return Colors.orange.shade100;
      case '🔔': return Colors.amber.shade100;
      case '🎲': return Colors.deepPurple.shade100;
      case '🥇': return Colors.amber.shade300;
      case '🍇': return Colors.purple.shade100;
      default: return Colors.grey.shade200;
    }
  }

  static bool isInForceWinPattern(int row, int col, String? winType, int? position) {
    if (winType == null || position == null) return false;

    switch (winType) {
      case 'horizontal':
        return row == position;
      case 'vertical':
        return col == position;
      case 'diagonal':
        if (position == 0) { // Down-right diagonal
          return row == col;
        } else { // Down-left diagonal
          return row + col == 3; // Assuming 4 rows/columns
        }
      default:
        return false;
    }
  }

  static void resetSettings() {
    settings = GameSettings(
      winPercentage: 0.5,
      minSpinToWin: 5,
      symbolRates : {
        '🍒': 0.30,
      '🍋': 0.30,
      '💎': 0.10,
      '💰': 0.10,
      '🍊': 0.15,
      '🔔': 0.20,
      '🎲': 0.25,
      '🥇': 0.30,
      '🍇': 0.30,
  }
    );
  }

}