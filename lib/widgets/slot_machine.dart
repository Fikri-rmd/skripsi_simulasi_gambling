import 'package:flutter/material.dart';
import 'package:firebase_auth101/utils/game_logic.dart';

class SlotMachine extends StatelessWidget {
  final List<List<String>> rows;
  final List<List<ScrollController>> scrollControllers;
  final List<List<bool>> isRolling;
  final List<WinLine> winLines;

  const SlotMachine({
    super.key,
    required this.rows,
    required this.scrollControllers,
    required this.isRolling,
    required this.winLines,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Slot machine grid
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: List.generate(4, (row) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (col) {
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SizedBox(
                      width: 70,
                      height: 70,
                      child: Stack(
                        children: [
                          // Symbol display
                          Center(
                            child: Text(
                              rows[row][col],
                              style: const TextStyle(fontSize: 40),
                            ),
                          ),
                          
                          // Highlight win lines
                          if (_isInWinLine(row, col))
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.yellow,
                                  width: 3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              );
            }),
          ),
        ),
        
        // Win line indicators
        ..._buildWinLineIndicators(),
      ],
    );
  }

  bool _isInWinLine(int row, int col) {
    for (var line in winLines) {
      switch (line.lineType) {
        case 'horizontal':
          if (line.row == row) {
            return true;
          }
          break;
        case 'vertical':
          if (line.col == col) {
            return true;
          }
          break;
        case 'diagonal':
          if (line.direction == 'down-right') {
            if (row == col) {
              return true;
            }
          } else if (line.direction == 'down-left') {
            if (row + col == 3) {
              return true;
            }
          }
          break;
      }
    }
    return false;
  }

  List<Widget> _buildWinLineIndicators() {
    List<Widget> indicators = [];
    const double indicatorSize = 30.0;
    const double cellSize = 78.0;
    const double offset = 15.0;
    
    for (var line in winLines) {
      double top = 0, left = 0;
      
      switch (line.lineType) {
        case 'horizontal':
          top = offset + (line.row! * cellSize) + (cellSize / 2) - (indicatorSize / 2);
          left = offset + (cellSize * 1.5) - (indicatorSize / 2); // Tengah horizontal
          indicators.add(Positioned(
            top: top,
            left: left,
            child: const Icon(Icons.horizontal_rule, 
              color: Colors.yellow, 
              size: indicatorSize),
          ));
          break;
          
        case 'vertical':
          top = offset + (cellSize * 1.5) - (indicatorSize / 2); // Tengah vertikal
          left = offset + (line.col! * cellSize) + (cellSize / 2) - (indicatorSize / 2);
          indicators.add(Positioned(
            top: top,
            left: left,
            child: const Icon(Icons.vertical_align_center, 
              color: Colors.yellow, 
              size: indicatorSize),
          ));
          break;
          
        case 'diagonal':
          top = offset + (cellSize * 1.5) - (indicatorSize / 2);
          left = offset + (cellSize * 1.5) - (indicatorSize / 2);
          
          double rotation = line.direction == 'down-right' ? 0.785 : -0.785;
          
          indicators.add(Positioned(
            top: top,
            left: left,
            child: Transform.rotate(
              angle: rotation,
              child: const Icon(Icons.trending_up, 
                color: Colors.yellow, 
                size: indicatorSize),
            ),
          ));
          break;
      }
    }
    
    return indicators;
  }
}