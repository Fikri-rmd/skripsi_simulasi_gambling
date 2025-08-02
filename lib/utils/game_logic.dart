import 'dart:collection';
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

  List<String> get symbols => symbolRates.keys.toList();

  void validateSymbolRates() {
    final total = symbolRates.values.fold(0.0, (sum, rate) => sum + rate);
    if ((total - 1.0).abs() > 0.001) {
      throw Exception("Total symbol rates must be 100%");
    }
    final activeSymbols = symbolRates.values.where((rate) => rate > 0).length;
    if (winPercentage < 1.0 && activeSymbols < 2) {
    throw Exception(
        "Pengaturan tidak valid: Mustahil menghasilkan kekalahan jika hanya ada satu simbol aktif. Naikkan persentase kemenangan menjadi 100% atau aktifkan simbol kedua.");
  }
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
    double winPercentage = prefs.getDouble('winPercentage') ?? 0.2;
    int minSpinToWin = prefs.getInt('minSpinToWin') ?? 5;
    
    Map<String, double> defaultRates = {
      '🍒': 0.25, '🍋': 0.25, '💎': 0.15, '💰': 0.15,
      '🍊': 0.20,
    };
    
    Map<String, double> symbolRates = {};
    for (String symbol in defaultRates.keys) {
      symbolRates[symbol] = prefs.getDouble('symbol_$symbol') ?? defaultRates[symbol]!;
    }

    final total = symbolRates.values.fold(0.0, (sum, rate) => sum + rate);
    if ((total - 1.0).abs() > 0.001) {
      return GameSettings(
        winPercentage: winPercentage,
        minSpinToWin: minSpinToWin,
        symbolRates: defaultRates,
      );
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
      '🍒': 0.25, '🍋': 0.25, '💎': 0.15, '💰': 0.15,
      '🍊': 0.20,
    },
  )..validateSymbolRates();

  static Queue<bool> activeCyclePool = Queue<bool>();
  static const int cycleLength = 10;
  static Queue<String> symbolCyclePool = Queue<String>();
  static const int symbolCycleLength = 10; 
  static const String _spinsSinceLastWinKey = 'spinsSinceLastWin';
  static int spinsSinceLastWin = 0;
  static bool _isCooldownActive = false;
  static const String _isCooldownActiveKey = 'isCooldownActive';

  
  static Future<void> initialize() async {
    settings = await GameSettings.loadFromPrefs();
    final prefs = await SharedPreferences.getInstance();
    spinsSinceLastWin = prefs.getInt(_spinsSinceLastWinKey) ?? 0;
    _isCooldownActive = prefs.getBool(_isCooldownActiveKey) ?? false;
  }

  static void _createSymbolCycle() {
    symbolCyclePool.clear();
    final List<String> cyclePatterns = [];
    
    settings.symbolRates.forEach((symbol, rate) {
      final count = (symbolCycleLength * rate).round();
      for (int i = 0; i < count; i++) {
        cyclePatterns.add(symbol);
      }
    });

    while (cyclePatterns.length < symbolCycleLength) {
      cyclePatterns.add(getRandomSymbol());
    }
    while (cyclePatterns.length > symbolCycleLength) {
      cyclePatterns.removeLast();
    }

    cyclePatterns.shuffle(_random);
    symbolCyclePool.addAll(cyclePatterns);
  }

  static void _createNewCycle() {
    activeCyclePool.clear();
    
    final int winCount = (cycleLength * settings.winPercentage).round();
    final int loseCount = cycleLength - winCount;

    final cyclePatterns = List.generate(winCount, (_) => true)
      ..addAll(List.generate(loseCount, (_) => false));
      
    cyclePatterns.shuffle(_random);
    activeCyclePool.addAll(cyclePatterns);
  }

  static Future<void> _saveSpinsSinceLastWin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_spinsSinceLastWinKey, spinsSinceLastWin);
  }

  static List<List<String>> generateSymbols() {
    bool isWin;

    if (_isCooldownActive && spinsSinceLastWin < settings.minSpinToWin) {
      isWin = false;
      spinsSinceLastWin++;
      _saveSpinsSinceLastWin();
      if (spinsSinceLastWin >= settings.minSpinToWin) {
        _isCooldownActive = false;
        final prefs = SharedPreferences.getInstance();
        prefs.then((p) => p.setBool(_isCooldownActiveKey, false));
      }
    }else {
      if (activeCyclePool.isEmpty) {
      _createNewCycle();
    }
    isWin = activeCyclePool.removeFirst();
  }
  if (isWin) {
    if (symbolCyclePool.isEmpty) {
      _createSymbolCycle();
    }
    String winningSymbol = symbolCyclePool.removeFirst();
    return _generateLiveWinningGrid(winningSymbol);
  } else {
    return _generateNearMissLosingGrid();
  }
}
 


  static List<List<String>> _generateLiveWinningGrid(String winningSymbol) {
    var grid = List.generate(4, (_) => List.filled(4, ''));
    final winTypes = ['horizontal', 'vertical', 'diagonal'];
    final selectedType = winTypes[_random.nextInt(winTypes.length)];

    if (selectedType == 'horizontal') {
      final row = _random.nextInt(4);
      for (int col = 0; col < 4; col++) {
        grid[row][col] = winningSymbol;
      }
    } else if (selectedType == 'vertical') {
      final col = _random.nextInt(4);
      for (int row = 0; row < 4; row++) {
        grid[row][col] = winningSymbol;
      }
    } else {
      if (_random.nextBool()) {
        for (int i = 0; i < 4; i++) {
          grid[i][i] = winningSymbol;
        }
      } else {
        for (int i = 0; i < 4; i++) {
          grid[i][3 - i] = winningSymbol;
        }
      }
    }
    
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 4; col++) {
        if (grid[row][col] == '') {
          grid[row][col] = getRandomSymbol();
        }
      }
    }
    
    return grid;
  }

  static List<List<String>> _generateNearMissLosingGrid() {
    List<List<String>> grid;
    do {
      grid = List.generate(4, (_) => List.filled(4, ''));

      final highValueSymbols = ['💎', '💰'];
      final baitSymbol = highValueSymbols[_random.nextInt(highValueSymbols.length)];
      
      String spoilerSymbol;
      do {
        spoilerSymbol = getRandomSymbol();
      } while (spoilerSymbol == baitSymbol);

      final lineTypes = ['horizontal', 'vertical', 'diagonal', 'anti-diagonal'];
      final selectedLineType = lineTypes[_random.nextInt(lineTypes.length)];
      final spoilerPosition = _random.nextInt(4);

      if (selectedLineType == 'horizontal') {
        final row = _random.nextInt(4);
        for (int i = 0; i < 4; i++) {
          grid[row][i] = (i == spoilerPosition) ? spoilerSymbol : baitSymbol;
        }
      } else if (selectedLineType == 'vertical') {
        final col = _random.nextInt(4);
        for (int i = 0; i < 4; i++) {
          grid[i][col] = (i == spoilerPosition) ? spoilerSymbol : baitSymbol;
        }
      } else if (selectedLineType == 'diagonal') {
        for (int i = 0; i < 4; i++) {
          grid[i][i] = (i == spoilerPosition) ? spoilerSymbol : baitSymbol;
        }
      } else {
        for (int i = 0; i < 4; i++) {
          grid[i][3 - i] = (i == spoilerPosition) ? spoilerSymbol : baitSymbol;
        }
      }

      for (int r = 0; r < 4; r++) {
        for (int c = 0; c < 4; c++) {
          if (grid[r][c] == '') {
            grid[r][c] = getRandomSymbol();
          }
        }
      }
    } while (checkWinLines(grid).isNotEmpty);

    return grid;
  }
 
  static Future<void> updateSettings(GameSettings newSettings) async {
    settings = newSettings;
    settings.validateSymbolRates();
    spinsSinceLastWin = 0;
    _isCooldownActive = true;
    activeCyclePool.clear();
    symbolCyclePool.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isCooldownActiveKey, _isCooldownActive);
    await _saveSpinsSinceLastWin(); 
  }

  static String getRandomSymbol() {
    if (settings.symbolRates.values.every((rate) => rate == 1.0)) {
       final symbols = settings.symbolRates.keys.toList();
       return symbols[_random.nextInt(symbols.length)];
    }

    final fullRateSymbol = settings.symbolRates.entries.firstWhere(
      (entry) => entry.value == 1.0,
      orElse: () => const MapEntry('', 0.0),
    );
    if (fullRateSymbol.key.isNotEmpty) {
      return fullRateSymbol.key;
    }

    final totalWeight = settings.symbolRates.values.fold(0.0, (sum, rate) => sum + rate);
    double randomValue = _random.nextDouble() * totalWeight;
    double cumulative = 0.0;
    
    for (var entry in settings.symbolRates.entries) {
      cumulative += entry.value;
      if (randomValue < cumulative) {
        return entry.key;
      }
    }
    return settings.symbolRates.keys.first;
  }

  static Future<void> resetStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalSpinCounter', 0);
    await prefs.setInt('totalWins', 0);
    await prefs.setInt('totalLoses', 0);
    await prefs.remove('symbolFreq');
    await prefs.remove(_spinsSinceLastWinKey);
    await prefs.remove(_isCooldownActiveKey);
    spinsSinceLastWin = 0;
    _isCooldownActive = false;
    activeCyclePool.clear();
    symbolCyclePool.clear();
  }
  
  static List<WinLine> checkWinLines(List<List<String>> grid) {
    List<WinLine> winLines = [];
    final baseRewards = {
      '🍒': 3, '🍋': 4, '💎': 10, '💰': 15,
      '🍊': 5,
    };
    
    for (int row = 0; row < 4; row++) {
      String symbol = grid[row][0];
      if (symbol == '🎰' || symbol == '') continue;
      bool win = true;
      for (int col = 1; col < 4; col++) {
        if (grid[row][col] != symbol) {
          win = false;
          break;
        }
      }
      if (win) {
        final existingLine = winLines.any((line) => line.lineType == 'horizontal' && line.row == row);
        if (!existingLine) {
            winLines.add(WinLine(
                lineType: 'horizontal',
                row: row,
                symbol: symbol,
                reward: baseRewards[symbol]! * 4,
            ));
        }
      }
    }
   
    for (int col = 0; col < 4; col++) {
      String symbol = grid[0][col];
      if (symbol == '🎰' || symbol == '') continue;
      bool win = true;
      for (int row = 1; row < 4; row++) {
        if (grid[row][col] != symbol) {
          win = false;
          break;
        }
      }
      if (win) {
        final existingLine = winLines.any((line) => line.lineType == 'vertical' && line.col == col);
        if (!existingLine) {
            winLines.add(WinLine(
                lineType: 'vertical',
                col: col,
                symbol: symbol,
                reward: baseRewards[symbol]! * 4,
            ));
        }
      }
    }
    
    String mainDiagSymbol = grid[0][0];
    if (mainDiagSymbol != '🎰' && mainDiagSymbol != '') {
        bool mainDiagWin = true;
        for (int i = 1; i < 4; i++) {
          if (grid[i][i] != mainDiagSymbol) {
            mainDiagWin = false;
            break;
          }
        }
        if (mainDiagWin) {
          final existingLine = winLines.any((line) => line.lineType == 'diagonal' && line.direction == 'down-right');
          if (!existingLine) {
              winLines.add(WinLine(
                  lineType: 'diagonal',
                  symbol: mainDiagSymbol,
                  direction: 'down-right',
                  reward: baseRewards[mainDiagSymbol]! * 4,
              ));
          }
        }
    }
    
    String antiDiagSymbol = grid[0][3];
    if (antiDiagSymbol != '🎰' && antiDiagSymbol != '') {
        bool antiDiagWin = true;
        for (int i = 1; i < 4; i++) {
          if (grid[i][3-i] != antiDiagSymbol) {
            antiDiagWin = false;
            break;
          }
        }
        if (antiDiagWin) {
          final existingLine = winLines.any((line) => line.lineType == 'diagonal' && line.direction == 'down-left');
          if (!existingLine) {
              winLines.add(WinLine(
                  lineType: 'diagonal',
                  symbol: antiDiagSymbol,
                  direction: 'down-left',
                  reward: baseRewards[antiDiagSymbol]! * 4,
              ));
          }
        }
    }
    
    return winLines;
  }

  static Color getSymbolColor(String symbol) {
    switch (symbol) {
      case '🍒': return Colors.pink.shade100;
      case '🍋': return Colors.yellow.shade100;
      case '💎': return Colors.blue.shade100;
      case '💰': return Colors.green.shade100;
      case '🍊': return Colors.orange.shade100;
      default: return Colors.grey.shade200;
    }
  }
}