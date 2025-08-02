import 'package:flutter/material.dart';

class HelpDialog extends StatelessWidget {
  const HelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cara Bermain'),
      content: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TUJUAN:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Simulasi edukasi ini menunjukkan cara mesin slot bekerja melawan pemain.'),
            SizedBox(height: 16),
            Text(
              'CARA BERMAIN:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('• Setiap putaran menghabiskan 10 koin'),
            Text('• Anda mulai dengan 1000 koin'),
            Text('• Dapatkan 4 simbol yang sama dalam satu garis untuk menang'),
            Text('• Garis menang bisa horizontal, vertikal, atau diagonal'),
            SizedBox(height: 16),
            Text(
              'KOMBINASI MENANG:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('🍒 Ceri: 12 koin '),
            Text('🍋 Lemon: 16 koin '),
            Text('🍊 Jeruk: 20 koin '),
            Text('💎 Berlian: 40 koin '),
            Text('💰 Uang: 60 koin '),
            SizedBox(height: 16),
            Text(
              'PENGATURAN:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('• Atur persentase kemenangan (0-100%)'),
            Text('• Setel putaran minimum sebelum menang'),
            Text('• Konfigurasi tingkat kemunculan kemenangan simbol'),
            SizedBox(height: 16),
            Text(
              'TUJUAN EDUKASI:',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            Text(
              'Simulator ini menunjukkan bagaimana algoritma perjudian dirancang untuk menguntungkan admin judi. '
              'Dalam perjudian nyata, Anda tidak bisa mengontrol pengaturan ini dan admin judi selalu menang dalam jangka panjang.',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
            textStyle: const TextStyle(fontSize: 16),
          
          
        ),
          child: const Text('Mengerti!', ),)
      ],
    );
  }
}