import 'package:flutter/material.dart';
import 'package:movietix_distributor/presentation/constants/colors.dart';
import 'package:movietix_distributor/presentation/screens/moviespage.dart';
import 'package:movietix_distributor/presentation/screens/profile.dart';

import 'package:movietix_distributor/presentation/screens/upcomingmovie.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}
class _HomescreenState extends State<Homescreen> {
  int _selectIndex = 0;
  final List _pages = [Moviespage(), Upcomingmovie(), ProfileScreen()];

  void _onItemsTapped(int index) {
    if (index >= 0 && index < _pages.length) {
      setState(() {
        _selectIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor().darkblue,
      body: _pages[_selectIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onItemsTapped,
        currentIndex: _selectIndex,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            label: "",
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            label: "",
            icon: Icon(Icons.movie),
          ),
          BottomNavigationBarItem(
            label: "",
            icon: Icon(Icons.person),
          ),
        ],
      ),
    );
  }
}