import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:simulasi_slot/utils/game_logic.dart';

class SpinPreparer {
  static final _random = Random();
  static List<List<List<String>>> _winPatterns = [];
  static List<List<List<String>>> _losePatterns = [];

  /// Load precomputed win/lose pattern JSON (once)
  static Future<void> loadPatternsFromAssets() async {
    if (_winPatterns.isNotEmpty && _losePatterns.isNotEmpty) return;

    final winJson = await rootBundle.loadString('assets/win_patterns.json');
    final loseJson = await rootBundle.loadString('assets/lose_patterns.json');

    _winPatterns = List<List<List<String>>>.from(
      jsonDecode(winJson).map(
        (row) => List<List<String>>.from(
          row.map((r) => List<String>.from(r)),
        ),
      ),
    );

    _losePatterns = List<List<List<String>>>.from(
      jsonDecode(loseJson).map(
        (row) => List<List<String>>.from(
          row.map((r) => List<String>.from(r)),
        ),
      ),
    );
  }

  /// Ambil kombinasi spin berdasarkan winPercentage
  static Future<List<List<List<String>>>> prepareSpins(
  int totalSpins,
  GameSettings settings,
) async {
  await loadPatternsFromAssets();

  final minSpin = settings.minSpinToWin;
  final actualSpinsForWin = max(0, totalSpins - minSpin);
  final winCount = (settings.winPercentage * actualSpinsForWin).round();
  final loseCount = totalSpins - winCount;

  final guaranteedLoses = List<List<List<String>>>.from(_losePatterns)..shuffle();
  final selectedWins = List<List<List<String>>>.from(_winPatterns)..shuffle();

  final List<List<List<String>>> result = [];

  // Spins sebelum mencapai minSpin → dijamin kalah
  result.addAll(guaranteedLoses.take(minSpin));

  // Sisanya: campuran menang dan kalah
  final int remaining = totalSpins - minSpin;
  final extraWins = selectedWins.take(winCount).toList();
  final extraLoses = guaranteedLoses.skip(minSpin).take(remaining - winCount).toList();

  final List<List<List<String>>> mixed = [...extraWins, ...extraLoses]..shuffle();
  result.addAll(mixed);

  return result;
}

}
