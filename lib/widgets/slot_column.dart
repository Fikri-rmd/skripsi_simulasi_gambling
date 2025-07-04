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
    return AnimatedContainer(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      width: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isWinningSymbol ? Colors.yellow : Colors.grey.shade400,
          width: isWinningSymbol ? 3 : 1,
        ),
        boxShadow: isWinningSymbol
            ? [
                BoxShadow(
                  color: Colors.yellow.withOpacity(0.6),
                  blurRadius: 8,
                  spreadRadius: 2
                )
              ]
            : null,
      ),
      child: _buildSymbolList(),
    );
  }
  
  Widget _buildSymbolList() {
    final symbols = isRolling
        ? [...List.generate(20, (_) => GameLogic.getRandomSymbol()), finalSymbol]
        : [finalSymbol];
    
    return ListView.builder(
      controller: controller,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: symbols.length,
      itemBuilder: (context, index) {
        return Container(
          height: 70,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: GameLogic.getSymbolColor(symbols[index]),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            symbols[index],
            style: const TextStyle(fontSize: 32),
          ),
        );      
      },
    );
  }
}