import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simulasi_slot/dialogs/help_dialog.dart';
import 'package:simulasi_slot/dialogs/reset_dialog.dart';
import 'package:simulasi_slot/dialogs/win_loss_dialog.dart';
import 'package:simulasi_slot/screens/profile_page.dart';
import 'package:simulasi_slot/screens/setting_page.dart';
import 'package:simulasi_slot/services/user_service.dart';
import 'package:simulasi_slot/utils/game_logic.dart';
import 'package:simulasi_slot/widgets/bottom_nav_bar.dart';
import 'package:simulasi_slot/widgets/slot_machine.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SlotGameScreen extends StatefulWidget {
  final bool isGuest;
  const SlotGameScreen({super.key, this.isGuest = false});

  @override
  State<SlotGameScreen> createState() => _SlotGameScreenState();
}

class _SlotGameScreenState extends State<SlotGameScreen> {
  int _coins = 500;
  List<WinLine> _winLines = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _totalSpinCounter = 0;
  int _spinCount = 0;
  bool _isSpinning = false;
  int _currentNavIndex = 1;
  late PageController _pageController;
  List<List<ScrollController>> _scrollControllers = [];
  List<List<bool>> _isRolling = [];
  Map<String, int> _symbolFrequency = {};
  int _winCount = 0;
  int _loseCount = 0;

