// slot_column.dart (diperbarui)
import 'package:flutter/material.dart';
import '../utils/game_logic.dart';

class SlotColumn extends StatefulWidget {
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
  State<SlotColumn> createState() => _SlotColumnState();
}

class _SlotColumnState extends State<SlotColumn> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  // bool _hasSpun = false;
  bool _shouldAnimate = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void didUpdateWidget(covariant SlotColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger rotation when spinning stops
    if (!widget.isRolling && oldWidget.isRolling) {
      _rotationController.reset();
      _rotationController.forward().then((_) {
        // Reset the controller after spinning
        setState(() => _shouldAnimate = false);
      });
    }
    if (widget.isRolling && !oldWidget.isRolling) {
      _shouldAnimate = false;
      _rotationController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    // final shouldRotate = _hasSpun && !widget.isRolling;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: widget.isWinningSymbol ? Colors.yellow : Colors.grey.shade400,
          width: widget.isWinningSymbol ? 3 : 2,
        ),
        boxShadow: widget.isWinningSymbol
            ? [
                BoxShadow(
                  color: Colors.yellow.withOpacity(0.6),
                  blurRadius: 10,
                  spreadRadius: 2
                )
              ]
            : null,
      ),
      child: _shouldAnimate
      ? RotationTransition(
        turns: Tween(begin: 0.5, end: 0.0).animate(
          CurvedAnimation(
            parent: _rotationController,
            curve: Curves.easeOutBack,
          ),
        ),
        child: _buildSymbolList(),
      )
      : _buildSymbolList(),
    );
  }
     
  Widget _buildSymbolList() {
    final symbol = widget.isRolling
        ? [...List.generate(20, (_) => GameLogic.getRandomSymbol()), widget.finalSymbol]
        : [widget.finalSymbol];

        return ListView.builder(
          controller: widget.controller,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: symbol.length,
          itemBuilder: (context, index) {
            return Container(
              height: 70,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: GameLogic.getSymbolColor(symbol[index]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                symbol[index],
                style: const TextStyle(fontSize: 28),
              ),
            );      
          },
        );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }
}