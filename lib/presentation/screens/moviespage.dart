import 'package:flutter/material.dart';
import 'package:movietix_distributor/presentation/constants/colors.dart';
import 'package:movietix_distributor/presentation/screens/addingscreen.dart';

class Moviespage extends StatelessWidget {
  const Moviespage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: MyColor().darkblue,
          title: Text(
            "Add Movies ",
            style: TextStyle(color: MyColor().white),
          ),
        ),
        backgroundColor: MyColor().darkblue,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return const MoviesAddingScreen();
            }));
          },
          backgroundColor: MyColor().white,
          child: Icon(Icons.add),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
            const   SizedBox(height:  20,),
             Container(
              height:  150,
              width: 400,
              decoration: BoxDecoration(
                color:  MyColor().gray,
                borderRadius: BorderRadius.circular(25)
              ),child:  Row(
    children: [
      Image.asset("asset/phot_icons.png")
    ],
              ),
             )
            ],
          ),
        ),
      ),
    );
  }
}
