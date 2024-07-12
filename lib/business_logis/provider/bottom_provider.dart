import 'package:flutter/material.dart';
import 'package:movietix_distributor/presentation/screens/moviespage.dart';
import 'package:movietix_distributor/presentation/screens/profile.dart';
import 'package:movietix_distributor/presentation/screens/upcomingmovie.dart';

class BottomProvider extends ChangeNotifier {
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;  // Changed from SelectIntent to selectedIndex

  final List<Widget> pages = [const Moviespage(), Upcomingmovie(), ProfileScreen()];

  void setSelectedIndex(int index) {
    if (index >= 0 && index < pages.length) {
      _selectedIndex = index;
      notifyListeners();
    }
  }
}