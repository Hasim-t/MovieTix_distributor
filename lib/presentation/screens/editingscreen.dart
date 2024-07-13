import 'package:flutter/material.dart';
import 'package:movietix_distributor/presentation/constants/colors.dart';
import 'package:movietix_distributor/presentation/widgets/textformfield.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class Editingscreen extends StatefulWidget {
  final String documentId;
  final Map<String, dynamic> movieData;

  const Editingscreen({Key? key, required this.documentId, required this.movieData}) : super(key: key);

  @override
  _EditingscreenState createState() => _EditingscreenState();
}

class _EditingscreenState extends State<Editingscreen> {
  late TextEditingController movienamecontroller;
  late TextEditingController languagecontroller;
  late TextEditingController categorycontroller;
  late TextEditingController certificationcontroller;
  late TextEditingController descriptioncontroller;

  File? _image;
  String? _imageUrl;
  List<Map<String, dynamic>> castList = [];

  @override
  void initState() {
    super.initState();
    movienamecontroller = TextEditingController(text: widget.movieData['name']);
    languagecontroller = TextEditingController(text: widget.movieData['language']);
    categorycontroller = TextEditingController(text: widget.movieData['category']);
    certificationcontroller = TextEditingController(text: widget.movieData['certification']);
    descriptioncontroller = TextEditingController(text: widget.movieData['description']);
    _imageUrl = widget.movieData['imageUrl'];
    castList = List<Map<String, dynamic>>.from(widget.movieData['cast'] ?? []);
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _imageUrl = null;
      });
    }
  }

  Future<void> showAddCastDialog([Map<String, dynamic>? existingCast]) async {
    String actorName = existingCast?['actorName'] ?? '';
    String castName = existingCast?['castName'] ?? '';
    String? imageUrl = existingCast?['imageUrl'];
    File? castImage;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(existingCast == null ? 'Add Cast' : 'Edit Cast'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(hintText: 'Actor Name'),
                      onChanged: (value) => actorName = value,
                      controller: TextEditingController(text: actorName),
                    ),
                    TextField(
                      decoration: InputDecoration(hintText: 'Cast Name'),
                      onChanged: (value) => castName = value,
                      controller: TextEditingController(text: castName),
                    ),
                    ElevatedButton(
                      child: Text(castImage != null || imageUrl != null ? 'Image Selected' : 'Select Image'),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          setState(() {
                            castImage = File(pickedFile.path);
                            imageUrl = null;
                          });
                        }
                      },
                    ),
                    if (imageUrl != null)
                      Image.network(imageUrl!, height: 100, width: 100, fit: BoxFit.cover),
                    if (castImage != null)
                      Image.file(castImage!, height: 100, width: 100, fit: BoxFit.cover),
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
                    if (actorName.isNotEmpty && castName.isNotEmpty) {
                      Navigator.of(context).pop({
                        'actorName': actorName,
                        'castName': castName,
                        'imageUrl': imageUrl,
                        'imagePath': castImage?.path,
                      });
                    }
                  },
                ),
              ],
            );
          }
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          if (existingCast != null) {
            int index = castList.indexOf(existingCast);
            if (index != -1) {
              castList[index] = value;
            }
          } else {
            castList.add(value);
          }
        });
      }
    });
  }

  void deleteCast(int index) {
    setState(() {
      castList.removeAt(index);
    });
  }

  Future<void> updateMovieData() async {
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
      await FirebaseFirestore.instance.collection('movies').doc(widget.documentId).update(updatedMovieData);
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: MyColor().darkblue,
          title: const Text('Edit Movie'),
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
                        : (_imageUrl != null
                            ? Image.network(_imageUrl!, height: 150, width: 150, fit: BoxFit.cover)
                            : Image.asset('asset/phot_icons.png', height: 200, width: 200)),
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
                const SizedBox(height: 20),
                Text('Cast', style: TextStyle(color: MyColor().white, fontSize: 18)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ...castList.asMap().entries.map((entry) {
                      final index = entry.key;
                      final cast = entry.value;
                      return Stack(
                        children: [
                          GestureDetector(
                            onTap: () => showAddCastDialog(cast),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundImage: cast['imageUrl'] != null
                                      ? NetworkImage(cast['imageUrl'])
                                      : (cast['imagePath'] != null
                                          ? FileImage(File(cast['imagePath']))
                                          : null) as ImageProvider?,
                                  child: (cast['imageUrl'] == null && cast['imagePath'] == null)
                                      ? Icon(Icons.person, color: MyColor().white)
                                      : null,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  cast['actorName'] ?? '',
                                  style: TextStyle(color: MyColor().white, fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
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
                      onTap: () => showAddCastDialog(),
                      child: Column(
                        children: [
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: MyColor().white
                            ),
                            child: Icon(Icons.add, color: MyColor().darkblue),
                          ),
                          SizedBox(height: 5),
                          Text('Add Cast', style: TextStyle(color: MyColor().white, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: updateMovieData,
                  child: const Text('Update Movie'),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
