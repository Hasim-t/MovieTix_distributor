import 'package:flutter/material.dart';
import 'package:movietix_distributor/business_logis/provider/adding_provider.dart';
import 'package:movietix_distributor/presentation/constants/colors.dart';
import 'package:movietix_distributor/presentation/widgets/textformfield.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class MoviesAddingScreen extends StatelessWidget {
  const MoviesAddingScreen({Key? key}) : super(key: key);

  Future<void> pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      Provider.of<MovieProvider>(context, listen: false).setImage(File(pickedFile.path));
    }
  }

  Future<void> showAddCastDialog(BuildContext context) async {
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
                      Provider.of<MovieProvider>(context, listen: false).addCast({
                        'actorName': actorName,
                        'castName': castName,
                        'imagePath': castImage!.path,
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

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieProvider>(
      builder: (context, movieProvider, child) {
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
                        onTap: () => pickImage(context),
                        child: movieProvider.image != null
                            ? Image.file(movieProvider.image!, height: 150, width: 150, fit: BoxFit.cover)
                            : Image.asset('asset/phot_icons.png', height: 200, width: 200),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomTextFormField(controller: movieProvider.movienamecontroller, hintText: 'Movie Name'),
                    const SizedBox(height: 20),
                    CustomTextFormField(controller: movieProvider.languagecontroller, hintText: 'Language'),
                    const SizedBox(height: 20),
                    CustomTextFormField(controller: movieProvider.categorycontroller, hintText: 'Category'),
                    const SizedBox(height: 20),
                    CustomTextFormField(controller: movieProvider.certificationcontroller, hintText: 'Certification'),
                    const SizedBox(height: 20),
                    CustomTextFormField(controller: movieProvider.descriptioncontroller, hintText: 'Description', maxlines: 6),
                    Text('Cast', style: TextStyle(color: MyColor().white, fontSize: 18)),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ...movieProvider.castList.asMap().entries.map((entry) {
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
                                  onTap: () => movieProvider.deleteCast(index),
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
                          onTap: () => showAddCastDialog(context),
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
                      onPressed: () => movieProvider.uploadMovieData(context),
                      child: const Text('Add Movie'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}