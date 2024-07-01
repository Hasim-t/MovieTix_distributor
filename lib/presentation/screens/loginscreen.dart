import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movietix_distributor/business_logis/auth/bloc/auth_bloc.dart';
import 'package:movietix_distributor/presentation/constants/colors.dart';
import 'package:movietix_distributor/presentation/screens/profile.dart';
import 'package:movietix_distributor/presentation/widgets/textformfield.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => ProfileScreen()),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.massage??"error")),
          );
        }
      },
      builder: (context, state) {
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
               Image.asset("asset/Logo_white.png",width: 499,height: 300,),
                    // TextField(
                    //   controller: usernameController,
                    //   decoration: InputDecoration(labelText: 'Username'),
                    // ),
                    CustomTextFormField(controller: usernameController, hintText: "Username"
                    ,prefixIcon: Icon(Icons.person),
                    ),
                
                    SizedBox(height: 40),
                    // TextField(
                    //   controller: passwordController,
                    //   obscureText: true,
                    //   decoration: InputDecoration(labelText: 'Password'),
                    // ),
                    CustomTextFormField(controller: passwordController, hintText: "password")
                    ,SizedBox(height: 40),
                    ElevatedButton(
                      
                      onPressed: () {
                        context.read<AuthBloc>().add(
                          LogingEvent(
                            username: usernameController.text,
                            passoword: passwordController.text,
                          ),
                        );
                      },
                      child: Text('Login'),
                    ),
                    if (state is AuthLoading)
                      CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
              
            ],
          ),
        );
      },
    );
  }
}