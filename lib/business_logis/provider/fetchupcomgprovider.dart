import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpcomingMoviesProvider extends ChangeNotifier {
  List<DocumentSnapshot> _movies = [];
  List<DocumentSnapshot> get movies => _movies;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchUpcomingMovies() async {
    _isLoading = true;
    notifyListeners();

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('upcoming').get();
      _movies = querySnapshot.docs;
    } catch (e) {
      print('Error fetching upcoming movies: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteMovie(String movieId) async {
    try {
      await FirebaseFirestore.instance.collection('upcoming').doc(movieId).delete();
      await fetchUpcomingMovies(); // Refresh the list after deletion
    } catch (e) {
      print('Error deleting movie: $e');
    }
  }
}