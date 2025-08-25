import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

class ModernBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final GlobalKey keySettings;
  final GlobalKey keyEdukasi;
  final GlobalKey keyBandar;
  final GlobalKey keyBantuan;
  const ModernBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.keySettings,
    required this.keyEdukasi,
    required this.keyBandar,
    required this.keyBantuan,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0, left: 0, right: 0),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            navigationBarTheme: NavigationBarThemeData(
              labelTextStyle: MaterialStateProperty.all(
                const TextStyle(
                  color: Colors.white, 
                  fontSize: 12, 
                ),
              ),
            ),
          ),
        child: NavigationBar(
          backgroundColor: Colors.blueGrey.shade800,
          elevation: 8,
          height: 70,
          selectedIndex: currentIndex,
          onDestinationSelected: onTap,
          indicatorColor: Colors.white.withOpacity(0.2),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
        // Index 0: Settings
        Showcase(
          key: keySettings,
          description: 'Sebelum simulasi, kunjungi halaman ini untuk mengatur probabilitas dan melihat bagaimana bandar bisa mengontrol peluang menang.',
            child: const NavigationDestination(
            icon: Icon(Icons.settings_outlined, color: Colors.white),
            selectedIcon: Icon(Icons.settings, color: Colors.white),

            label: 'Settings',
          ),
        ),
        // Index 1: Simulator
        const NavigationDestination(
          icon: Icon(Icons.casino_outlined, color: Colors.white70),
          selectedIcon: Icon(Icons.casino, color: Colors.white),
          label: 'Simulator',
        ),
        // Index 2: Edukasi
        Showcase(
          key: keyEdukasi,
          title: 'Mulai Dari Sini!',
          description: 'Ini adalah langkah pertama yang paling penting. Kunjungi halaman ini untuk memahami misi aplikasi dan bahaya judi online.',
          child: const NavigationDestination(
            icon: Icon(Icons.school_outlined, color: Colors.white70),
            selectedIcon: Icon(Icons.school, color: Colors.white),
            label: 'Edukasi',
          ),
        ),
        // Index 3: Bandar
        Showcase(
          key: keyBandar,
          description: 'Fitur utama kami! Di sini Anda berperan sebagai bandar dan melihat bukti nyata bahwa dalam jangka panjang, hanya bandar yang menang.',
          child: const NavigationDestination(
            icon: Icon(Icons.show_chart_outlined, color: Colors.white70),
            selectedIcon: Icon(Icons.show_chart, color: Colors.white),
            label: 'Bandar',
          ),
        ),
        // Index 4: Profil
        const NavigationDestination(
          icon: Icon(Icons.person_outline, color: Colors.white70),
          selectedIcon: Icon(Icons.person, color: Colors.white),
          label: 'Profil',
        ),
        // Index 5: Bantuan
        Showcase(
          key: keyBantuan,
          description: 'Jika Anda atau kerabat butuh pertolongan terkait kecanduan judi, halaman ini menyediakan kontak profesional yang bisa dihubungi.',
          child: const NavigationDestination(
            icon: Icon(Icons.help_outline, color: Colors.white70),
            selectedIcon: Icon(Icons.help, color: Colors.white),
            label: 'Bantuan',
          ),
          ),
          ],
        ),
      ),
    ),
    );
  }
}