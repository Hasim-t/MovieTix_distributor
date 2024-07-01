import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movietix_distributor/business_logis/auth/bloc/auth_bloc.dart';
import 'package:movietix_distributor/data/repositories/firebase_options.dart';
import 'package:movietix_distributor/presentation/screens/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp( MultiBlocProvider(
    providers: [BlocProvider<AuthBloc>(create: (context)=>AuthBloc())],
    child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
       home: Splash(),
    );
  }
}