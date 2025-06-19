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
  final String _email = "pengguna@contoh.com"; // Final agar tidak bisa diubah
  int _age = 25;
  
  // Controller untuk form
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

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
        icon: Icon(Icons.check_circle, color: Colors.green, size: 40),
        title: Text(
          'Berhasil Disimpan!',
          style: TextStyle(
            fontFamily: 'Raleway',
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        content: Text(
          'Perubahan profil telah berhasil disimpan',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Raleway',
          ),
        ),
        actions: [
          TextButton(
            child: Text(
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
        icon: Icon(Icons.error, color: Colors.red, size: 40),
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
          style: TextStyle(
            fontFamily: 'Raleway',
          ),
        ),
        actions: [
          TextButton(
            child: Text(
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