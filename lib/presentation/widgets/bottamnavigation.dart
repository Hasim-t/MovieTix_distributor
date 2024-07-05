 import 'package:flutter/material.dart';
import 'package:movietix_distributor/presentation/constants/colors.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor:  MyColor().darkblue,
    );
  }
}