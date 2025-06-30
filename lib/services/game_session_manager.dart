import 'package:simulasi_slot/services/firestore_service.dart';

class GameSessionManager {
  final FirestoreService _firestore = FirestoreService();
  String? _currentSessionId;
  String? _userId;
  int _initialCoins = 0;

  // Inisialisasi session
  Future<void> initSession(String userId, int initialCoins) async {
    _userId = userId;
    _initialCoins = initialCoins;
    
    // Cek session belum selesai
    final lastSession = await _firestore.getLastSession(userId);
    if (lastSession.docs.isNotEmpty) {
      final session = lastSession.docs.first;
      if (session['endTime'] == null) {
        _currentSessionId = session.id;
        return;
      }
    }
    
    // Buat session baru
    _currentSessionId = await _firestore.startGameSession(
      userId: userId,
      initialCoins: initialCoins,
    );
  }

  // Akhiri session saat keluar aplikasi
  Future<void> endSession(int finalCoins, int totalSpins) async {
    if (_currentSessionId == null || _userId == null) return;
    
    await _firestore.endGameSession(
      sessionId: _currentSessionId!,
      finalCoins: finalCoins,
      totalSpins: totalSpins,
    );
  }

  // Simpan riwayat permainan
  Future<void> saveGameResult({
    required bool isWin,
    required int amount,
    required String details,
  }) async {
    if (_currentSessionId == null || _userId == null) return;
    
    await _firestore.saveGameHistory(
      userId: _userId!,
      isWin: isWin,
      amount: amount,
      details: details,
      sessionId: _currentSessionId!,
    );
  }
}