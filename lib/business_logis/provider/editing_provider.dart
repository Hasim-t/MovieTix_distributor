import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class MovieEditProvider extends ChangeNotifier {
  late TextEditingController movienamecontroller;
  late TextEditingController languagecontroller;
  late TextEditingController categorycontroller;
  late TextEditingController certificationcontroller;
  late TextEditingController descriptioncontroller;

  File? _image;
  String? _imageUrl;
  List<Map<String, dynamic>> castList = [];

  MovieEditProvider(Map<String, dynamic> movieData) {
    movienamecontroller = TextEditingController(text: movieData['name']);
    languagecontroller = TextEditingController(text: movieData['language']);
    categorycontroller = TextEditingController(text: movieData['category']);
    certificationcontroller = TextEditingController(text: movieData['certification']);
    descriptioncontroller = TextEditingController(text: movieData['description']);
    _imageUrl = movieData['imageUrl'];
    castList = List<Map<String, dynamic>>.from(movieData['cast'] ?? []);
  }

  File? get image => _image;
  String? get imageUrl => _imageUrl;

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
      // Upload new image if selected
      final storageRef = FirebaseStorage.instance.ref().child('movie_images/${DateTime.now().toString()}');
      await storageRef.putFile(_image!);
      imageUrl = await storageRef.getDownloadURL();
    }

    // Update cast images if needed
    List<Map<String, dynamic>> updatedCastList = [];
    for (var cast in castList) {
      if (cast['imageUrl'] != null) {
        // Image URL already exists, no need to upload
        updatedCastList.add(cast);
      } else if (cast['imagePath'] != null) {
        // New image, need to upload
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
        // No image, just add the cast info
        updatedCastList.add({
          'actorName': cast['actorName']!,
          'castName': cast['castName']!,
        });
      }
    }

    // Prepare updated movie data
    final updatedMovieData = {
      'name': movienamecontroller.text,
      'language': languagecontroller.text,
      'category': categorycontroller.text,
      'certification': certificationcontroller.text,
      'description': descriptioncontroller.text,
      'imageUrl': imageUrl,
      'cast': updatedCastList,
    };

    // Update data in Firestore
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