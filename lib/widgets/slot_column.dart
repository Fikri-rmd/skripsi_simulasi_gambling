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
  late AnimationController _highlightController;
  late Animation<double> _highlightAnimation;
  bool _showHighlight = false;

  @override
  void initState() {
    super.initState();
    
    _highlightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _highlightAnimation = CurvedAnimation(
      parent: _highlightController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(SlotColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (!widget.isRolling && widget.isWinningSymbol && !_showHighlight) {
      _showHighlight = true;
      Future.delayed(const Duration(milliseconds: 300 ), () {
        if (mounted) {
          _highlightController.forward();
        }
      });
    } else if (widget.isRolling && _showHighlight) {
      _showHighlight = false;
      _highlightController.reset();
    }
  }

  @override
  void dispose() {
    _highlightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: AnimatedBuilder(
        animation: _highlightAnimation,
        builder: (context, child) {
          final glowIntensity = _highlightAnimation.value;
          
          return Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(  
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: widget.isWinningSymbol 
                    ? Color.lerp(Colors.grey.shade400, const Color.fromARGB(255, 255, 59, 59), glowIntensity)!
                    : Colors.grey.shade400,
                width: widget.isWinningSymbol ? glowIntensity * 1 + 1 : 1,
              ),
              boxShadow: widget.isWinningSymbol && _showHighlight
                  ? [
                      BoxShadow(
                        color: const Color.fromARGB(255, 255, 0, 0).withOpacity(0.3 * glowIntensity),
                        blurRadius: 5 * glowIntensity + 5,
                        spreadRadius: 5 * glowIntensity,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : null,
            ),
            child: child,
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: _buildSymbolList()
        ),
      ),
    );
  }
  
  Widget _buildSymbolList() {
    final symbols = widget.isRolling
        ? [...List.generate(20, (_) => GameLogic.getRandomSymbol()), widget.finalSymbol]
        : [widget.finalSymbol];
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView.builder(
          controller: widget.controller,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: symbols.length,
          itemBuilder: (context, index) {
            return Container(
              height: constraints.maxHeight,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: GameLogic.getSymbolColor(symbols[index]),
              ),
              child: Text(
                symbols[index],
                style: TextStyle(
                  fontSize: constraints.maxHeight * 0.5,
                  shadows: widget.isWinningSymbol && _showHighlight
                      ? [
                          Shadow(
                            color: Colors.white.withOpacity(_highlightAnimation.value),
                            blurRadius: 10 * _highlightAnimation.value,
                          )
                        ]
                      : null,
                ),
              ),
            );      
          },
        );
      }
    );
  }
}