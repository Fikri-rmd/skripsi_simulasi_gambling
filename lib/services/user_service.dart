import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> saveUserData({
    required String userId,
    required String nama,
    required String email,
  }) async {
    await _firestore.collection('users').doc(userId).set({
      'userId': userId,
      'nama': nama,
      'email': email,
      'tanggalJoin': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> updateLastLogin(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'lastLogin': FieldValue.serverTimestamp(),
    });
  }
}