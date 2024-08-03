import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class MovieEditProvider extends ChangeNotifier {
  late TextEditingController movienamecontroller;
  late TextEditingController certificationcontroller;
  late TextEditingController descriptioncontroller;

  String? selectedLanguage;
  String? selectedCategory;

  final List<String> languages = ['English', 'Spanish', 'French', 'German', 'Chinese', 'Japanese']; // Add more as needed
  final List<String> categories = ['Action', 'Comedy', 'Drama', 'Thriller', 'Sci-Fi', 'Horror']; // Add more as needed

  File? _image;
  String? _imageUrl;
  List<Map<String, dynamic>> castList = [];

  MovieEditProvider(Map<String, dynamic> movieData) {
    movienamecontroller = TextEditingController(text: movieData['name']);
    certificationcontroller = TextEditingController(text: movieData['certification']);
    descriptioncontroller = TextEditingController(text: movieData['description']);
    selectedLanguage = movieData['language'];
    selectedCategory = movieData['category'];
    _imageUrl = movieData['imageUrl'];
    castList = List<Map<String, dynamic>>.from(movieData['cast'] ?? []);
  }

  File? get image => _image;
  String? get imageUrl => _imageUrl;

  void setLanguage(String language) {
    selectedLanguage = language;
    notifyListeners();
  }

  void setCategory(String category) {
    selectedCategory = category;
    notifyListeners();
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      _imageUrl = null;
      notifyListeners();
    }
  }

  void addOrUpdateCast(Map<String, dynamic> cast, [int? index]) {
    if (index != null) {
      castList[index] = cast;
    } else {
      castList.add(cast);
    }
    notifyListeners();
  }

  void deleteCast(int index) {
    castList.removeAt(index);
    notifyListeners();
  }

  Future<void> updateMovieData(String documentId, BuildContext context) async {
    String? imageUrl = _imageUrl;

    if (_image != null) {
      final storageRef = FirebaseStorage.instance.ref().child('movie_images/${DateTime.now().toString()}');
      await storageRef.putFile(_image!);
      imageUrl = await storageRef.getDownloadURL();
    }

    List<Map<String, dynamic>> updatedCastList = [];
    for (var cast in castList) {
      if (cast['imageUrl'] != null) {
        updatedCastList.add(cast);
      } else if (cast['imagePath'] != null) {
        final castImageFile = File(cast['imagePath']!);
        final castStorageRef = FirebaseStorage.instance.ref().child('cast_images/${DateTime.now().toString()}_${cast['actorName']}');
        await castStorageRef.putFile(castImageFile);
        final castImageUrl = await castStorageRef.getDownloadURL();
        updatedCastList.add({
          'actorName': cast['actorName']!,
          'castName': cast['castName']!,
          'imageUrl': castImageUrl,
        });
      } else {
        updatedCastList.add({
          'actorName': cast['actorName']!,
          'castName': cast['castName']!,
        });
      }
    }

    final updatedMovieData = {
      'name': movienamecontroller.text,
      'language': selectedLanguage,
      'category': selectedCategory,
      'certification': certificationcontroller.text,
      'description': descriptioncontroller.text,
      'imageUrl': imageUrl,
      'cast': updatedCastList,
    };

    try {
      await FirebaseFirestore.instance.collection('movies').doc(documentId).update(updatedMovieData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Movie updated successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating movie: $e')),
      );
    }
  }
}