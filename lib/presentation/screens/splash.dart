import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movietix_distributor/business_logis/auth/bloc/auth_bloc.dart';
import 'package:movietix_distributor/presentation/constants/colors.dart';
import 'package:movietix_distributor/presentation/screens/loginscreen.dart';
import 'package:movietix_distributor/presentation/screens/profile.dart';


class Splash extends StatelessWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc()..add(CheckAuthStatusEvent()),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => LoginScreen()),
            );
          } else if (state is AuthAuthenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => ProfileScreen()),
            );
          }
        },
        child: Scaffold(
          backgroundColor: MyColor().darkblue,
          body: Center(
            child: Image.asset("asset/Movietix_logo.png", height: 180, width: 180),
          ),
        ),
      ),
    );
  }
}