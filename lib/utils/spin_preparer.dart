// spin_preparer.dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:simulasi_slot/utils/game_logic.dart';

class SpinPreparer {
  static final Random _random = Random();
  static final Map<String, List<List<List<String>>>> _winPatternsBySymbol = {};
  static List<List<List<String>>> _losePatterns = [];
  static late Map<String, String> _symbolFileMap;

  static Future<void> loadPatternsFromAssets() async {
    if (_winPatternsBySymbol.isNotEmpty) return;

    // 1. Load symbol mapping
    try {
      final mapJson = await rootBundle.loadString('assets/patterns/symbol_map.json');
      _symbolFileMap = Map<String, String>.from(jsonDecode(mapJson));
    } catch (e) {
      // Fallback mapping jika file tidak ditemukan
      _symbolFileMap = {
        '🍒': 'cherry',
        '🍋': 'lemon',
        '💎': 'diamond',
        '💰': 'money',
        '🍊': 'orange',
      };
    }

    // 2. Load lose patterns
    try {
      final loseJson = await rootBundle.loadString('assets/patterns/lose_patterns.json');
      _losePatterns = _parseJsonPatterns(loseJson);
    } catch (e) {
      // Generate fallback lose patterns jika file tidak ditemukan
      _losePatterns = _createFallbackLosePatterns(50);
    }

    // 3. Load win patterns for each symbol
    final symbols = GameLogic.settings.symbolRates.keys;
    for (String symbol in symbols) {
      try {
        if (_symbolFileMap.containsKey(symbol)) {
          final fileName = _symbolFileMap[symbol]!;
          final winJson = await rootBundle.loadString('assets/patterns/${fileName}_win_patterns.json');
          _winPatternsBySymbol[symbol] = _parseJsonPatterns(winJson);
        } else {
          // Fallback untuk simbol baru
          _winPatternsBySymbol[symbol] = _createFallbackWinPatterns(symbol);
        }
      } catch (e) {
        // Gunakan fallback jika terjadi error
        _winPatternsBySymbol[symbol] = _createFallbackWinPatterns(symbol);
      }
    }
  }

  static List<List<List<String>>> _parseJsonPatterns(String json) {
    return List<List<List<String>>>.from(
      jsonDecode(json).map(
        (grid) => List<List<String>>.from(
          grid.map((row) => List<String>.from(row))
        )
      )
    );
  }

  static List<List<List<String>>> _createFallbackWinPatterns(String symbol) {
    // Buat pola dasar jika file tidak ditemukan
    return [
      // Horizontal win
      [
        [symbol, symbol, symbol, symbol],
        ['🎰', '🎰', '🎰', '🎰'],
        ['🎰', '🎰', '🎰', '🎰'],
        ['🎰', '🎰', '🎰', '🎰']
      ],
      // Vertical win
      [
        [symbol, '🎰', '🎰', '🎰'],
        [symbol, '🎰', '🎰', '🎰'],
        [symbol, '🎰', '🎰', '🎰'],
        [symbol, '🎰', '🎰', '🎰']
      ],
      // Diagonal win
      [
        [symbol, '🎰', '🎰', '🎰'],
        ['🎰', symbol, '🎰', '🎰'],
        ['🎰', '🎰', symbol, '🎰'],
        ['🎰', '🎰', '🎰', symbol]
      ],
      // Anti-diagonal win
      [
        ['🎰', '🎰', '🎰', symbol],
        ['🎰', '🎰', symbol, '🎰'],
        ['🎰', symbol, '🎰', '🎰'],
        [symbol, '🎰', '🎰', '🎰']
      ]
    ];
  }

  static List<List<List<String>>> _createFallbackLosePatterns(int count) {
    final symbols = GameLogic.settings.symbolRates.keys.toList();
    final patterns = <List<List<String>>>[];
    
    for (int i = 0; i < count; i++) {
      final grid = List.generate(4, (row) => 
          List.generate(4, (col) => symbols[_random.nextInt(symbols.length)]));
      patterns.add(grid);
    }
    
    return patterns;
  }

  static List<List<String>> getRandomWinPattern(String symbol) {
    final patterns = _winPatternsBySymbol[symbol] ?? _createFallbackWinPatterns(symbol);
    return patterns[_random.nextInt(patterns.length)];
  }

  static List<List<String>> getRandomLosePattern() {
    if (_losePatterns.isEmpty) {
      return _createFallbackLosePatterns(1).first;
    }
    return _losePatterns[_random.nextInt(_losePatterns.length)];
  }

