import 'package:shared_preferences/shared_preferences.dart';

Future<void> resetAllGameData() async {
  // Hapus semua shared preferences, local score, dll.
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('game_settings');
  await prefs.remove('coins');
  await prefs.remove('spin_count');
  await prefs.remove('win_count');
  await prefs.remove('lose_count');


  print('[RESET] Semua data lokal berhasil dihapus saat logout.');
}
