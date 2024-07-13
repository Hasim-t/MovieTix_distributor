import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class MovieProvider extends ChangeNotifier {
  final TextEditingController movienamecontroller = TextEditingController();
  final TextEditingController languagecontroller = TextEditingController();
  final TextEditingController categorycontroller = TextEditingController();
  final TextEditingController certificationcontroller = TextEditingController();
  final TextEditingController descriptioncontroller = TextEditingController();

  File? _image;
  File? get image => _image;

  List<Map<String, String>> castList = [];

  void setImage(File? image) {
    _image = image;
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
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

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
      'language': languagecontroller.text,
      'category': categorycontroller.text,
      'certification': certificationcontroller.text,
      'description': descriptioncontroller.text,
      'imageUrl': imageUrl,
      'cast': castData,
    };

    // Add data to Firestore
    try {
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
    }
  }

  void clearForm() {
    movienamecontroller.clear();
    languagecontroller.clear();
    categorycontroller.clear();
    certificationcontroller.clear();
    descriptioncontroller.clear();
    _image = null;
    castList.clear();
    notifyListeners();
  }
}