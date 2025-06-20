import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

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
  int _currentNavIndex = 1; // Default to home screen
  late PageController _pageController;
  
  // Kontroler untuk efek roll vertikal
  List<List<ScrollController>> _scrollControllers = [];
  List<List<bool>> _isRolling = [];

  final List<Map<String, dynamic>> _symbolProbabilities = [
    {'symbol': '🍒', 'weight': 30},
    {'symbol': '🍊', 'weight': 10},
    {'symbol': '🔔', 'weight': 15},
    {'symbol': '🎲', 'weight': 5},
    {'symbol': '🥇', 'weight': 3},
    {'symbol': '🍇', 'weight': 12},
    {'symbol': '🍋', 'weight': 25},
    {'symbol': '💎', 'weight': 8},
    {'symbol': '💰', 'weight': 2},
  ];
  final Random _random = Random();
  
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
    // Inisialisasi scroll controllers
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

  void _showResetSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 40),
          title: Text(
            'Reset Berhasil!',
            style: TextStyle(
              color: Colors.red.shade900,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: Text(
            'Permainan telah direset ke kondisi awal\n'
            '🪙 Saldo: 500 Koin\n'
            '🔁 Spin Counter: 0',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'MULAI LAGI',
                style: TextStyle(
                  color: Colors.red.shade900,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
         ) );
      },
    );
  }

  void _resetGame() {
    setState(() {
      _coins = 500;
      _spinCount = 0;
      _rows = List.generate(4, (_) => List.filled(4, '🎰'));
      _initScrollControllers(); // Reset scroll controllers
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showResetSuccessDialog();
    });
  }

  Future<void> _spin() async {
    if (_coins < 50 || _isSpinning) return;

    setState(() {
      _coins -= 50;
      _spinCount++;
      _isSpinning = true;
    });
    
    // Generate hasil baru terlebih dahulu
    final newSymbols = _generateSymbols();
    
    // Animasikan setiap kolom
    List<Future> animations = [];
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 4; col++) {
        animations.add(_startRollingAnimation(row, col, newSymbols[row][col]));
      }
    }
    
    // Tunggu hingga semua animasi selesai
    await Future.wait(animations);
    
    setState(() {
      _rows = newSymbols;
      _checkWin();
      _isSpinning = false;
    });
  }

  Future<void> _startRollingAnimation(int row, int col, String finalSymbol) async {
    setState(() {
      _isRolling[row][col] = true;
    });
    
    // Buat list simbol panjang untuk efek roll
    List<String> rollingSymbols = [];
    for (int i = 0; i < 20; i++) {
      rollingSymbols.add(_getRandomSymbol());
    }
    rollingSymbols.add(finalSymbol);
    
    // Hitung tinggi setiap item
    const double itemHeight = 70.0;
    final double targetOffset = rollingSymbols.length * itemHeight;
    
    // Scroll ke posisi akhir dengan animasi
    final completer = Completer<void>();
    
    _scrollControllers[row][col].animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOut,
    ).then((_) {
      setState(() {
        _isRolling[row][col] = false;
      });
      completer.complete();
    });
    
    return completer.future;
  }

  String _getRandomSymbol() {
    final int totalWeight = _symbolProbabilities.fold(
      0, 
      (int sum, item) => sum + (item['weight'] as int)
    );
    
    int randomNumber = _random.nextInt(totalWeight);
    int cumulative = 0;
    
    for (var item in _symbolProbabilities) {
      cumulative += item['weight'] as int;
      if (randomNumber < cumulative) {
        return item['symbol'] as String;
      }
    }
    return '🎰';
  }

  List<List<String>> _generateSymbols() {
    final int totalWeight = _symbolProbabilities.fold(
      0, 
      (int sum, item) => sum + (item['weight'] as int)
    );
    
    return List.generate(4, (row) {
      return List.generate(4, (col) {
        int randomNumber = _random.nextInt(totalWeight);
        int cumulative = 0;
        
        for (var item in _symbolProbabilities) {
          cumulative += item['weight'] as int;
          if (randomNumber < cumulative) {
            return item['symbol'] as String;
          }
        }
        return '🎰';
      });
    });
  }

  Widget _buildSlotRow(int rowIndex, List<String> symbols) {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: symbols.asMap().entries.map((entry) {
          int colIndex = entry.key;
          String symbol = entry.value;
          
          return _buildSlotColumn(
            rowIndex, 
            colIndex,
            symbol,
            _isRolling[rowIndex][colIndex]
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSlotColumn(int row, int col, String finalSymbol, bool isRolling) {
    // Buat list simbol untuk efek roll
    List<String> symbols = [];
    if (isRolling) {
      for (int i = 0; i < 20; i++) {
        symbols.add(_getRandomSymbol());
      }
      symbols.add(finalSymbol);
    } else {
      symbols.add(finalSymbol);
    }
    
    return Container(
      width: 70,
      child: ListView.builder(
        controller: _scrollControllers[row][col],
        physics: const NeverScrollableScrollPhysics(),
        itemCount: symbols.length,
        itemBuilder: (context, index) {
          String currentSymbol = symbols[index];
          return Container(
            height: 70,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _getSymbolColor(currentSymbol),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.shade400,
                width: 2,
              ),
            ),
            child: Text(
              currentSymbol,
              style: const TextStyle(fontSize: 28),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSlotMachine() {
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
            _buildSlotRow(i, _rows[i]),
        ],
      ),
    );
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
      int reward = 0;
      if (symbol == '🍒' && count >= 6) reward = 1;
      if (symbol == '🍋' && count >= 5) reward = 2;
      if (symbol == '💎' && count >= 4) reward = 10;
      if (symbol == '💰' && count >= 3) reward = 30;
      if (symbol == '🍊' && count >= 5) reward = 3;
      if (symbol == '🔔' && count >= 5) reward = 4;
      if (symbol == '🎲' && count >= 5) reward = 5;
      if (symbol == '🥇' && count >= 5) reward = 6;
      if (symbol == '🍇' && count >= 5) reward = 7;
      

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
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(isWin ? Icons.celebration : Icons.warning,
                color: isWin ? Colors.green : Colors.red),
            const SizedBox(width: 10),
            Text(isWin ? 'Menang!' : 'Kalah Lagi'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', 
              style: TextStyle(color: isWin ? Colors.green : Colors.red)),
          ),
        ],
      ),
    );
  }

  Color _getSymbolColor(String symbol) {
    switch (symbol) {
      case '🍒': return Colors.pink.shade100;
      case '🍋': return Colors.yellow.shade100;
      case '💎': return Colors.blue.shade100;
      case '💰': return Colors.green.shade100;
      case '🍊': return Colors.orange.shade100;
      case '🔔': return Colors.amber.shade100;
      case '🎲': return Colors.deepPurple.shade100;
      case '🥇': return Colors.amber.shade300;
      case '🍇': return Colors.purple.shade100;
      default: return Colors.grey.shade200;
    }
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('❓ Cara Bermain'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Panduan Bermain Slot Machine Simulator:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              _buildHelpItem('1. Tekan tombol PUTAR untuk memutar mesin slot'),
              _buildHelpItem('2. Setiap putaran akan mengurangi 50 koin dari saldo Anda'),
              _buildHelpItem('3. Dapatkan kombinasi simbol yang sesuai untuk memenangkan hadiah'),
              _buildHelpItem('4. Gunakan menu untuk melihat statistik dan informasi lainnya'),
              _buildHelpItem('5. Reset permainan jika ingin memulai dari awal'),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '⚠️ INGAT: Ini hanya simulasi untuk tujuan edukasi. '
                  'Judi dapat menyebabkan ketagihan dan kerugian finansial!',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('MENGERTI', style: TextStyle(color: Colors.red.shade900)),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildHelpItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  // Screen untuk Setting
  Widget _buildSettingScreen() {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.settings, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            Text(
              'Pengaturan',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade900,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Halaman pengaturan akan dikembangkan lebih lanjut',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  // Screen untuk Profile
  Widget _buildProfileScreen() {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.red,
              child: Icon(Icons.person, size: 80, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              'Profil Pengguna',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade900,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Halaman profil akan dikembangkan lebih lanjut',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  // Screen utama untuk permainan slot
  Widget _buildSlotScreen() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Center(
              child: _buildSlotMachine(),
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

  void _handleNavTap(int index) {
    setState(() {
      _currentNavIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SLOT MACHINE SIMULATOR'),
        backgroundColor: Colors.red.shade900,
        actions: [
          // Tombol Cara Bermain di app bar
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelp,
            tooltip: 'Cara Bermain',
          ),
          // Tampilkan koin hanya di halaman utama
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
        onPageChanged: (index) {
          setState(() {
            _currentNavIndex = index;
          });
        },
        children: [
          _buildSettingScreen(),    // Index 0
          _buildSlotScreen(),       // Index 1 (Home)
          _buildProfileScreen(),    // Index 2
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.red.shade900,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey.shade300,
        currentIndex: _currentNavIndex,
        onTap: _handleNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Setting',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 32), // Lebih besar untuk menonjolkan
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Dispose semua scroll controller
    for (var row in _scrollControllers) {
      for (var controller in row) {
        controller.dispose();
      }
    }
    _pageController.dispose();
    super.dispose();
  }
}