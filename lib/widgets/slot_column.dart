import 'package:flutter/material.dart';
import '../utils/game_logic.dart';

class SlotColumn extends StatelessWidget {
  final int row;
  final int col;
  final String finalSymbol;
  final bool isRolling;
  final ScrollController controller;

  const SlotColumn({
    super.key,
    required this.row,
    required this.col,
    required this.finalSymbol,
    required this.isRolling,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // PERBAIKAN: Gunakan if-else biasa atau spread operator
    List<String> symbols;
    if (isRolling) {
      symbols = List.generate(20, (_) => GameLogic.getRandomSymbol());
      symbols.add(finalSymbol);
    } else {
      symbols = [finalSymbol];
    }

    // Alternatif dengan spread operator:
    // List<String> symbols = isRolling
    //   ? [...List.generate(20, (_) => GameLogic.getRandomSymbol()), finalSymbol]
    //   : [finalSymbol];

    return Container(
      width: 70,
      child: ListView.builder(
        controller: controller,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: symbols.length,
        itemBuilder: (context, index) {
          return Container(
            height: 70,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: GameLogic.getSymbolColor(symbols[index]),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.shade400,
                width: 2,
              ),
            ),
            child: Text(
              symbols[index],
              style: const TextStyle(fontSize: 28),
            ),
          );
        },
      ),
    );
  }
}