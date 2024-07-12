// lib/presentation/screens/profile.dart
import 'package:flutter/material.dart';
import 'package:movietix_distributor/business_logis/provider/authprovider.dart';

import 'package:movietix_distributor/presentation/constants/colors.dart';
import 'package:movietix_distributor/presentation/screens/loginscreen.dart';
import 'package:movietix_distributor/presentation/widgets/textrowwidget.dart';
import 'package:provider/provider.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  MyColor().darkblue,

      appBar: AppBar(
         backgroundColor:  MyColor().darkblue,
         centerTitle: true,
        title: Text("Profile",style: TextStyle(
          color:  MyColor().white,
          fontSize: 28
        ),),
        actions:  [
        
        ],
      ),
      body:  Padding(
        padding: const EdgeInsets.symmetric(horizontal:  35),
        child: Column(
          children: [
             SizedBox(
              height:  20,
             ),
            Center(
              child: CircleAvatar(
              radius:  100,
                child: Image(image: AssetImage('asset/avatarpng.png', ),height:  200, width:  200),
              ),
            ),SizedBox(
              height: 20,
            ),
            Text('Admin ',style: TextStyle(
              color:  MyColor().white,
              fontSize: 24
            ),),
   const  Divider(),
const SizedBox(height:  20,),
         const    CoustomRowIcontext(icon: Icons.tv, text: 'All Theaters'),

          const   CoustomRowIcontext(icon: Icons.dark_mode, text: 'Dark Mode'),

                     const   CoustomRowIcontext(icon: Icons.privacy_tip, text: 'Terms and contitionas'),

                     CoustomRowIcontext(icon: Icons.logout, text: 'Logout', color:  MyColor().red, ontap:   () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },),
        
            
        
          ],
        ),
      ),
    );
  }
}