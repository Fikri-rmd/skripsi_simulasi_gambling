import 'package:simulasi_slot/screens/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // bool _isLoadingHistory = true;
  bool _isEditing = false;

  // Data pengguna
  String _name = '';
  String _email = '';
  String? _photoURL;
  DateTime? _lastLogin;
  // List<Map<String, dynamic>> _gameHistory = [];

  // Controller untuk form
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // _loadGameHistory();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _name = user.displayName ?? '';
        _email = user.email ?? '';
        _photoURL = user.photoURL;
        _lastLogin = user.metadata.lastSignInTime;
        _nameController.text = _name;
      });
    }
  }

  // Future<void> _loadGameHistory() async {
  //   User? user = _auth.currentUser;
  //   if (user == null) return;

  //   try {
  //     QuerySnapshot snapshot = await _firestore
  //         .collection('users')
  //         .doc(user.uid)
  //         .collection('gameHistory')
  //         .orderBy('date', descending: true)
  //         .limit(10)
  //         .get();

  //     setState(() {
  //       _gameHistory = snapshot.docs.map((doc) {
  //         Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  //         return {
  //           'result': data['result'],
  //           'amount': data['amount'],
  //           'date': (data['date'] as Timestamp).toDate(),
  //           'details': data['details'],
  //         };
  //       }).toList();
  //       _isLoadingHistory = false;
  //     });
  //   } catch (e) {
  //     print("Error loading game history: $e");
  //     setState(() {
  //       _isLoadingHistory = false;
  //     });
  //   }
  // }

  Stream<QuerySnapshot> _getGameHistoryStream() {
    User? user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('gameHistory')
        .orderBy('date', descending: true)
        .limit(10)
        .snapshots();
  }

  void _logout() async {
    try {
      await _auth.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      _showErrorDialog('Logout gagal. Silakan coba lagi.');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 40),
          title: const Text('Berhasil Disimpan!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          content: const Text('Perubahan profil telah berhasil disimpan', textAlign: TextAlign.center),
          actions: [
            TextButton(
              child: const Text('OK', style: TextStyle(color: Colors.green)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(Icons.error, color: Colors.red, size: 40),
          title: const Text('Gagal', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          content: Text(message, textAlign: TextAlign.center),
          actions: [
            TextButton(
              child: const Text('OK', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _nameController.text = _name;
      }
    });
  }

  void _saveProfile() {
    if (_nameController.text.isEmpty) {
      _showErrorDialog('Nama tidak boleh kosong');
      return;
    }

    try {
      _auth.currentUser?.updateDisplayName(_nameController.text);
      setState(() {
        _name = _nameController.text;
        _isEditing = false;
      });
      _showSuccessDialog();
    } catch (e) {
      _showErrorDialog('Gagal menyimpan data');
    }
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> history) {
    final bool isWin = history['result'] == 'Menang';
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      color: isWin ? Colors.green.shade50 : Colors.red.shade50,
      child: ListTile(
        leading: Icon(
          isWin ? Icons.emoji_events : Icons.warning,
          color: isWin ? Colors.green : Colors.red,
        ),
        title: Text(
          history['result'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isWin ? Colors.green : Colors.red,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(history['details']),
            Text(dateFormat.format(history['date'])),
          ],
        ),
        trailing: Text(
          '${history['amount'] > 0 ? '+' : ''}${history['amount']}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isWin ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final joinDateText = _lastLogin != null
        ? DateFormat('dd MMMM yyyy HH:mm').format(_lastLogin!)
        : '-';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        actions: [
          IconButton(icon: Icon(_isEditing ? Icons.close : Icons.edit), onPressed: _toggleEdit),
          if (_isEditing) IconButton(icon: const Icon(Icons.save), onPressed: _saveProfile),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage:
                  _photoURL != null ? NetworkImage(_photoURL!) : null,
              child: _photoURL == null ? const Icon(Icons.person, size: 50) : null,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person),
              title: _isEditing
                  ? TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                          labelText: 'Nama', border: OutlineInputBorder()),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Nama', style: TextStyle(color: Colors.grey)),
                        Text(_name),
                      ],
                    ),
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Email', style: TextStyle(color: Colors.grey)),
                  Text(_email),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Tanggal Login Terakhir'),
              subtitle: Text(joinDateText),
            ),
            const Divider(thickness: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.history, size: 24),
                  const SizedBox(width: 10),
                  const Text(
                    'Riwayat Permainan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
             // Gunakan StreamBuilder untuk real-time update
            Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: _getGameHistoryStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Belum ada riwayat permainan'));
                  }
                  
                  final historyList = snapshot.data!.docs;
                  
                  return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: historyList.length,
                    itemBuilder: (context, index) {
                      final history = historyList[index].data() as Map<String, dynamic>;
                      return _buildHistoryItem({
                        'result': history['result'],
                        'amount': history['amount'],
                        'date': (history['date'] as Timestamp).toDate(),
                        'details': history['details'],
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                onPressed: _showLogoutConfirmation,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
