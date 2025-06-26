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
      '🍒': 0.30,
      '🍋': 0.25,
      '💎': 0.08,
      '💰': 0.02,
      '🍊': 0.10,
      '🔔': 0.15,
      '🎲': 0.05,
      '🥇': 0.03,
      '🍇': 0.12,
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
      '🍋': 0.25,
      '💎': 0.08,
      '💰': 0.02,
      '🍊': 0.10,
      '🔔': 0.15,
      '🎲': 0.05,
      '🥇': 0.03,
      '🍇': 0.12,
    },
  );

  static List<WinLine> checkWinLines(List<List<String>> grid) {
    List<WinLine> winLines = [];
    final baseRewards = {
      '🍒': 1,
      '🍋': 2,
      '💎': 10,
      '💰': 30,
      '🍊': 3,
      '🔔': 4,
      '🎲': 5,
      '🥇': 6,
      '🍇': 7,
    };
    // Cek garis horizontal
    for (int row = 0; row < 4; row++) {
      String symbol = grid[row][0];
      bool win = true;
      for (int col = 1; col < 4; col++) {
        if (grid[row][col] != symbol) {
          win = false;
          break;
        }
      }
      if (win && symbol != '🎰') {
        winLines.add(WinLine(
          lineType: 'horizontal',
          row: row,
          symbol: symbol,
          reward: baseRewards[symbol]! * 4,
        ));
      }
    }
    // for (int row = 0; row < grid.length; row++) {
    //   String symbol = grid[row][0];
    //   if (symbol != '🎰' && 
    //       symbol == grid[row][1] && 
    //       symbol == grid[row][2] && 
    //       symbol == grid[row][3]) {
        
    //     int reward = baseRewards[symbol]! * 4;
    //     winLines.add(WinLine(
    //       lineType: 'horizontal',
    //       row: row,
    //       startCol: 0,
    //       endCol: 3,
    //       symbol: symbol,
    //       reward: reward,
    //     ));
    //   }
    // }
    // Cek garis vertikal (4 simbol)
    for (int col = 0; col < 4; col++) {
      String symbol = grid[0][col];
      bool win = true;
      for (int row = 1; row < 4; row++) {
        if (grid[row][col] != symbol) {
          win = false;
          break;
        }
      }
      if (win && symbol != '🎰') {
        winLines.add(WinLine(
          lineType: 'vertical',
          col: col,
          symbol: symbol,
          reward: baseRewards[symbol]! * 4,
        ));
      }
    }
    // for (int col = 0; col < grid[0].length; col++) {
    //   String symbol = grid[0][col];
    //   if (symbol != '🎰' && 
    //       symbol == grid[1][col] && 
    //       symbol == grid[2][col] && 
    //       symbol == grid[3][col]) {
        
    //     int reward = baseRewards[symbol]! * 4;
    //     winLines.add(WinLine(
    //       lineType: 'vertical',
    //       col: col,
    //       startRow: 0,
    //       endRow: 3,
    //       symbol: symbol,
    //       reward: reward,
    //     ));
    //   }
    // }
    // Cek diagonal utama (kiri atas ke kanan bawah - 4 simbol)
    // String mainDiagSymbol = grid[0][0];
    // if (mainDiagSymbol != '🎰' && 
    //     mainDiagSymbol == grid[1][1] && 
    //     mainDiagSymbol == grid[2][2] && 
    //     mainDiagSymbol == grid[3][3]) {
      
    //   int reward = baseRewards[mainDiagSymbol]! * 4;
    //   winLines.add(WinLine(
    //     lineType: 'diagonal',
    //     direction: 'down-right',
    //     startRow: 0,
    //     startCol: 0,
    //     endRow: 3,
    //     endCol: 3,
    //     symbol: mainDiagSymbol,
    //     reward: reward,
    //   ));
    // }
    // Cek diagonal utama (kiri atas ke kanan bawah)
    String mainDiagSymbol = grid[0][0];
    bool mainDiagWin = true;
    for (int i = 1; i < 4; i++) {
      if (grid[i][i] != mainDiagSymbol) {
        mainDiagWin = false;
        break;
      }
    }
    if (mainDiagWin && mainDiagSymbol != '🎰') {
      winLines.add(WinLine(
        lineType: 'diagonal',
        symbol: mainDiagSymbol,
        reward: baseRewards[mainDiagSymbol]! * 4,
      ));
    }
    //  // Cek diagonal sekunder (kanan atas ke kiri bawah - 4 simbol)
    // String antiDiagSymbol = grid[0][3];
    // if (antiDiagSymbol != '🎰' && 
    //     antiDiagSymbol == grid[1][2] && 
    //     antiDiagSymbol == grid[2][1] && 
    //     antiDiagSymbol == grid[3][0]) {
      
    // int reward = baseRewards[antiDiagSymbol]! * 4;
    // winLines.add(WinLine(
    //   lineType: 'diagonal',
    //   direction: 'down-left',
    //   startRow: 0,
    //   startCol: 3,
    //   endRow: 3,
    //   endCol: 0,
    //   symbol: antiDiagSymbol,
    //   reward: reward,
    // Cek diagonal sekunder (kanan atas ke kiri bawah)
    String antiDiagSymbol = grid[0][3];
    bool antiDiagWin = true;
    for (int i = 1; i < 4; i++) {
      if (grid[i][3-i] != antiDiagSymbol) {
        antiDiagWin = false;
        break;
      }
    }
    if (antiDiagWin && antiDiagSymbol != '🎰') {
      winLines.add(WinLine(
        lineType: 'diagonal',
        symbol: antiDiagSymbol,
        reward: baseRewards[antiDiagSymbol]! * 4,
      ));
        }return winLines;}
  

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
      if (activeSymbols.length < 5) {
      activeSymbols['🍒'] = 0.3;
      activeSymbols['🍋'] = 0.3;
      activeSymbols['🍊'] = 0.4;
      activeSymbols['💎'] = 0.1;
      activeSymbols['💰'] = 0.2;
    }
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
    
    // Hitung berapa kali simbol ini sudah muncul di putaran saat ini
    // CATATAN: Ini hanya contoh, implementasi sebenarnya perlu menyimpan state putaran saat ini
    return true; // Implementasi nyata memerlukan state management
    
    // Di implementasi nyata, kita perlu:
    // 1. Menyimpan jumlah kemunculan sementara untuk setiap simbol
    // 2. Membandingkan dengan maxCount
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

  // Hitung reward berdasarkan simbol yang muncul
  static int calculateReward(String symbol, int count) {
    // Fixed rewards, tidak terpengaruh pengaturan
    Map<String, int> baseRewards = {
      '🍒': 1,
      '🍋': 2,
      '💎': 10,
      '💰': 30,
      '🍊': 3,
      '🔔': 4,
      '🎲': 5,
      '🥇': 6,
      '🍇': 7,
    };
    
    return baseRewards[symbol]! * count;
  }

  // Cek apakah spin ini menghasilkan kemenangan
  static bool shouldWin(int spinCount) {
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
  }
  