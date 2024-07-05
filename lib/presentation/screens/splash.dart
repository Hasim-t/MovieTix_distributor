

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movietix_distributor/business_logis/provider/authprovider.dart';
import 'package:movietix_distributor/presentation/constants/colors.dart';
import 'package:movietix_distributor/presentation/screens/loginscreen.dart';
import 'package:movietix_distributor/presentation/screens/profile.dart';

class Splash extends StatelessWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<AuthProvider>(context, listen: false).initializeApp(),
      builder: (context, snapshot) {
        return Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            if (authProvider.isLoading) {
              return Scaffold(
                backgroundColor: MyColor().darkblue,
                body: Center(
                  child: Image.asset("asset/Movietix_logo.png", height: 180, width: 180),
                ),
              );
            } else {
              if (authProvider.isAuthenticated) {
                return  ProfileScreen();
              } else {
                return LoginScreen();
              }
            }
          },
        );
      },
    );
  }
}