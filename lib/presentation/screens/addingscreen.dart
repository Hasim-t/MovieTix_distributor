import 'package:flutter/material.dart';
import 'package:movietix_distributor/presentation/constants/colors.dart';
import 'package:movietix_distributor/presentation/widgets/textformfield.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class MoviesAddingScreen extends StatefulWidget {
  const MoviesAddingScreen({super.key});

  @override
  _MoviesAddingScreenState createState() => _MoviesAddingScreenState();
}

class _MoviesAddingScreenState extends State<MoviesAddingScreen> {
  final TextEditingController movienamecontroller = TextEditingController();
  final TextEditingController languagecontroller = TextEditingController();
  final TextEditingController categorycontroller = TextEditingController();
  final TextEditingController certificationcontroller = TextEditingController();
  final TextEditingController descriptioncontroller = TextEditingController();

  File? _image;


  List<Map<String, String>> castList = [];

void deleteCast(int index) {
  setState(() {
    castList.removeAt(index);
  });
}

 Future<void> showAddCastDialog() async {
  String actorName = '';
  String castName = '';
  File? castImage;
  bool imageSelected = false;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Add Cast'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(hintText: 'Actor Name'),
                    onChanged: (value) => actorName = value,
                  ),
                  TextField(
                    decoration: InputDecoration(hintText: 'Cast Name'),
                    onChanged: (value) => castName = value,
                  ),
                  ElevatedButton(
                    child: Text(imageSelected ? 'Image Selected' : 'Select Image'),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        castImage = File(pickedFile.path);
                        setState(() {
                          imageSelected = true;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text('Save'),
                onPressed: () {
                  if (actorName.isNotEmpty && castName.isNotEmpty && castImage != null) {
                    this.setState(() {
                      castList.add({
                        'actorName': actorName,
                        'castName': castName,
                        'imagePath': castImage!.path,
                      });
                    });
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        }
      );
    },
  );
}

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

   Future<void> uploadMovieData() async {
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
      'actorName': cast['actorName']!,
      'castName': cast['castName']!,
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
  setState(() {
    _image = null;
    castList.clear(); // Clear the cast list
  });
}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: MyColor().darkblue,
          title: const Text('Add Movies'),
          foregroundColor: MyColor().white,
        ),
        backgroundColor: MyColor().darkblue,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: GestureDetector(
                    onTap: pickImage,
                    child: _image != null
                        ? Image.file(_image!, height: 150, width: 150, fit: BoxFit.cover)
                        : Image.asset('asset/phot_icons.png', height: 200, width: 200),
                  ),
                ),
                const SizedBox(height: 20),
                CustomTextFormField(controller: movienamecontroller, hintText: 'Movie Name'),
                const SizedBox(height: 20),
                CustomTextFormField(controller: languagecontroller, hintText: 'Language'),
                const SizedBox(height: 20),
                CustomTextFormField(controller: categorycontroller, hintText: 'Category'),
                const SizedBox(height: 20),
                CustomTextFormField(controller: certificationcontroller, hintText: 'Certification'),
                const SizedBox(height: 20),
                CustomTextFormField(controller: descriptioncontroller, hintText: 'Description', maxlines: 6),
                 Text('Cast', style: TextStyle(color: MyColor().white, fontSize: 18)),
              SizedBox(height: 10),
             Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ...castList.asMap().entries.map((entry) {
                    final index = entry.key;
                    final cast = entry.value;
                    return Stack(
                      children: [
                        Column(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundImage: FileImage(File(cast['imagePath']!)),
                            ),
                            Text(cast['actorName']!, style: TextStyle(color: MyColor().white)),
                          ],
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () => deleteCast(index),
                            child: Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.close, size: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  GestureDetector(
                    onTap: showAddCastDialog,
                    child: Column(
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(33),
                            color: MyColor().white
                          ),
                          child: const Icon(Icons.add),
                        ),
                        Text('Add Cast', style: TextStyle(color: MyColor().white)),
                      ],
                    ),
                  ),
                ],
              ),

                ElevatedButton(
                  onPressed: uploadMovieData,
                  child: const Text('Add Movie'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    
  }
}