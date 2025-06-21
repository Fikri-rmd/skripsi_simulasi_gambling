import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  

  // Update settings
  static void updateSettings(GameSettings newSettings) {
    settings = newSettings;
  }

  // Get random symbol berdasarkan probabilitas
  static String getRandomSymbol() {
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
      return List.generate(4, (col) => getRandomSymbol());
    });
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