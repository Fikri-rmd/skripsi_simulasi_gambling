import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final DateTime _joinDate = DateTime.now();
  bool _isEditing = false;
  
  // Data pengguna
  String _name = "John Doe";
  final String _email = "pengguna@contoh.com";
  int _age = 25;
  
  // Controller untuk form
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  
  // Riwayat permainan
  final List<Map<String, dynamic>> _gameHistory = [
    {
      'result': 'Menang',
      'amount': 150,
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'details': '🍒 x6, 🍋 x5'
    },
    {
      'result': 'Kalah',
      'amount': -50,
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'details': 'Tidak ada kombinasi'
    },
    {
      'result': 'Menang',
      'amount': 230,
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'details': '💎 x4, 🍇 x5'
    },
    {
      'result': 'Kalah',
      'amount': -50,
      'date': DateTime.now().subtract(const Duration(days: 4)),
      'details': 'Spin minimum belum tercapai'
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 40),
          title: Text(
            'Berhasil Disimpan!',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          content: const Text(
            'Perubahan profil telah berhasil disimpan',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Raleway',
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  color: Colors.green,
                ),
              ),
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
          title: Text(
            'Gagal Menyimpan',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Raleway',
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  color: Colors.red,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _loadUserData() {
    _nameController.text = _name;
    _ageController.text = _age.toString();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _loadUserData();
      }
    });
  }

  void _saveProfile() {
    // Validasi input
    if (_nameController.text.isEmpty) {
      _showErrorDialog('Nama tidak boleh kosong');
      return;
    }

    final age = int.tryParse(_ageController.text);
    if (age == null || age < 0) {
      _showErrorDialog('Umur harus berupa angka yang valid');
      return;
    }

    setState(() {
      _name = _nameController.text;
      _age = age;
      _isEditing = false;
    });
    
    _showSuccessDialog();
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
                Navigator.pop(context); // Kembali ke halaman sebelumnya
                // Di sini Anda bisa tambahkan logika logout sebenarnya
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: _toggleEdit,
          ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveProfile,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 20),
            _buildEditableField(
              label: 'Nama',
              icon: Icons.person,
              controller: _nameController,
              isEditing: _isEditing,
            ),
            _buildEmailField(),
            _buildEditableField(
              label: 'Umur',
              icon: Icons.cake,
              controller: _ageController,
              isEditing: _isEditing,
              keyboardType: TextInputType.number,
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Tanggal Join'),
              subtitle: Text(
                DateFormat('dd MMMM yyyy').format(_joinDate),
              ),
            ),
            
            // Tombol Logout
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _showLogoutConfirmation,
              ),
            ),
            
            // Riwayat Permainan
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
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      // Aksi untuk melihat semua riwayat
                    },
                    child: const Text('Lihat Semua'),
                  ),
                ],
              ),
            ),
            
            // Daftar riwayat
            Column(
              children: _gameHistory
                  .take(3) // Tampilkan hanya 3 item terbaru
                  .map((history) => _buildHistoryItem(history))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required bool isEditing,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: isEditing
          ? TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                labelText: label,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '$label tidak boleh kosong';
                }
                if (label == 'Umur' && int.tryParse(value) == null) {
                  return 'Masukkan angka yang valid';
                }
                return null;
              },
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey)),
                Text(controller.text),
              ],
            ),
    );
  }

  Widget _buildEmailField() {
    return ListTile(
      leading: const Icon(Icons.email),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Email', style: TextStyle(color: Colors.grey)),
          Text(_email),
        ],
      ),
    );
  }
}