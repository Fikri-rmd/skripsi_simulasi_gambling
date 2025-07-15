import 'package:flutter/material.dart';

class ModernBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ModernBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0, left: 10 , right: 10),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        child: NavigationBar(
          backgroundColor: Colors.red.shade900,
          elevation: 8,
          height: 70,
          selectedIndex: currentIndex,
          onDestinationSelected: onTap,
          indicatorColor: Colors.black12.withOpacity(0.5),
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.settings_outlined, color: Colors.white),
              selectedIcon: Icon(Icons.settings, color: Colors.red),
              label: 'Settings',
            ),
            NavigationDestination(
              icon: Icon(Icons.casino_outlined, color: Colors.white),
              selectedIcon: Icon(Icons.casino, color: Colors.red),
              label: 'Game',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: Colors.white),
              selectedIcon: Icon(Icons.person, color: Colors.red),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
