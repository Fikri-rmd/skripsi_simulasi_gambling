import 'dart:math';
import 'dart:convert';
import 'dart:io';

class PatternGenerator {
  static final _random = Random();

  static const List<String> symbols = ['🍒', '🍋', '💎', '💰', '🍊'];

  static List<List<List<String>>> generateWinningPatterns() {
    List<List<List<String>>> patterns = [];

    for (var symbol in symbols) {
      // Horizontal
      for (int row = 0; row < 4; row++) {
        final grid = _emptyGrid();
        for (int col = 0; col < 4; col++) {
          grid[row][col] = symbol;
        }
        patterns.add(grid);
      }

      // Vertical
      for (int col = 0; col < 4; col++) {
        final grid = _emptyGrid();
        for (int row = 0; row < 4; row++) {
          grid[row][col] = symbol;
        }
        patterns.add(grid);
      }

      // Diagonal (main)
      final diag1 = _emptyGrid();
      for (int i = 0; i < 4; i++) diag1[i][i] = symbol;
      patterns.add(diag1);

      // Diagonal (anti)
      final diag2 = _emptyGrid();
      for (int i = 0; i < 4; i++) diag2[i][3 - i] = symbol;
      patterns.add(diag2);
    }

    return patterns;
  }

  static List<List<List<String>>> generateCombinedWinningPatterns() {
    List<List<List<String>>> patterns = [];

    for (var symbol in symbols) {
      // Row 0 & 3
      final grid1 = _emptyGrid();
      for (int col = 0; col < 4; col++) {
        grid1[0][col] = symbol;
        grid1[3][col] = symbol;
      }
      patterns.add(grid1);

      // Column 0 & 2
      final grid2 = _emptyGrid();
      for (int row = 0; row < 4; row++) {
        grid2[row][0] = symbol;
        grid2[row][2] = symbol;
      }
      patterns.add(grid2);

      // Diagonal + row 1
      final grid3 = _emptyGrid();
      for (int i = 0; i < 4; i++) {
        grid3[i][i] = symbol;
        grid3[1][i] = symbol;
      }
      patterns.add(grid3);

      // Anti-diagonal + column 3
      final grid4 = _emptyGrid();
      for (int i = 0; i < 4; i++) {
        grid4[i][3 - i] = symbol;
        grid4[i][3] = symbol;
      }
      patterns.add(grid4);

      // Row 1 + col 2 + diag
      final grid5 = _emptyGrid();
      for (int i = 0; i < 4; i++) {
        grid5[1][i] = symbol;
        grid5[i][2] = symbol;
        grid5[i][i] = symbol;
      }
      patterns.add(grid5);
    }

    return patterns;
  }

  static List<List<List<String>>> generateLosingPatterns(int count) {
    List<List<List<String>>> patterns = [];

    while (patterns.length < count) {
      final grid = List.generate(4, (_) => List.generate(4, (_) => symbols[_random.nextInt(symbols.length)]));
      if (!_hasWin(grid)) {
        patterns.add(grid);
      }
    }

    return patterns;
  }

  static List<List<String>> _emptyGrid() =>
      List.generate(4, (_) => List.generate(4, (_) => _randomSymbol()));

  static String _randomSymbol() => symbols[_random.nextInt(symbols.length)];

  static bool _hasWin(List<List<String>> grid) {
    for (int row = 0; row < 4; row++) {
      if (grid[row].toSet().length == 1) return true;
    }

    for (int col = 0; col < 4; col++) {
      final colSet = {for (int row = 0; row < 4; row++) grid[row][col]};
      if (colSet.length == 1) return true;
    }

    final mainDiag = {for (int i = 0; i < 4; i++) grid[i][i]};
    final antiDiag = {for (int i = 0; i < 4; i++) grid[i][3 - i]};
    if (mainDiag.length == 1 || antiDiag.length == 1) return true;

    return false;
  }

  static void savePatternsToJson(
    List<List<List<String>>> patterns,
    String filePath,
  ) {
    final jsonString = jsonEncode(patterns);
    File(filePath).writeAsStringSync(jsonString);
  }
}

void main() {
  final basicWinning = PatternGenerator.generateWinningPatterns();
  final combinedWinning = PatternGenerator.generateCombinedWinningPatterns();
  final allWinning = [...basicWinning, ...combinedWinning];
  final losingPatterns = PatternGenerator.generateLosingPatterns(2000);

  final allPatterns = [...allWinning, ...losingPatterns];
  PatternGenerator.savePatternsToJson(allPatterns, 'patterns.json');

  print('Generated ${allWinning.length} winning and ${losingPatterns.length} losing patterns.');
}
