import 'package:flutter/material.dart';
import 'package:movietix_distributor/business_logis/provider/bottom_provider.dart';
import 'package:movietix_distributor/presentation/constants/colors.dart';
import 'package:provider/provider.dart';
class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BottomProvider(),
      child: _BottomNavContent(),
    );
  }
}
class _BottomNavContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BottomProvider>(context);

    return Scaffold(
      backgroundColor: MyColor().darkblue,
    
      body: provider.pages[provider.selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: MyColor().darkblue,
          unselectedItemColor: MyColor().gray,

        onTap: provider.setSelectedIndex,
        currentIndex: provider.selectedIndex, 
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            label: "",
            icon: Icon(Icons.home),
          ),
            BottomNavigationBarItem(
            label: "",
            icon: Icon(Icons.tv),
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