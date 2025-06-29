// ignore_for_file: unused_field

import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simulasi_slot/dialogs/help_dialog.dart';
import 'package:simulasi_slot/dialogs/reset_dialog.dart';
import 'package:simulasi_slot/dialogs/win_loss_dialog.dart';
import 'package:simulasi_slot/screens/profile_page.dart';
import 'package:simulasi_slot/screens/setting_page.dart';
import 'package:simulasi_slot/utils/game_logic.dart';
import 'package:simulasi_slot/widgets/bottom_nav_bar.dart';
import 'package:simulasi_slot/widgets/slot_machine.dart';
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
  final Set<Point<int>> _winningPositions = {}; // gunakan dart:math Point
  bool _animateAll = false;
  List<WinLine> _winLines = [];
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


  Future<void> _saveGameHistory(bool isWin, int amount, String details) async {
    if (widget.isGuest) return; // Skip untuk guest
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).collection('gameHistory').add({
        'result': isWin ? 'Menang' : 'Kalah',
        'coin': amount,
        'date': DateTime.now(),
        'details': details,
      });
    } catch (e) {
      print('Error saving game history: $e');
    }
  }
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
      _resetSymbolCounts();
      _isSpinning = false;
      _currentSpin = 0;
      _winLines = [];
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) => const ResetSuccessDialog(),
      );
    });
  }
  @override
  Future<void> _spin() async {
    if (_coins < 10 || _isSpinning) return;

    setState(() {
      _coins -= 10;
      _spinCount++;
      _currentSpin++;
      _isSpinning = true;
      _resetSymbolCounts();
      _winLines = []; 
    });

    // Generate new symbols
    List<List<String>> newSymbols = GameLogic.generateSymbols();
    
    // final newSymbols = GameLogic.generateSymbols();
    // Check if we need to force a win
    bool isForceWinNeeded = GameLogic.settings.winPercentage == 1.0;
    String? forceWinSymbol;
    String? forceWinType;
    int? forceWinPosition;

     if (isForceWinNeeded) {
      final winTypes = ['horizontal', 'vertical', 'diagonal'];
      forceWinType = winTypes[Random().nextInt(winTypes.length)];
      
      // Get active symbols
      List<String> activeSymbols = [];
      GameLogic.settings.symbolRates.forEach((symbol, rate) {
        if (rate > 0) activeSymbols.add(symbol);
      });
    if (activeSymbols.isNotEmpty) {
        forceWinSymbol = activeSymbols[Random().nextInt(activeSymbols.length)];
        
        // Determine position based on type
        switch (forceWinType) {
          case 'horizontal':
            forceWinPosition = Random().nextInt(4);
            break;
          case 'vertical':
            forceWinPosition = Random().nextInt(4);
            break;
          case 'diagonal':
            forceWinPosition = Random().nextInt(2); // 0 = down-right, 1 = down-left
            break;
        }
      }
    }

    List<Future> animations = [];
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 4; col++) {
        final isForceWinCell = isForceWinNeeded && 
        GameLogic.isInForceWinPattern(row, col, forceWinType, forceWinPosition);
        final cellSymbol = isForceWinCell ? forceWinSymbol! : newSymbols[row][col];
        animations.add(_startRollingAnimation(row, col, cellSymbol,applyForceWin: isForceWinCell));
      }
    }
    
    await Future.wait(animations);

      if (isForceWinNeeded && forceWinSymbol != null && forceWinType != null && forceWinPosition != null) {
      for (int row = 0; row < 4; row++) {
        for (int col = 0; col < 4; col++) {
          if (GameLogic.isInForceWinPattern(row, col, forceWinType, forceWinPosition)) {
            newSymbols[row][col] = forceWinSymbol;
          }
        }
      }
    }
    
    setState(() {
      _rows = newSymbols;
      // _checkWin();
      _isSpinning = false;
    });
    await Future.delayed(const Duration(milliseconds: 1000));
    if(mounted){
      _checkWin();
    }

  }

  Future<void> _startRollingAnimation(int row, int col, String finalSymbol, {bool applyForceWin = false}) async {
    setState(() => _isRolling[row][col] = true);
    
    List<String> rollingSymbols = List.generate(20, (_) => GameLogic.getRandomSymbol());
    // Apply forced win in the middle of animation
    if (applyForceWin) {
      // Replace symbols in the middle of the animation
      for (int i = 10; i < 15; i++) {
        rollingSymbols[i] = finalSymbol;
      }
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

  Future<void> _checkWin() async {
  // Cek apakah spin ini memenuhi syarat untuk bisa menang
  await Future.delayed(const Duration(milliseconds: 50));
  bool canWin = _currentSpin >= GameLogic.settings.minSpinToWin;
  if (!canWin) {
    String lossMessage = 'Spin minimum belum tercapai (${GameLogic.settings.minSpinToWin})\nSaldo: $_coins';
    if (_spinCount % 5 == 0) {
      lossMessage += '\n\nℹ️ Anda perlu ${GameLogic.settings.minSpinToWin} spin untuk mulai mendapatkan kemenangan';
    }
    _saveGameHistory(false, -10, lossMessage);
    _showMessage(lossMessage, isWin: false);
    return;
  }
  // Cek garis-garis yang menang (4 simbol)
    _winLines = GameLogic.checkWinLines(_rows);
    int totalReward = 0;
    
    bool forceWin = GameLogic.settings.winPercentage == 1.0;
    // Jika winPercentage 100% dan tidak ada garis menang alami, buat garis menang paksa
  if (forceWin && _winLines.isEmpty) {
    // Pilih simbol acak yang aktif
    final winTypes = ['horizontal', 'vertical', 'diagonal'];
    final random = Random();
    final selectedType = winTypes[random.nextInt(winTypes.length)];

    List<String> activeSymbols = [];
    GameLogic.settings.symbolRates.forEach((symbol, rate) {
      if (rate > 0) activeSymbols.add(symbol);
    });
    
    if (activeSymbols.isNotEmpty) {
      String winSymbol = activeSymbols[Random().nextInt(activeSymbols.length)];
      final newRows = List<List<String>>.from(_rows);

      switch (selectedType) {
        case 'horizontal':
          final rowIdx = random.nextInt(4);
          for (int col = 0; col < 4; col++) {
            newRows[rowIdx][col] = winSymbol;
          }
          break;

        case 'vertical':
          final colIdx = random.nextInt(4);
          for (int row = 0; row < 4; row++) {
            newRows[row][colIdx] = winSymbol;
          }
          break;

        case 'diagonal':
          final direction = random.nextBool() ? 'down-right' : 'down-left';
          if (direction == 'down-right') {
            for (int i = 0; i < 4; i++) {
              newRows[i][i] = winSymbol;
            }
          } else {
            for (int i = 0; i < 4; i++) {
              newRows[i][3 - i] = winSymbol;
            }
          }
          break;
      }
      setState(() => _rows = newRows);
      // Beri sedikit delay untuk animasi
      await Future.delayed(const Duration(milliseconds: 300));

      // Hitung ulang winLines dengan pola baru
    }}
      _winLines = GameLogic.checkWinLines(_rows);
     if (_winLines.isNotEmpty) {
      for (var line in _winLines) {
        totalReward += line.reward;
      }
      setState(() {
        _animateAll = true;
        
      });
      await Future.delayed(const Duration(milliseconds: 800));
      setState(() {
        _animateAll = false;
        
      });
     setState(() {
        _coins += totalReward;
      });
      // Format detail kemenangan
      String details = _winLines.map((line) {
        String position = "";
        switch (line.lineType) {
          case 'horizontal':
            position = "Baris ${line.row! + 1} kolom 1-4";
            break;
          case 'vertical':
            position = "Kolom ${line.col! + 1} baris 1-4";
            break;
          case 'diagonal':
            position = "Diagonal ${line.direction == 'down-right' ? 'kiri-kanan' : 'kanan-kiri'}";
            break;
        }
        return "4x ${line.symbol} ($position) → +${line.reward}";
      }).join("\n");
      _saveGameHistory(true, totalReward,
        "Spin: $_spinCount | Kemenangan: +$totalReward Koin\n$details");
      _showMessage(
        "Kemenangan: +$totalReward Koin\n$details",
        isWin: true,
      );
    } else {
      _saveGameHistory(false, -10, "Tidak ada kombinasi pemenang");
      _showMessage(
        'Tidak ada garis menang\n'
        '🎲 Spin: $_spinCount | ✅ Persentase: ${(GameLogic.settings.winPercentage * 100).toInt()}%',
        isWin: false,
      );
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
                winLines: _winLines,
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
            '• SIMULASI INI MEMPERLIHATKAN BAGAIMANA ALGORITMA JUDI ONLINE BEKERJA\n'
            '• TIDAK ADA STRATEGI YANG BISA MENGALAHKAN MESIN YANG DIRANCANG UNTUK MENGUNTUNGKAN PEMILIK\n'
            '• JUDI MENYEBABKAN KETERGANTUNGAN, MASALAH KEUANGAN, DAN KERETAKAN KELUARGA',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red, fontSize: 12),
            
          ),
        
        ),const SizedBox(height: 5),
        ElevatedButton(
              onPressed: () => _showEducationalDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
              ),
              child: const Text('BACA LEBIH LANJUT'),
    ),],
    );
  }
  void _showEducationalDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('EDUKASI ANTI JUDI', style: TextStyle(color: Colors.red)),
      content: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FAKTA TENTANG PERJUDIAN:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('• 99% pemain judi mengalami kerugian finansial jangka panjang'),
            Text('• Mesin slot dirancang dengan "Return to Player" (RTP) di bawah 100%, artinya pemain selalu dirugikan dalam jangka panjang'),
            Text('• Semakin sering bermain, semakin besar kemungkinan kalah karena algoritma house edge'),
            SizedBox(height: 20),
            Text(
              'BAHAYA PERJUDIAN:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('• Kecanduan judi bisa menyebabkan gangguan mental'),
            Text('• Banyak kasus perceraian dan masalah keluarga akibat judi'),
            Text('• 1 dari 5 pecandu judi mencoba bunuh diri'),
            SizedBox(height: 20),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('MENGERTI',selectionColor: Colors.red, style: TextStyle(color: Colors.red),)
        ),
      ],
    ),
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