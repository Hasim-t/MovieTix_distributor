import 'package:flutter/material.dart';
import 'package:movietix_distributor/presentation/screens/moviespage.dart';
import 'package:movietix_distributor/presentation/screens/profile.dart';
import 'package:movietix_distributor/presentation/screens/theater_screen.dart';
import 'package:movietix_distributor/presentation/screens/upcomingmovie.dart';

class BottomProvider extends ChangeNotifier {
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;  // Changed from SelectIntent to selectedIndex

  final List<Widget> pages = [ Moviespage(),TheaterScreen(), Upcomingmovie(), ProfileScreen()];

  void setSelectedIndex(int index) {
    if (index >= 0) {
      _selectedIndex = index;
      notifyListeners();
    }
  }
}