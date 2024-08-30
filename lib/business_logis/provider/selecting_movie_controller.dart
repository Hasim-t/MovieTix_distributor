import 'package:flutter/material.dart';

class MovieSelectionProvider extends ChangeNotifier {
  String? _selectedMovieId;

  String? get selectedMovieId => _selectedMovieId;

  void selectMovie(String movieId) {
    _selectedMovieId = movieId;
    notifyListeners();
  }
} 