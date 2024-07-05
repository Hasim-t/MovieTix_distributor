// lib/presentation/screens/profile.dart
import 'package:flutter/material.dart';
import 'package:movietix_distributor/business_logis/provider/authprovider.dart';
import 'package:provider/provider.dart';
import 'package:movietix_distributor/presentation/screens/loginscreen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        actions: [
          IconButton(
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
            icon: Icon(Icons.logout)
          )
        ],
      ),
    );
  }
}