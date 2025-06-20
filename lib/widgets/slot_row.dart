import 'package:flutter/material.dart';
import 'slot_column.dart';

class SlotRow extends StatelessWidget {
  final int rowIndex;
  final List<String> symbols;
  final List<ScrollController> scrollControllers;
  final List<bool> isRolling;

  const SlotRow({
    super.key,
    required this.rowIndex,
    required this.symbols,
    required this.scrollControllers,
    required this.isRolling,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: symbols.asMap().entries.map((entry) {
          int colIndex = entry.key;
          return SlotColumn(
            row: rowIndex,
            col: colIndex,
            finalSymbol: entry.value,
            isRolling: isRolling[colIndex],
            controller: scrollControllers[colIndex],
          );
        }).toList(),
      ),
    );
  }
}