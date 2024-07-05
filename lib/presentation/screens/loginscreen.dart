// lib/presentation/screens/loginscreen.dart
import 'package:flutter/material.dart';
import 'package:movietix_distributor/business_logis/provider/authprovider.dart';
import 'package:provider/provider.dart';
import 'package:movietix_distributor/presentation/constants/colors.dart';
import 'package:movietix_distributor/presentation/screens/profile.dart';
import 'package:movietix_distributor/presentation/widgets/textformfield.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor().darkblue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  Image.asset("asset/Logo_white.png", width: 499, height: 300),
                  CustomTextFormField(
                    controller: usernameController,
                    hintText: "Username",
                    prefixIcon: Icon(Icons.person),
                  ),
                  SizedBox(height: 40),
                  CustomTextFormField(
                    controller: passwordController,
                    hintText: "Password",
                    obscureText: true,
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await Provider.of<AuthProvider>(context, listen: false).login(
                          usernameController.text,
                          passwordController.text,
                        );
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => ProfileScreen()),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    },
                    child: Text('Login'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}