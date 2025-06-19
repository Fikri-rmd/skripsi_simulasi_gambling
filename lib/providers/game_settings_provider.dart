import 'package:flutter/material.dart';

class GameSettingsProvider with ChangeNotifier {
  List<Map<String, dynamic>> _symbolProbabilities = [
    {'symbol': '🍒', 'weight': 65},
    {'symbol': '🍋', 'weight': 25},
    {'symbol': '💎', 'weight': 8},
    {'symbol': '💰', 'weight': 2},
  ];

  List<Map<String, dynamic>> get symbolProbabilities => _symbolProbabilities;

  void updateProbabilities(List<Map<String, dynamic>> newProbabilities) {
    final totalWeight = newProbabilities.fold(
      0, 
      (sum, item) => sum + (item['weight'] as int)
    );
    
    if (totalWeight <= 100) {
      _symbolProbabilities = newProbabilities;
      notifyListeners();
    } else {
      throw Exception("Total weight cannot exceed 100");
    }
  }

  void resetToDefault() {
    _symbolProbabilities = [
      {'symbol': '🍒', 'weight': 65},
      {'symbol': '🍋', 'weight': 25},
      {'symbol': '💎', 'weight': 8},
      {'symbol': '💰', 'weight': 2},
    ];
    notifyListeners();
  }
}