  @override
  void initState() {
    super.initState();
    _initAll();
    _initUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final isFirstRun = prefs.getBool('first_run') ?? true;
      
      if (isFirstRun) {
        await _resetGameStatistics();
        await prefs.setBool('first_run', false);
      }
    });
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

  Future<void> _initAll() async {
    await GameLogic.initialize();
    await _loadSpinCounter(); 
    await _loadStatistics();
    setState(() {});
  }
  
  void _handleSettingsUpdated() {
    setState(() {});
  }

  Future<void> _resetGameStatistics() async {
    await GameLogic.resetStatistics();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('winPercentage');
    await prefs.remove('minSpinToWin');
    final keys = prefs.getKeys();
    for (String key in keys) {
      if (key.startsWith('symbol_')) {
        await prefs.remove(key);
      }
    }
    
    setState(() {
      _totalSpinCounter = 0;
      _winCount = 0;
      _loseCount = 0;
      _symbolFrequency = {};
    });
  }

  Future<void> _loadStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    _winCount = prefs.getInt('totalWins') ?? 0;
    _loseCount = prefs.getInt('totalLoses') ?? 0;

    final json = prefs.getString('symbolFreq');
    if (json != null) {
      final decoded = jsonDecode(json);
      _symbolFrequency = Map<String, int>.from(decoded);
    }
  }

  void _initScrollControllers() {
    _scrollControllers = List.generate(4, (i) => List.generate(4, (j) => ScrollController()));
    _isRolling = List.generate(4, (i) => List.generate(4, (j) => false));
  }

  Future<void> _initUserData() async {
    if (widget.isGuest) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      await UserService.saveUserData(
        userId: user.uid,
        nama: user.displayName ?? '',
        email: user.email ?? '',
      );
    } else {
      await _firestore.collection('users').doc(user.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _saveSpinCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalSpinCounter', _totalSpinCounter);
  }

  Future<void> _loadSpinCounter() async {
    final prefs = await SharedPreferences.getInstance();
    _totalSpinCounter = prefs.getInt('totalSpinCounter') ?? 0;
  }

  void _resetGame() async{
    await _saveSpinCounter();
    await GameLogic.resetStatistics();
    GameLogic.initializeOrResetPatternPool();
    setState(()  {
      _coins = 500;
      _spinCount = 0;
      _totalSpinCounter = 0;
      _winCount = 0;
      _rows = List.generate(4, (_) => List.filled(4, '🎰'));
      _initScrollControllers();
      _isSpinning = false;
      _winLines = [];
      _loseCount = 0;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => const ResetSuccessDialog(),
      );
    });
  }

  List<List<String>> _rows = List.generate(4, (_) => List.filled(4, '🎰'));

  Future<void> _spin() async {
    if (_coins < 10 || _isSpinning) return;
    
    setState(() {
      _spinCount++;
      _coins -= 10;
      _isSpinning = true;
      _winLines = [];
      _totalSpinCounter++;
    });
    await _saveSpinCounter();

    final newSymbols = GameLogic.generateSymbols();

    List<Future> animations = [];
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 4; col++) {
        final delay = (row * 4 + col) * 100;
        animations.add(
          Future.delayed(
            Duration(milliseconds: delay),
            () => _startRollingAnimation(row, col, newSymbols[row][col]),
          ),
        );
      }
    }

    await Future.wait(animations);

    setState(() {
      _rows = newSymbols;
      for (var row in newSymbols) {
        for (var symbol in row) {
          _symbolFrequency[symbol] = (_symbolFrequency[symbol] ?? 0) + 1;
        }
      }
    });

    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      _checkWin();
    }
  }

  Future<void> _startRollingAnimation(int row, int col, String finalSymbol) async {
    if (!mounted) return;
    setState(() => _isRolling[row][col] = true);
    
    const int rollingItems = 30;
    List<String> rollingSymbols = List.generate(rollingItems, (_) => GameLogic.getRandomSymbol());
    
    rollingSymbols.add(finalSymbol);

    const double itemHeight = 70.0; 
    final double targetOffset = (rollingSymbols.length - 1) * itemHeight;

    if (_scrollControllers[row][col].hasClients) {
      _scrollControllers[row][col].jumpTo(0);

      await _scrollControllers[row][col].animateTo(
        targetOffset * 0.7,
        duration: const Duration(milliseconds: 3000),
        curve: Curves.easeIn,
      );

      await _scrollControllers[row][col].animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }

    if (mounted) {
      setState(() {
        _isRolling[row][col] = false;
        _rows[row][col] = finalSymbol;
      });
    }
  }

  void _checkWin() {
    _winLines = GameLogic.checkWinLines(_rows);
    bool won = _winLines.isNotEmpty;

    if (won) {
      _winCount++;
      int totalReward = _winLines.fold(0, (sum, line) => sum + line.reward);
      setState(() {
        _coins += totalReward;
      });

      String details = _winLines.map((line) {
        String position = "";
        switch (line.lineType) {
          case 'horizontal':
            position = "Baris ${line.row! + 1}";
            break;
          case 'vertical':
            position = "Kolom ${line.col! + 1}";
            break;
          case 'diagonal':
            position = "Diagonal ${line.direction == 'down-right' ? 'kiri-kanan' : 'kanan-kiri'}";
            break;
        }
        return "4x ${line.symbol} ($position) → +${line.reward}";
      }).join("\n");

      _saveGameHistory(true, totalReward, "Spin: $_spinCount | Kemenangan: +$totalReward Koin\n$details");
      _showMessage("Kemenangan: +$totalReward Koin\n$details", isWin: true);
    } else {
      _loseCount++;
      _saveGameHistory(false, -10, "Tidak ada kombinasi pemenang");
      _showMessage(
        'Tidak ada garis menang\n'
        '🎲 Spin: $_spinCount | ✅ Persentase: ${(GameLogic.settings.winPercentage * 100).toInt()}%',
        isWin: false,
      );
    }
    _saveStatistics();
  }
  Future<void> _saveStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalWins', _winCount);
    await prefs.setInt('totalLoses', _loseCount);
    await prefs.setString('symbolFreq', jsonEncode(_symbolFrequency));
  }

  Future<void> _saveGameHistory(bool isWin, int amount, String details) async {
    if (widget.isGuest) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).collection('gameHistory').add({
        'result': isWin ? 'Menang' : 'Kalah',
        'coin': amount,
        'date': DateTime.now(),
        'details': details,
        'winPercentage': GameLogic.settings.winPercentage,
        'minSpin': GameLogic.settings.minSpinToWin,
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error saving game history: $e');
    }
  }

  void _showMessage(String message, {required bool isWin}) {
    showDialog(
      context: context,
      builder: (context) => WinLossDialog(
        message: message,
        isWin: isWin,
      ),
    ).then((_) {
      if (mounted) {
        setState(() {
          _isSpinning = false;
        });
      }
    });
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
        Text('Menang: $_winCount | Kalah: $_loseCount'),
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
        Text(
          'Total Spin: $_totalSpinCounter',
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(height: 8),
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
        ),
        const SizedBox(height: 5),
        ElevatedButton(
          onPressed: _showEducationalDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          ),
          child: const Text('BACA LEBIH LANJUT'),
        ),
      ],
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
              Text('FAKTA TENTANG PERJUDIAN:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text('• 99% pemain judi mengalami kerugian finansial jangka panjang'),
              Text('• Mesin slot dirancang dengan "Return to Player" (RTP) di bawah 100%, artinya pemain selalu dirugikan dalam jangka panjang'),
              Text('• Semakin sering bermain, semakin besar kemungkinan kalah karena algoritma house edge'),
              SizedBox(height: 20),
              Text('BAHAYA PERJUDIAN:', style: TextStyle(fontWeight: FontWeight.bold)),
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
            child: const Text('MENGERTI', style: TextStyle(color: Colors.red)),
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
                label: Text('$_coins 🪙', style: const TextStyle(color: Colors.white)),
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
            onSettingsUpdated: _handleSettingsUpdated,
            onSaveAndSwitchToSlot: () {
              setState(() {
                _currentNavIndex = 1;
              });
              _pageController.jumpToPage(1);
            },
          ),
          _buildSlotScreen(),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: ModernBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          if (!_isSpinning) {
            _handleNavTap(index);
          }
        },
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