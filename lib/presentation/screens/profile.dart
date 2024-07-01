import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movietix_distributor/business_logis/auth/bloc/auth_bloc.dart';
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
            onPressed: () {
              // Dispatch logout event
              BlocProvider.of<AuthBloc>(context).add(LogoutEvent());
              // Navigate to login screen
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