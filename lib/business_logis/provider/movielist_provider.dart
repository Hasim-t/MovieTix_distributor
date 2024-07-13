import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class MovieListProvider extends ChangeNotifier {
  Stream<QuerySnapshot> get moviesStream => 
      FirebaseFirestore.instance.collection('movies').snapshots();

  Future<void> deleteMovie(String documentId, String? imageUrl, BuildContext context) async {
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
    notifyListeners();
  }
}