import 'package:simulasi_slot/utils/game_logic.dart';
import 'package:flutter/material.dart';
import 'slot_column.dart';

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
    return Container(
      height: 70,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: symbols.asMap().entries.map((entry) {
          final colIndex = entry.key;
          final symbols = entry.value;
          // int colIndex = entry.key;
          // bool isWinning = _isInWinLine(rowIndex, colIndex);
          final isWinning = winLines.any((line) {
            switch (line.lineType) {
              case 'horizontal':
                return line.row == rowIndex;
              case 'vertical':
                return line.col == colIndex;
              case 'diagonal':
                // if (line.direction == 'down-right') return rowIndex == colIndex;
                // if (line.direction == 'down-left') return rowIndex + colIndex == symbols.length - 1; 
                
                if (line.direction == 'down-right') {
                  return rowIndex == colIndex;
                } else if (line.direction == 'down-left') {
                  return rowIndex + colIndex == symbols.length - 1; // Assuming 4 rows/columns
                }
                return false;
              default:
                return false;
            }
          });
          return SlotColumn(
            row: rowIndex,
            col: colIndex,
            finalSymbol: entry.value,
            isRolling: isRolling[colIndex],
            controller: scrollControllers[colIndex],
            // isWinningSymbol: isWinning,
            isWinningSymbol: isWinning,
          );
        }).toList(),
      ),
    );
  }
  // bool _isInWinLine(int row, int col) {
  //   for (var line in winLines) {
  //     switch (line.lineType) {
  //       case 'horizontal':
  //         if (line.row == row) {
  //           return true;
  //         }
  //         break;
  //       case 'vertical':
  //         if (line.col == col) {
  //           return true;
  //         }
  //         break;
  //       case 'diagonal':
  //         if (line.direction == 'down-right') {
  //           if (row == col) {
  //             return true;
  //           }
  //         } else if (line.direction == 'down-left') {
  //           if (row + col == 3) {
  //             return true;
  //           }
  //         }
  //         break;
  //     }
  //   }
  //   return false;
  // }
}