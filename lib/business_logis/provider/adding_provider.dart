import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class MovieProvider extends ChangeNotifier {
  final TextEditingController movienamecontroller = TextEditingController();
  final TextEditingController certificationcontroller = TextEditingController();
  final TextEditingController descriptioncontroller = TextEditingController();

  // Language dropdown
  List<String> languages = ['English', 'Spanish', 'French', 'German', 'Chinese', 'Japanese'];
  String? selectedLanguage;

  // Category dropdown
  List<String> categories = ['Action', 'Comedy', 'Drama', 'Thriller', 'Sci-Fi', 'Horror'];
  String? selectedCategory;

  File? _image;
  File? get image => _image;

  List<Map<String, String>> castList = [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setImage(File? image) {
    _image = image;
    notifyListeners();
  }

  void setLanguage(String language) {
    selectedLanguage = language;
    notifyListeners();
  }

  void setCategory(String category) {
    selectedCategory = category;
    notifyListeners();
  }

  void addCast(Map<String, String> cast) {
    castList.add(cast);
    notifyListeners();
  }

  void deleteCast(int index) {
    castList.removeAt(index);
    notifyListeners();
  }

  Future<void> uploadMovieData(BuildContext context) async {
    if (_image == null || selectedLanguage == null || selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select an image')),
      );
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Upload movie image to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child('movie_images/${DateTime.now().toString()}');
      await storageRef.putFile(_image!);
      final imageUrl = await storageRef.getDownloadURL();

      // Upload cast images and get their download URLs
      List<Map<String, String>> castData = [];
      for (var cast in castList) {
        final castImageFile = File(cast['imagePath']!);
        final castStorageRef = FirebaseStorage.instance.ref().child('cast_images/${DateTime.now().toString()}_${cast['actorName']}');
        await castStorageRef.putFile(castImageFile);
        final castImageUrl = await castStorageRef.getDownloadURL();
        
        castData.add({
          'actorName': cast['actorName'] as String,
          'castName': cast['castName'] as String,
          'imageUrl': castImageUrl,
        });
      }

      // Prepare movie data
      final movieData = {
        'name': movienamecontroller.text,
        'language': selectedLanguage,
        'category': selectedCategory,
        'certification': certificationcontroller.text,
        'description': descriptioncontroller.text,
        'imageUrl': imageUrl,
        'cast': castData,
      };

      // Add data to Firestore
      await FirebaseFirestore.instance.collection('movies').add(movieData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Movie added successfully')),
      );
      // Clear the form
      clearForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding movie: $e')),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearForm() {
    movienamecontroller.clear();
    selectedLanguage = null;
    selectedCategory = null;
    certificationcontroller.clear();
    descriptioncontroller.clear();
    _image = null;
    castList.clear();
    notifyListeners();
  }
}