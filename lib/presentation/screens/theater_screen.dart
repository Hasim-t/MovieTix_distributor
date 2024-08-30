import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movietix_distributor/presentation/constants/colors.dart';
import 'package:movietix_distributor/presentation/screens/screen_deatials.dart';
import 'package:movietix_distributor/presentation/screens/selectingmovie.dart';

class TheaterScreen extends StatelessWidget {
  const TheaterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor().darkblue,
      appBar: AppBar(
        title: Text('All Theaters', style: TextStyle(color: Colors.white)),
        backgroundColor: MyColor().darkblue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('owners').snapshots(),
        builder: (context, ownersSnapshot) {
          if (ownersSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (ownersSnapshot.hasError) {
            return Center(child: Text('Error: ${ownersSnapshot.error}'));
          }

          if (!ownersSnapshot.hasData || ownersSnapshot.data!.docs.isEmpty) {
            return Center(child: Text('No owners found'));
          }

          return ListView.builder(
            itemCount: ownersSnapshot.data!.docs.length,
            itemBuilder: (context, ownerIndex) {
              var owner = ownersSnapshot.data!.docs[ownerIndex];
              return ExpansionTile(
                title: Text(
                  owner['name'] ?? 'Unknown Owner',
                  style:  TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('owners')
                        .doc(owner.id)
                        .collection('screens')
                        .snapshots(),
                    builder: (context, screensSnapshot) {
                      if (screensSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (screensSnapshot.hasError) {
                        return Center(
                            child: Text('Error: ${screensSnapshot.error}'));
                      }

                      if (!screensSnapshot.hasData ||
                          screensSnapshot.data!.docs.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('No Seats found for this Theater',
                              style: TextStyle(color: Colors.white70)),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: screensSnapshot.data!.docs.length,
                        itemBuilder: (context, screenIndex) {
                          var screen = screensSnapshot.data!.docs[screenIndex];
                          return Card(
                            margin: EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            color: MyColor().gray,
                            child: ListTile(
                              title: Text(
                                screen.id,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              subtitle: Text(
                                'Rows: ${screen['rows']} | Columns: ${screen['cols']}',
                                style: TextStyle(color: Colors.white70),
                              ),
                              trailing: IconButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                      return Selectingmovie(
                                        screenId: screen.id,
                                        ownerId: owner.id,
                                      );
                                    }));
                                  },
                                  icon: Icon(Icons.add)),
                              onTap: () {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
    return ScreenDeatials(
      screenName: screen.id,
      rows: screen['rows'],
      cols: screen['cols'],
      ownerId: owner.id,
      screenId: screen.id,
    );
  }));
},
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
