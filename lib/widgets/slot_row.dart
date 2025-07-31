import 'package:flutter/material.dart';
import 'slot_column.dart';
import 'package:simulasi_slot/utils/game_logic.dart';

class SlotRow extends StatelessWidget {
  final int rowIndex;
  final List<String> symbols;
  final List<ScrollController> scrollControllers;
  final List<bool> isRolling;
  final List<WinLine> winLines;
  

  const SlotRow({
    super.key,
    required this.rowIndex,
    required this.symbols,
    required this.scrollControllers,
    required this.isRolling,
    required this.winLines,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: symbols.asMap().entries.map((entry) {
          final colIndex = entry.key;
    
          final isWinning = winLines.any((line) {
            switch (line.lineType) {
              case 'horizontal':
                return line.row == rowIndex;
              case 'vertical':
                return line.col == colIndex;
              case 'diagonal':
                
                if (line.direction == 'down-right') {
                  return rowIndex == colIndex;
                } else if (line.direction == 'down-left') {
                  return rowIndex + colIndex == 3;
                }
                return false;
              default:
                return false;
            }
          });
          return Expanded(
            child: SlotColumn(
              row: rowIndex,
              col: colIndex,
              finalSymbol: entry.value,
              isRolling: isRolling[colIndex],
              controller: scrollControllers[colIndex],
              isWinningSymbol: isWinning,
            ),
          );
        }).toList(),
      ),
    );
  }
}