import 'package:simulasi_slot/utils/pattern_generator.dart';

void main() {
  final winPatterns = PatternGenerator.generateWinningPatterns();
  final losePatterns = PatternGenerator.generateLosingPatterns(100);

  PatternGenerator.savePatternsToJson(winPatterns, 'assets/win_patterns.json');
  PatternGenerator.savePatternsToJson(losePatterns, 'assets/lose_patterns.json');

  print('✅ Kombinasi disimpan: ${winPatterns.length} menang + ${losePatterns.length} kalah');
}
