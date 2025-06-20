import 'dart:async';

import 'package:firebase_auth101/screens/profile_page.dart';
import 'package:firebase_auth101/screens/setting_page.dart';
import 'package:flutter/material.dart';
import '../widgets/slot_machine.dart';
import '../dialogs/help_dialog.dart';
import '../dialogs/reset_dialog.dart';
import '../dialogs/win_loss_dialog.dart';
import '../widgets/bottom_nav_bar.dart';
import '../utils/game_logic.dart';


class SlotGameScreen extends StatefulWidget {
  final bool isGuest;
  const SlotGameScreen({super.key, this.isGuest = false});
  @override
  State<SlotGameScreen> createState() => _SlotGameScreenState();
}

class _SlotGameScreenState extends State<SlotGameScreen> {
  int _coins = 500;
  List<List<String>> _rows = List.generate(4, (_) => List.filled(4, '🎰'));
  int _spinCount = 0;
  bool _isSpinning = false;
  int _currentNavIndex = 1;
  late PageController _pageController;
  List<List<ScrollController>> _scrollControllers = [];
  List<List<bool>> _isRolling = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentNavIndex);
    if (widget.isGuest) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anda masuk dalam mode tamu. Data tidak akan disimpan.'),
            duration: Duration(seconds: 3),
          ),
        );
      });
    }
    _initScrollControllers();
  }

  void _initScrollControllers() {
    _scrollControllers = [];
    _isRolling = [];
    for (int i = 0; i < 4; i++) {
      List<ScrollController> rowControllers = [];
      List<bool> rowRolling = [];
      for (int j = 0; j < 4; j++) {
        rowControllers.add(ScrollController());
        rowRolling.add(false);
      }
      _scrollControllers.add(rowControllers);
      _isRolling.add(rowRolling);
    }
  }

  void _resetGame() {
    setState(() {
      _coins = 500;
      _spinCount = 0;
      _rows = List.generate(4, (_) => List.filled(4, '🎰'));
      _initScrollControllers();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) => const ResetSuccessDialog(),
      );
    });
  }

  Future<void> _spin() async {
    if (_coins < 50 || _isSpinning) return;

    setState(() {
      _coins -= 50;
      _spinCount++;
      _isSpinning = true;
    });
    
    final newSymbols = GameLogic.generateSymbols();
    List<Future> animations = [];
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 4; col++) {
        animations.add(_startRollingAnimation(row, col, newSymbols[row][col]));
      }
    }
    
    await Future.wait(animations);
    
    setState(() {
      _rows = newSymbols;
      _checkWin();
      _isSpinning = false;
    });
  }

  Future<void> _startRollingAnimation(int row, int col, String finalSymbol) async {
    setState(() => _isRolling[row][col] = true);
    
    List<String> rollingSymbols = [];
    for (int i = 0; i < 20; i++) {
      rollingSymbols.add(GameLogic.getRandomSymbol());
    }
    rollingSymbols.add(finalSymbol);
    
    const double itemHeight = 70.0;
    final double targetOffset = rollingSymbols.length * itemHeight;
    
    final completer = Completer<void>();
    _scrollControllers[row][col].animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOut,
    ).then((_) {
      setState(() => _isRolling[row][col] = false);
      completer.complete();
    });
    
    return completer.future;
  }

  void _checkWin() {
    Map<String, int> counts = {};
    bool hasWon = false;
    
    for (var row in _rows) {
      for (var symbol in row) {
        counts[symbol] = (counts[symbol] ?? 0) + 1;
      }
    }

    counts.forEach((symbol, count) {
      int reward = GameLogic.calculateReward(symbol, count);
      if (reward > 0) {
        setState(() {
          _coins += reward;
          hasWon = true;
        });
        _showMessage(
          'Kemenangan $symbol: $count+$reward Koin\n'
          '💡 Kemenangan kecil untuk membuat Anda terus bermain',
          isWin: true,
        );
      }
    });

    if (!hasWon) {
      String lossMessage = 'Tidak ada kemenangan\nSaldo: $_coins';
      if (_spinCount % 5 == 0) {
        lossMessage += '\n\n💸 Fakta: 80% pemain kehilangan >60% saldo dalam 10 spin';
      }
      _showMessage(lossMessage, isWin: false);
    }
  }

  void _showMessage(String message, {required bool isWin}) {
    showDialog(
      context: context,
      builder: (context) => WinLossDialog(
        message: message,
        isWin: isWin,
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => const HelpDialog(),
    );
  }

  void _handleNavTap(int index) {
    setState(() {
      _currentNavIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  Widget _buildSlotScreen() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Center(
              child: SlotMachine(
                rows: _rows,
                scrollControllers: _scrollControllers,
                isRolling: _isRolling,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.casino, size: 28),
            label: const Text('PUTAR', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade800,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
              elevation: 5,
            ),
            onPressed: _isSpinning ? null : _spin,
          ),
        ),
        Container(
          color: Colors.red.shade50,
          padding: const EdgeInsets.all(12),
          child: const Text(
            'SIMULASI INI MEMPERLIHATKAN BAGAIMANA ALGORITMA JUDI ONLINE BEKERJA\n'
            'HANYA UNTUK EDUKASI - JANGAN COBA DI DUNIA NYATA',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SLOT MACHINE SIMULATOR'),
        backgroundColor: Colors.red.shade900,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelp,
            tooltip: 'Cara Bermain',
          ),
          if (_currentNavIndex == 1) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Chip(
                label: Text('$_coins 🪙', 
                  style: const TextStyle(color: Colors.white)),
                backgroundColor: Colors.red.shade700,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.restart_alt, color: Colors.white),
              onPressed: _resetGame,
              tooltip: 'Reset Game',
            ),
          ],
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) => setState(() => _currentNavIndex = index),
        children: [
          const ProbabilitySettingsPage2(),
          _buildSlotScreen(),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _handleNavTap,
      ),
    );
  }

  @override
  void dispose() {
    for (var row in _scrollControllers) {
      for (var controller in row) {
        controller.dispose();
      }
    }
    _pageController.dispose();
    super.dispose();
  }
}