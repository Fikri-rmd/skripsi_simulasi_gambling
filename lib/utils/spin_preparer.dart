import 'package:simulasi_slot/utils/game_logic.dart';

class SpinPreparer {
  static List<List<List<String>>> prepareSpins(int totalSpins, GameSettings settings) {
    final winCount = (settings.winPercentage * totalSpins).round();
    final loseCount = totalSpins - winCount;
    final List<List<List<String>>> spins = [];

    final winSymbol = GameLogic.getSymbolForWin();

    for (int i = 0; i < winCount; i++) {
      spins.add(GameLogic.generateForcedWinGridWithSymbol(winSymbol));
    }

    for (int i = 0; i < loseCount; i++) {
      List<List<String>> grid;
      do {
        grid = GameLogic.generateSymbols();
      } while (GameLogic.checkWinLines(grid).isNotEmpty);
      spins.add(grid);
    }

    spins.shuffle();
    return spins;
  }
}