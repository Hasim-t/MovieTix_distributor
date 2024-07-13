import 'package:flutter/material.dart';
import 'package:movietix_distributor/presentation/constants/colors.dart';
import 'package:movietix_distributor/presentation/screens/addingscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:movietix_distributor/presentation/screens/editingscreen.dart';

class Moviespage extends StatefulWidget {
  const Moviespage({super.key});

  @override
  _MoviespageState createState() => _MoviespageState();
}

class _MoviespageState extends State<Moviespage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: MyColor().darkblue,
          title: Text(
            "Movies",
            style:
                TextStyle(color: MyColor().white, fontWeight: FontWeight.bold),
          ),
          elevation: 0,
        ),
        backgroundColor: MyColor().darkblue,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return const MoviesAddingScreen();
            }));
          },
          backgroundColor: MyColor().white,
          child: Icon(Icons.add, color: MyColor().darkblue),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('movies').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                  child: Text('Error: ${snapshot.error}',
                      style: TextStyle(color: MyColor().white)));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(color: MyColor().white));
            }

            return ListView(
              padding: EdgeInsets.all(16),
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: MyColor().gray.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            bottomLeft: Radius.circular(15),
                          ),
                          child: Image.network(
                            data['imageUrl'] ?? "asset/phot_icons.png",
                            height: 180,
                            width: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Movie name:" + data['name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: MyColor().white,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text("Language: " + data['language'],
                                  style: TextStyle(
                                      color: MyColor().white.withOpacity(0.7))),
                              Text("category: " + data['category'],
                                  style: TextStyle(
                                      color: MyColor().white.withOpacity(0.7))),
                              Text("certification: " + data['certification'],
                                  style: TextStyle(
                                      color: MyColor().white.withOpacity(0.7))),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              _deleteMovie(document.id, data['imageUrl']),
                        ),
                      IconButton(
  onPressed: () {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Editingscreen(
        documentId: document.id,
        movieData: data,
      ),
    ));
  },
  icon: const Icon(Icons.edit),
)

                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  Future<void> _deleteMovie(String documentId, String? imageUrl) async {
    try {
      await FirebaseFirestore.instance
          .collection('movies')
          .doc(documentId)
          .delete();
      if (imageUrl != null) {
        await FirebaseStorage.instance.refFromURL(imageUrl).delete();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Movie deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting movie: $e')),
      );
    }
  }
}
