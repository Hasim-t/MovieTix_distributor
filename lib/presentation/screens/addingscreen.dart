import 'package:flutter/material.dart';
import 'package:movietix_distributor/business_logis/provider/adding_provider.dart';
import 'package:movietix_distributor/presentation/constants/colors.dart';
import 'package:movietix_distributor/presentation/widgets/textformfield.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'dart:ui' as ui;

class MoviesAddingScreen extends StatelessWidget {
  const MoviesAddingScreen({Key? key}) : super(key: key);

  Future<void> pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      Provider.of<MovieProvider>(context, listen: false).setImage(File(pickedFile.path));
    }
  }

  Future<bool> isValidImage(File file) async {
    try {
      final Uint8List bytes = await file.readAsBytes();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      return frameInfo.image.width > 0 && frameInfo.image.height > 0;
    } catch (e) {
      print('Error validating image: $e');
      return false;
    }
  }

  Future<void> showAddCastDialog(BuildContext context) async {
    String actorName = '';
    String castName = '';
    File? castImage;
    String? imageError;

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
                    SizedBox(height: 20),
                    castImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              castImage!,
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 100,
                                  width: 100,
                                  color: Colors.grey[300],
                                  child: Icon(Icons.error, color: Colors.red),
                                );
                              },
                            ),
                          )
                        : Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.person, size: 50),
                          ),
                    if (imageError != null)
                      Text(
                        imageError!,
                        style: TextStyle(color: Colors.red),
                      ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      child: Text(castImage != null ? 'Change Image' : 'Select Image'),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        try {
                          final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
                          if (pickedFile != null) {
                            final File file = File(pickedFile.path);
                            final bool isValid = await isValidImage(file);
                            if (isValid) {
                              setState(() {
                                castImage = file;
                                imageError = null;
                              });
                            } else {
                              setState(() {
                                imageError = 'Invalid image. Please select another.';
                                castImage = null;
                              });
                            }
                          }
                        } catch (e) {
                          setState(() {
                            imageError = 'Error selecting image: ${e.toString()}';
                            castImage = null;
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
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please fill all fields and select a valid image')),
                      );
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
            body: Stack(
              children: [
                Padding(
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
                       const  SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: movieProvider.isLoading
                              ? null
                              : () => movieProvider.uploadMovieData(context),
                          child: movieProvider.isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Add Movie'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: MyColor().white, backgroundColor: MyColor().darkblue,
                            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                if (movieProvider.isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}