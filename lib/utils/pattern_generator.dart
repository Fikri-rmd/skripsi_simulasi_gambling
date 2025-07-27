import 'dart:math';
import 'dart:convert';
import 'dart:io';

class PatternGenerator {
  static final Random _random = Random();

  // Daftar simbol yang digunakan
   static const Map<String, String> symbolFileMap = {
    '🍒': 'cherry',
    '🍋': 'lemon',
    '💎': 'diamond',
    '💰': 'money',
    '🍊': 'orange',
  };
   static List<String> get symbols => symbolFileMap.keys.toList();
  // Generate pola kemenangan dasar per simbol
  static List<List<List<String>>> generateBasicWinningPatternsForSymbol(String symbol) {
    List<List<List<String>>> patterns = [];

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

    return patterns;
  }

  // Generate pola kemenangan kombinasi per simbol
  static List<List<List<String>>> generateCombinedWinningPatternsForSymbol(String symbol) {
    List<List<List<String>>> patterns = [];

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

    return patterns;
  }

  // Generate semua pola kemenangan untuk sebuah simbol
  static List<List<List<String>>> generateAllWinningPatternsForSymbol(String symbol) {
    final basic = generateBasicWinningPatternsForSymbol(symbol);
    final combined = generateCombinedWinningPatternsForSymbol(symbol);
    return [...basic, ...combined];
  }

  // Generate pola kalah
  static List<List<List<String>>> generateLosingPatterns(int count) {
    List<List<List<String>>> patterns = [];

    while (patterns.length < count) {
      final grid = List.generate(4, (_) => 
          List.generate(4, (_) => symbols[_random.nextInt(symbols.length)]));
      
      if (!_hasWin(grid)) {
        patterns.add(grid);
      }
    }

    return patterns;
  }

  // Helper untuk membuat grid kosong
  static List<List<String>> _emptyGrid() =>
      List.generate(4, (_) => List.generate(4, (_) => _randomSymbol()));

  // Helper untuk memilih simbol acak
  static String _randomSymbol() => symbols[_random.nextInt(symbols.length)];

  // Cek apakah grid memiliki pola menang
  static bool _hasWin(List<List<String>> grid) {
    // Horizontal
    for (int row = 0; row < 4; row++) {
      if (grid[row][0] != '🎰' && 
          grid[row][0] == grid[row][1] &&
          grid[row][1] == grid[row][2] &&
          grid[row][2] == grid[row][3]) {
        return true;
      }
    }

    // Vertical
    for (int col = 0; col < 4; col++) {
      if (grid[0][col] != '🎰' && 
          grid[0][col] == grid[1][col] &&
          grid[1][col] == grid[2][col] &&
          grid[2][col] == grid[3][col]) {
        return true;
      }
    }

    // Diagonal (main)
    if (grid[0][0] != '🎰' && 
        grid[0][0] == grid[1][1] &&
        grid[1][1] == grid[2][2] &&
        grid[2][2] == grid[3][3]) {
      return true;
    }

    // Diagonal (anti)
    if (grid[0][3] != '🎰' && 
        grid[0][3] == grid[1][2] &&
        grid[1][2] == grid[2][1] &&
        grid[2][1] == grid[3][0]) {
      return true;
    }

    return false;
  }

  // Simpan pola ke file JSON
  static void savePatternsToJson(
    List<List<List<String>>> patterns,
    String filePath,
  ) {
    final jsonString = jsonEncode(patterns);
    File(filePath).writeAsStringSync(jsonString);
    print('Saved ${patterns.length} patterns to $filePath');
  }

  // Generate dan simpan semua pola per simbol
  static void generateAndSaveAllPatterns() {
    // Buat direktori jika belum ada
    Directory('patterns').createSync(recursive: true);

     File('assets/patterns/symbol_map.json').writeAsStringSync(
      jsonEncode(symbolFileMap),
    );

    // Generate dan simpan pola kemenangan per simbol
     for (String symbol in symbols) {
      final fileName = symbolFileMap[symbol]!;
      final patterns = generateAllWinningPatternsForSymbol(symbol);
      savePatternsToJson(patterns, 'assets/patterns/${fileName}_win_patterns.json');
    }

    // Generate dan simpan pola kalah
    final losingPatterns = generateLosingPatterns(2000);
    savePatternsToJson(losingPatterns, 'assets/patterns/lose_patterns.json');

    print('\nTotal generated:');
    print('Pola berhasil digenerate!');
    print('- Winning patterns: ${symbols.length} symbols × ~${symbols.length * 15} patterns each');
    print('- Losing patterns: ${losingPatterns.length}');
  }
}

void main() {
  PatternGenerator.generateAndSaveAllPatterns();
}