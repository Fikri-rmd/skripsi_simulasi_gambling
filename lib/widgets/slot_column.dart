import 'package:flutter/material.dart';
import '../utils/game_logic.dart';

class SlotColumn extends StatelessWidget {
  final int row;
  final int col;
  final String finalSymbol;
  final bool isRolling;
  final ScrollController controller;
  final bool isWinningSymbol;

  const SlotColumn({
    super.key,
    required this.row,
    required this.col,
    required this.finalSymbol,
    required this.isRolling,
    required this.controller,
    required this.isWinningSymbol,
  });

  @override
  Widget build(BuildContext context) {
    // PERBAIKAN: Gunakan if-else biasa atau spread operator
    // List<String> symbols;
    // if (isRolling) {
    //   symbols = List.generate(20, (_) => GameLogic.getRandomSymbol());
    //   symbols.add(finalSymbol);
    // } else {
    //   symbols = [finalSymbol];
    // }

    // Alternatif dengan spread operator:
    List<String> symbols = isRolling
      ? [...List.generate(20, (_) => GameLogic.getRandomSymbol()), finalSymbol]
      : [finalSymbol];

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
                color : isWinningSymbol ? Colors.yellow : Colors.grey.shade400,
                width: isWinningSymbol ? 3 : 2,
              ),
            boxShadow: isWinningSymbol
                ? [BoxShadow(
                    color: Colors.yellow.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )]
                : null,
            ),
            
            child: Text(
              symbols[index],
              style: TextStyle(
              fontSize: 28,
              shadows: isWinningSymbol
                  ? [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 10,
                        offset: const Offset(0, 0),),
                    ]
                  : null,
              ),
            ),
          );
        },  
      ),
    );
  }
}

