import 'package:flutter/material.dart';
import 'slot_row.dart';

class SlotMachine extends StatelessWidget {
  final List<List<String>> rows;
  final List<List<ScrollController>> scrollControllers;
  final List<List<bool>> isRolling;

  const SlotMachine({
    super.key,
    required this.rows,
    required this.scrollControllers,
    required this.isRolling,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade700,
          width: 4,
        ),
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade300,
            Colors.grey.shade200,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: const Offset(6, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < 4; i++) 
            SlotRow(
              rowIndex: i,
              symbols: rows[i],
              scrollControllers: scrollControllers[i],
              isRolling: isRolling[i],
            ),
        ],
      ),
    );
  }
}