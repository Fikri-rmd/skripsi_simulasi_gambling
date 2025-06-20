import 'dart:math';

import 'package:flutter/material.dart';

class GameLogic {
  static final Random _random = Random();

  static const List<Map<String, dynamic>> _symbolProbabilities = [
    {'symbol': '🍒', 'weight': 30},
    {'symbol': '🍊', 'weight': 10},
    {'symbol': '🔔', 'weight': 15},
    {'symbol': '🎲', 'weight': 5},
    {'symbol': '🥇', 'weight': 3},
    {'symbol': '🍇', 'weight': 12},
    {'symbol': '🍋', 'weight': 25},
    {'symbol': '💎', 'weight': 8},
    {'symbol': '💰', 'weight': 2},
  ];

  static String getRandomSymbol() {
    final int totalWeight = _symbolProbabilities.fold(
      0, (int sum, item) => sum + (item['weight'] as int)
    );
    
    int randomNumber = _random.nextInt(totalWeight);
    int cumulative = 0;
    
    for (var item in _symbolProbabilities) {
      cumulative += item['weight'] as int;
      if (randomNumber < cumulative) {
        return item['symbol'] as String;
      }
    }
    return '🎰';
  }

  static List<List<String>> generateSymbols() {
    return List.generate(4, (row) {
      return List.generate(4, (col) => getRandomSymbol());
    });
  }

  static int calculateReward(String symbol, int count) {
    switch (symbol) {
      case '🍒': return count >= 6 ? 1 : 0;
      case '🍋': return count >= 5 ? 2 : 0;
      case '💎': return count >= 4 ? 10 : 0;
      case '💰': return count >= 3 ? 30 : 0;
      case '🍊': return count >= 5 ? 3 : 0;
      case '🔔': return count >= 5 ? 4 : 0;
      case '🎲': return count >= 5 ? 5 : 0;
      case '🥇': return count >= 5 ? 6 : 0;
      case '🍇': return count >= 5 ? 7 : 0;
      default: return 0;
    }
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