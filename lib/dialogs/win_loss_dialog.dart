import 'package:flutter/material.dart';

class WinLossDialog extends StatelessWidget {
  final String message;
  final bool isWin;

  const WinLossDialog({
    super.key,
    required this.message,
    required this.isWin,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(isWin ? Icons.celebration : Icons.warning,
              color: isWin ? Colors.green : Colors.red),
          const SizedBox(width: 10),
          Text(isWin ? 'Menang!' : 'Kalah Lagi'),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK', 
            style: TextStyle(color: isWin ? Colors.green : Colors.red)),
        ),
      ],
    );
  }
}