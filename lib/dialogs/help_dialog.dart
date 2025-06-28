import 'package:flutter/material.dart';

class HelpDialog extends StatelessWidget {
  const HelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
            _buildHelpItem('2. Setiap putaran akan mengurangi 10 koin dari saldo Anda'),
            _buildHelpItem('3. Dapatkan kombinasi simbol yang sesuai untuk memenangkan hadiah'),
            _buildHelpItem('4. Gunakan menu profile untuk melihat statistik dan informasi lainnya'),
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
}