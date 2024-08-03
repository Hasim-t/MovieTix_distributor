 import 'dart:io';
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:movietix_distributor/business_logis/provider/adding_provider.dart';
import 'package:provider/provider.dart';

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