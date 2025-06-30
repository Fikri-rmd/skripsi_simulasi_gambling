import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simulasi_slot/services/firestore_service.dart';

class UserRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestore = FirestoreService();

  // Dapatkan user saat ini
  User? get currentUser => _auth.currentUser;

  // Stream status autentikasi
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Dapatkan data pengguna
  Future<Map<String, dynamic>> getUserData() async {
    if (currentUser == null) return {};
    
    final snapshot = await _firestore.getUserData(currentUser!.uid);
    return snapshot.data() as Map<String, dynamic>? ?? {};
  }

  // Update saldo koin
  Future<void> updateCoins(int amount) async {
    if (currentUser == null) return;
    
    await _firestore.updateCoins(
      userId: currentUser!.uid,
      amount: amount,
    );
  }

  // Dapatkan riwayat permainan
  Stream<QuerySnapshot> get gameHistory {
    if (currentUser == null) return const Stream.empty();
    return _firestore.getGameHistory(currentUser!.uid);
  }
}