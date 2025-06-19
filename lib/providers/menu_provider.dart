import 'package:flutter/material.dart';

enum NavigationItem {
  home,
  profile,
  setting,
  logout
}

class MenuProvider with ChangeNotifier {
  NavigationItem _currentItem = NavigationItem.home;
  bool _isMenuOpen = false;

  NavigationItem get currentItem => _currentItem;
  bool get isMenuOpen => _isMenuOpen;

  void setNavigationItem(NavigationItem item) {
    _currentItem = item;
    _isMenuOpen = false;
    notifyListeners();
  }

  void toggle() {
    _isMenuOpen = !_isMenuOpen;
    notifyListeners();
  }

  void closeMenu() {
    _isMenuOpen = false;
    notifyListeners();
  }
}