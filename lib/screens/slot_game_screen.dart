import 'dart:async';

import 'package:firebase_auth101/dialogs/help_dialog.dart';
import 'package:firebase_auth101/dialogs/reset_dialog.dart';
import 'package:firebase_auth101/dialogs/win_loss_dialog.dart';
import 'package:firebase_auth101/screens/profile_page.dart';
import 'package:firebase_auth101/screens/setting_page.dart';
import 'package:firebase_auth101/utils/game_logic.dart';
import 'package:firebase_auth101/widgets/bottom_nav_bar.dart';
import 'package:firebase_auth101/widgets/slot_machine.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SlotGameScreen extends StatefulWidget {
  final bool isGuest;
  const SlotGameScreen({super.key, this.isGuest = false});
  @override
  State<SlotGameScreen> createState() => _SlotGameScreenState();
}

class _SlotGameScreenState extends State<SlotGameScreen> {
  int _coins = 500;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String,int> _symbolCounts = {};
  int _currentSpin = 0;
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
    _resetSymbolCounts();
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
    _loadSettings();
  }
  void _resetSymbolCounts() {
    _symbolCounts = {
      '🍒': 0,
      '🍋': 0,
      '💎': 0,
      '💰': 0,
      '🍊': 0,
      '🔔': 0,
      '🎲': 0,
      '🥇': 0,
      '🍇': 0,
      '🎰': 0,
    };
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

  Future<void> _loadSettings() async {
    final settings = await GameSettings.loadFromPrefs();
    GameLogic.updateSettings(settings);
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
    if (_coins < 10 || _isSpinning) return;

    setState(() {
      _coins -= 10;
      _spinCount++;
      _currentSpin++;
      _isSpinning = true;
      _resetSymbolCounts();
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
    
    List<String> rollingSymbols = List.generate(20, (_) => GameLogic.getRandomSymbol());
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
  // Cek apakah spin ini memenuhi syarat untuk bisa menang
  // bool canWin = GameLogic.shouldWin(_spinCount);
  bool canWin = _currentSpin >= GameLogic.settings.minSpinToWin;
  if (!canWin) {
    String lossMessage = 'Spin minimum belum tercapai (${GameLogic.settings.minSpinToWin})\nSaldo: $_coins';
    if (_spinCount % 5 == 0) {
      lossMessage += '\n\nℹ️ Anda perlu ${GameLogic.settings.minSpinToWin} spin untuk mulai mendapatkan kemenangan';
    }
    _showMessage(lossMessage, isWin: false);
    return;
  }

  List<String> activeSymbols = [];
  GameLogic.settings.symbolRates.forEach((symbol, rate) {
    if (rate > 0) activeSymbols.add(symbol);
  });
  if (activeSymbols.length < 5) {
    activeSymbols.addAll(['🍒', '🍋', '🍊','💎','💰']);
  }

  // Hitung reward berdasarkan simbol yang muncul
  Map<String, int> counts = {};
  int totalReward = 0;
  bool hasWinningCombination = false;
  
  for (var row in _rows) {
    for (var symbol in row) {
      counts[symbol] = (counts[symbol] ?? 0) + 1;
    }
  }

  final winningCombinations = [
    { 'symbol': '🍒', 'count': 6, 'reward': 1 },
    { 'symbol': '🍋', 'count': 5, 'reward': 2 },
    { 'symbol': '💎', 'count': 4, 'reward': 10 },
    { 'symbol': '💰', 'count': 3, 'reward': 30 },
    { 'symbol': '🍊', 'count': 5, 'reward': 3 },
    { 'symbol': '🔔', 'count': 5, 'reward': 4 },
    { 'symbol': '🎲', 'count': 5, 'reward': 5 },
    { 'symbol': '🥇', 'count': 5, 'reward': 6 },
    { 'symbol': '🍇', 'count': 5, 'reward': 7 },
  ].where((combo) => activeSymbols.contains(combo['symbol'])).toList();
  for (var combo in winningCombinations) {
    final symbol = combo['symbol'] as String;
    final requiredCount = combo['count'] as int;
    final rewardValue = combo['reward'] as int;
    
    if ((counts[symbol] ?? 0) >= requiredCount) {
      totalReward += rewardValue;
      hasWinningCombination = true;
    }
  }
   // Jika ada kombinasi pemenang
  if (hasWinningCombination) {
    setState(() {
      _coins += totalReward;
    });
    _showMessage(
      'Kemenangan: +$totalReward Koin\n'
      '🎲 Kombinasi simbol berhasil!',
      isWin: true,
    );
  } else {
    // Meskipun persentase kemenangan terpenuhi, tapi tidak ada kombinasi
    _showMessage(
      'Tidak ada kombinasi pemenang\n'
      '🎲 Spin: $_spinCount | ✅ Persentase: ${(GameLogic.settings.winPercentage * 100).toInt()}%',
      isWin: false,
    );
  }
  int? _getMaxCountForSymbol(String symbol) {
    final Map<String, int> maxCounts = {
      '🍒': 6,
      '🍋': 5,
      '💎': 4,
      '💰': 3,
      '🍊': 5,
      '🔔': 5,
      '🎲': 5,
      '🥇': 5,
      '🍇': 5,
    };
    
    return maxCounts[symbol];
  }
  // counts.forEach((symbol, count) {
  //   int reward = GameLogic.calculateReward(symbol, count);
  //   if (symbol == '🍒' && count >= 6) reward = 1;
  //   else if (symbol == '🍋' && count >= 5) reward = 2;
  //   else if (symbol == '💎' && count >= 4) reward = 10;
  //   else if (symbol == '💰' && count >= 3) reward = 30;
  //   else if (symbol == '🍊' && count >= 5) reward = 3;
  //   else if (symbol == '🔔' && count >= 5) reward = 4;
  //   else if (symbol == '🎲' && count >= 5) reward = 5;
  //   else if (symbol == '🥇' && count >= 5) reward = 6;
  //   else if (symbol == '🍇' && count >= 5) reward = 7;
  //   if (reward > 0) {
  //     totalReward += reward;
  //     hasWon = true;
  //   }
  // });
  

  // if (hasWon) {
  //   setState(() {
  //     _coins += totalReward;
  //   });
  //   _showMessage(
  //     'Kemenangan: +$totalReward Koin\n'
  //     'Spin: $_spinCount | ✅ Persentase: ${(GameLogic.settings.winPercentage * 100).toInt()}%',
  //     isWin: true,
  //   );
  // } else {
  //   _showMessage(
  //     'Tidak ada kombinasi pemenang\n'
  //     'Spin: $_spinCount | ✅ Persentase: ${(GameLogic.settings.winPercentage * 100).toInt()}%',
  //     isWin: false,
  //   );
  // }
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

  Future<void> _openSettings() async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProbabilitySettingsPage(
        initialWinPercentage: GameLogic.settings.winPercentage,
        initialMinSpinToWin: GameLogic.settings.minSpinToWin,
        initialSymbolRates: GameLogic.settings.symbolRates,
      ),
    ),
  );
  
  // Setelah kembali dari settings page, muat ulang pengaturan
  final settings = await GameSettings.loadFromPrefs();
  GameLogic.updateSettings(settings);
}

  // Future<void> _openSettings() async {
  //   final result = await Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => ProbabilitySettingsPage(
  //         initialWinPercentage: GameLogic.settings.winPercentage,
  //         initialMinSpinToWin: GameLogic.settings.minSpinToWin,
  //         initialSymbolRates: GameLogic.settings.symbolRates,
  //       ),
  //     ),
  //   );

  //   if (result != null) {
  //     // Terapkan pengaturan baru
  //     GameLogic.updateSettings(result);
  //     // Simpan ke SharedPreferences
  //     await result.saveToPrefs();
  //   }
  // }

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
          // IconButton(
          //   icon: const Icon(Icons.settings, color: Colors.white),
          //   onPressed: _openSettings,
          //   tooltip: 'Pengaturan',
          // ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) => setState(() => _currentNavIndex = index),
        children: [
          ProbabilitySettingsPage(
            initialWinPercentage: GameLogic.settings.winPercentage,
            initialMinSpinToWin: GameLogic.settings.minSpinToWin,
            initialSymbolRates: GameLogic.settings.symbolRates,
          ),
          _buildSlotScreen(),
          const ProfilePage()
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