import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:movietix_distributor/business_logis/provider/adding_provider.dart';
import 'package:movietix_distributor/business_logis/provider/authprovider.dart';
import 'package:movietix_distributor/business_logis/provider/bottom_provider.dart';
import 'package:movietix_distributor/business_logis/provider/fetchupcomgprovider.dart';

import 'package:movietix_distributor/business_logis/provider/movielist_provider.dart';
import 'package:movietix_distributor/business_logis/provider/upcoming.dart';
import 'package:movietix_distributor/data/repositories/firebase_options.dart';
import 'package:movietix_distributor/presentation/screens/splash.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context)=>AuthProvider()),
        ChangeNotifierProvider(create: (context)=>BottomProvider()),
        ChangeNotifierProvider(create: (context)=>MovieProvider()),
        ChangeNotifierProvider(create: (context)=>MovieListProvider()),
        ChangeNotifierProvider(create: (context)=>UpcomingProvider()),
        ChangeNotifierProvider(create: (context)=>UpcomingMoviesProvider()),

      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
         home: Splash(),
      ),
    );
  }
}