  static Future<List<List<List<String>>>> prepareSpins({
    required int totalSpins,
    required int currentSpinCount,
    required GameSettings settings,
  }) async {
    await loadPatternsFromAssets();
    final List<List<List<String>>> result = [];
    
    final minSpin = settings.minSpinToWin;
    final winCount = (settings.winPercentage * totalSpins).round();
    
    // Cek apakah ada simbol yang harus selalu menang
    final fullRateSymbol = _getFullRateSymbol(settings.symbolRates);
    
    // Pilih simbol untuk kemenangan
    final winSymbols = _selectWinSymbols(winCount, settings.symbolRates, fullRateSymbol);

    // Spin awal di bawah minSpinToWin: dijamin kalah
    for (int i = 0; i < minSpin; i++) {
      result.add(getRandomLosePattern());
    }

    // Spin setelah minSpinToWin: campuran menang dan kalah
    for (int i = 0; i < winCount; i++) {
      final symbol = winSymbols[i];
      var winPattern = getRandomWinPattern(symbol);
      
      // Jika ada fullRateSymbol, pastikan hanya simbol itu yang digunakan untuk kemenangan
      if (fullRateSymbol != null) {
        winPattern = _ensureWinPatternUsesSymbol(winPattern, fullRateSymbol);
      }
      
      result.add(winPattern);
    }

    // Isi sisa dengan spin kalah
    final remaining = totalSpins - minSpin - winCount;
    for (int i = 0; i < remaining; i++) {
      result.add(getRandomLosePattern());
    }

    // Acak urutan spin (kecuali spin awal yang dijamin kalah)
    final guaranteedLoses = result.sublist(0, minSpin);
    final otherSpins = result.sublist(minSpin)..shuffle();
    
    return [...guaranteedLoses, ...otherSpins];
  }

  static String? _getFullRateSymbol(Map<String, double> rates) {
    for (var entry in rates.entries) {
      if (entry.value == 1.0) {
        return entry.key;
      }
    }
    return null;
  }

  static List<String> _selectWinSymbols(int count, Map<String, double> rates, String? fullRateSymbol) {
    final List<String> symbols = [];
    
    // Jika ada simbol 100%, gunakan untuk semua kemenangan
    if (fullRateSymbol != null) {
      return List.filled(count, fullRateSymbol);
    }
    
    // Jika tidak, pilih berdasarkan probabilitas
    final totalWeight = rates.values.fold(0.0, (sum, rate) => sum + rate);
    
    for (int i = 0; i < count; i++) {
      double randomValue = _random.nextDouble() * totalWeight;
      double cumulative = 0.0;
      
      for (var entry in rates.entries) {
        cumulative += entry.value;
        if (randomValue < cumulative) {
          symbols.add(entry.key);
          break;
        }
      }
    }
    
    return symbols;
  }

  static List<List<String>> _ensureWinPatternUsesSymbol(
    List<List<String>> pattern, 
    String symbol
  ) {
    // Buat salinan pattern
    final newPattern = List<List<String>>.from(pattern.map((row) => List<String>.from(row)));
    
    // Identifikasi garis kemenangan dan ganti dengan simbol yang diinginkan
    for (int row = 0; row < 4; row++) {
      // Cek horizontal
      if (newPattern[row][0] == newPattern[row][1] &&
          newPattern[row][1] == newPattern[row][2] &&
          newPattern[row][2] == newPattern[row][3]) {
        for (int col = 0; col < 4; col++) {
          newPattern[row][col] = symbol;
        }
      }
    }
    
    for (int col = 0; col < 4; col++) {
      // Cek vertikal
      if (newPattern[0][col] == newPattern[1][col] &&
          newPattern[1][col] == newPattern[2][col] &&
          newPattern[2][col] == newPattern[3][col]) {
        for (int row = 0; row < 4; row++) {
          newPattern[row][col] = symbol;
        }
      }
    }
    
    // Cek diagonal utama
    if (newPattern[0][0] == newPattern[1][1] &&
        newPattern[1][1] == newPattern[2][2] &&
        newPattern[2][2] == newPattern[3][3]) {
      for (int i = 0; i < 4; i++) {
        newPattern[i][i] = symbol;
      }
    }
    
    // Cek diagonal anti
    if (newPattern[0][3] == newPattern[1][2] &&
        newPattern[1][2] == newPattern[2][1] &&
        newPattern[2][1] == newPattern[3][0]) {
      for (int i = 0; i < 4; i++) {
        newPattern[i][3 - i] = symbol;
      }
    }
    
    return newPattern;
  }
}