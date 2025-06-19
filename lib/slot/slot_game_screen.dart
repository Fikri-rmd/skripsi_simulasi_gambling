import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class SlotGameScreen extends StatefulWidget {
  const SlotGameScreen({super.key});

  @override
  State<SlotGameScreen> createState() => _SlotGameScreenState();
}

class _SlotGameScreenState extends State<SlotGameScreen> {
  int _coins = 500;
  List<List<String>> _rows = List.generate(4, (_) => List.filled(4, '🎰'));
  int _spinCount = 0;
  bool _isSpinning = false;
  
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
          // backgroundColor: Colors.white,
      ),
        );
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
  
  // New methods for menu options
  void _showStatistics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📊 Statistik Permainan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Spin:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('$_spinCount 🔁', style: TextStyle(color: Colors.red.shade900)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Koin Dimainkan:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('${_spinCount * 50} 🪙', style: TextStyle(color: Colors.red.shade900)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Rasio Kemenangan:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('${_calculateWinRate().toStringAsFixed(1)}%', style: TextStyle(color: Colors.red.shade900)),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'ℹ️ Rasio kemenangan dihitung berdasarkan koin yang dimenangkan dibandingkan dengan total koin yang dimainkan',
                style: TextStyle(fontSize: 12, color: Colors.red),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('TUTUP', style: TextStyle(color: Colors.red.shade900)),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  double _calculateWinRate() {
    final totalCoinsPlayed = _spinCount * 50;
    if (totalCoinsPlayed == 0) return 0.0;
    final coinsWon = _coins - 500 + totalCoinsPlayed;
    return (coinsWon / totalCoinsPlayed * 100).clamp(0, 100);
  }

  void _showSpinHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📜 Riwayat Spin Terakhir'),
        content: const Text(
          'Fitur ini akan menampilkan hasil spin sebelumnya dalam versi mendatang. '
          'Kami berencana untuk menyimpan hingga 20 spin terakhir untuk analisis pola.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('TUTUP', style: TextStyle(color: Colors.red.shade900)),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
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

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚙️ Pengaturan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pengaturan akan tersedia pada versi berikutnya. '
              'Fitur yang sedang dalam pengembangan:',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            _buildSettingItem('Volume Efek Suara'),
            _buildSettingItem('Animasi Mesin Slot'),
            _buildSettingItem('Tema Warna'),
            _buildSettingItem('Kecepatan Putaran'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('TUTUP', style: TextStyle(color: Colors.red.shade900)),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildSettingItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(Icons.construction, color: Colors.orange.shade700, size: 20),
          const SizedBox(width: 10),
          Text(text),
        ],
      ),
    );
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ℹ️ Tentang Aplikasi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.casino, size: 60, color: Colors.red),
            const SizedBox(height: 15),
            const Text(
              'Slot Machine Simulator',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text('Versi 1.0.0'),
            const SizedBox(height: 15),
            const Text(
              'Aplikasi ini dibuat untuk tujuan edukasi tentang mekanisme permainan slot online dan algoritma yang digunakan',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '🚫 PERINGATAN: \nJudi dilarang untuk anak di bawah umur dan dapat menyebabkan ketagihan',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red),
              ),
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('TUTUP', style: TextStyle(color: Colors.red.shade900)),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SLOT MACHINE SIMULATOR'),
        backgroundColor: Colors.red.shade900,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
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
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.7,
        backgroundColor: Colors.red.shade50,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.red.shade900,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SLOT MACHINE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Saldo: $_coins 🪙',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'Spin: $_spinCount 🔁',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.red),
              title: const Text('Beranda'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.leaderboard, color: Colors.red),
              title: const Text('Statistik'),
              onTap: () {
                Navigator.pop(context);
                _showStatistics();
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.red),
              title: const Text('Riwayat Spin'),
              onTap: () {
                Navigator.pop(context);
                _showSpinHistory();
              },
            ),
            ListTile(
              leading: const Icon(Icons.help, color: Colors.red),
              title: const Text('Cara Bermain'),
              onTap: () {
                Navigator.pop(context);
                _showHelp();
              },
            ),
            const Divider(thickness: 1, color: Colors.red),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.red),
              title: const Text('Pengaturan'),
              onTap: () {
                Navigator.pop(context);
                _showSettings();
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.red),
              title: const Text('Tentang'),
              onTap: () {
                Navigator.pop(context);
                _showAbout();
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: _buildSlotMachine(), // Gunakan widget baru ini
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
    super.dispose();
  }
}