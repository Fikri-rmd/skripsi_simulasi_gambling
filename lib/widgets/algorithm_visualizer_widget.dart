import 'dart:collection';
import 'package:flutter/material.dart';

class AlgorithmVisualizerWidget extends StatelessWidget {
  final Queue<bool> cyclePreview;

  const AlgorithmVisualizerWidget({super.key, required this.cyclePreview});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blueGrey.shade200, width: 1.5),
      ),
      child: Column(
        children: [
          const Text(
            'Siklus Hasil Telah Ditentukan',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: cyclePreview.map((isWin) {
              return Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: isWin ? Colors.green.shade300 : Colors.red.shade300,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.shade400)
                ),
                child: Center(child: Text(isWin ? 'W' : 'L', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}