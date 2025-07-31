import 'package:flutter/material.dart';

class ResetSuccessDialog extends StatelessWidget {
  const ResetSuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsPadding: const EdgeInsets.all(15.0),
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
      '🪙 Saldo: 500 Koin\n',
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
      actionsAlignment: MainAxisAlignment.end, // default is end (bottom)
      shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}