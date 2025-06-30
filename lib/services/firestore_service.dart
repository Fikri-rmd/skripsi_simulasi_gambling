import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simulasi_slot/utils/game_logic.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Simpan data user saat registrasi/login
  Future<void> saveUserData({
    required String userId,
    required String name,
    required String email,
  }) async {
    await _firestore.collection('users').doc(userId).set({
      'nama': name,
      'email': email,
      'tanggalJoin': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
      'saldoKoin': 500,
    }, SetOptions(merge: true));
  }

  // Mulai game session baru
  Future<String> startGameSession({
    required String userId,
    required int initialCoins,
  }) async {
    final settings = await GameSettings.loadFromPrefs();
    
    final session = await _firestore.collection('game_sessions').add({
      'userId': userId,
      'saldoAwal': initialCoins,
      'startTime': FieldValue.serverTimestamp(),
      'winPercentage': (settings.winPercentage * 100).round(),
      'settings': {
        'symbolRates': settings.symbolRates,
        'minSpinToWin': settings.minSpinToWin,
      }
    });
    
    return session.id;
  }

  // Akhiri game session
  Future<void> endGameSession({
    required String sessionId,
    required int finalCoins,
    required int totalSpins,
  }) async {
    await _firestore.collection('game_sessions').doc(sessionId).update({
      'saldoAkhir': finalCoins,
      'totalSpin': totalSpins,
      'endTime': FieldValue.serverTimestamp(),
    });
  }

  // Simpan riwayat permainan
  Future<void> saveGameHistory({
    required String userId,
    required bool isWin,
    required int amount,
    required String details,
    required String sessionId,
  }) async {
    // Simpan ke riwayat pengguna
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('game_history')
        .add({
      'result': isWin ? 'Menang' : 'Kalah',
      'amount': amount,
      'date': FieldValue.serverTimestamp(),
      'details': details,
      'sessionId': sessionId,
    });
    
    // Update saldo pengguna
    await _firestore.collection('users').doc(userId).update({
      'saldoKoin': FieldValue.increment(amount),
      'lastLogin': FieldValue.serverTimestamp(),
    });
  }

  // Dapatkan riwayat permainan
  Stream<QuerySnapshot> getGameHistory(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('game_history')
        .orderBy('date', descending: true)
        .limit(10)
        .snapshots();
  }

  // Dapatkan data pengguna
  Future<DocumentSnapshot> getUserData(String userId) {
    return _firestore.collection('users').doc(userId).get();
  }

  // Dapatkan session terakhir
  Future<QuerySnapshot> getLastSession(String userId) {
    return _firestore
        .collection('game_sessions')
        .where('userId', isEqualTo: userId)
        .orderBy('startTime', descending: true)
        .limit(1)
        .get();
  }

  // Update profil pengguna
  Future<void> updateProfile({
    required String userId,
    required String name,
  }) async {
    await _firestore.collection('users').doc(userId).update({
      'nama': name,
    });
    
    // Update juga di Firebase Auth
    await _auth.currentUser?.updateDisplayName(name);
  }
}