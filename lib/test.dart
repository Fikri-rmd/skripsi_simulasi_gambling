import 'package:flutter/material.dart';

class TestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Screen'),
      ),
      body: Center(
        child: Text(
          'Welcome to Test Screen!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
class LCG {
  static const int a = 1664525;
  static const int c = 1013904223;
  static const int m = 4294967296; // 2^32
  int _seed;

  LCG() : _seed = DateTime.now().millisecondsSinceEpoch % m;

  // Generate angka acak
  int generate() {
    _seed = (a * _seed + c) % m;
    return _seed;
  }

  // Cek apakah user menang
  bool isWin(double winPercentage) {
    int randomValue = generate();
    double result = (randomValue % 10000) / 100; // Konversi ke 0.00-99.99
    return result < winPercentage;
  }
}

void main() {
  runApp(MaterialApp(
    home: TestScreen(),
  ));
}