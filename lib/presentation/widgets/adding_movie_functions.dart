import 'dart:io';
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:heif_converter/heif_converter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:movietix_distributor/business_logis/provider/adding_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

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
                        setState(() {
                          imageError = 'Processing image...';
                        });
                        final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          File file = File(pickedFile.path);
                          if (file.path.toLowerCase().endsWith('.heic')) {
                            setState(() {
                              imageError = 'Converting HEIC image...';
                            });
                            final jpegPath = await convertHeicToJpeg(file.path);
                            file = File(jpegPath);
                          }
                          final processedFile = await processAndValidateImage(file);
                          if (processedFile != null) {
                            setState(() {
                              castImage = processedFile;
                              imageError = null;
                            });
                          } else {
                            setState(() {
                              imageError = 'Invalid image. Please select another.';
                              castImage = null;
                            });
                          }
                        } else {
                          setState(() {
                            imageError = 'No image selected.';
                          });
                        }
                      } catch (e) {
                        setState(() {
                          imageError = 'Error processing image: ${e.toString()}';
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
        },
      );
    },
  );
}

Future<File?> processAndValidateImage(File file) async {
  try {
    // Compress the image
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      file.absolute.path.replaceAll(RegExp(r'\.[^\.]*$'), '_compressed.jpg'),
      quality: 88,
    );

    if (result == null) {
      print('Compression failed');
      return null;
    }

    // Validate the compressed image
    final Uint8List bytes = await result.readAsBytes();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    
    if (frameInfo.image.width > 0 && frameInfo.image.height > 0) {
      return File(result.path);
    } else {
      print('Invalid image dimensions');
      return null;
    }
  } catch (e) {
    print('Error processing and validating image: $e');
    return null;
  }
}

Future<String> convertHeicToJpeg(String heicPath) async {
  final jpegPath = heicPath.replaceAll('.heic', '.jpg');
  try {
    await HeifConverter.convert(
      heicPath,
      output: jpegPath,
    );
    return jpegPath;
  } catch (e) {
    print('Error converting HEIC to JPEG: $e');
    throw e;
  }
}


 Future<void> pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final movieProvider = Provider.of<MovieProvider>(context, listen: false);

    try {
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        print("File picked: ${pickedFile.path}");
        File file = File(pickedFile.path);

        // Check if the file is a HEIC image
        if (file.path.toLowerCase().endsWith('.heic')) {
          print("HEIC file detected. Attempting conversion...");
          try {
            final jpegPath = await convertHeicToJpeg(file.path);
            file = File(jpegPath);
            print("HEIC conversion successful. New path: ${file.path}");
          } catch (e) {
            print("HEIC conversion failed: $e");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error converting HEIC image: $e')),
            );
            return;
          }
        }

        // Process and validate the image
        print("Processing and validating image...");
        final processedFile = await processAndValidateImage(file);
        if (processedFile != null) {
          print("Image processed successfully. Path: ${processedFile.path}");
          movieProvider.setImage(processedFile);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image selected successfully')),
          );
        } else {
          print("Image processing failed.");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid image. Please select another.')),
          );
        }
      } else {
        print("No file picked.");
      }
    } catch (e) {
      print("Error in pickImage: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing image: $e')),
      );
    }
  }

  // Future<String> convertHeicToJpeg(String heicPath) async {
  //   final jpegPath = heicPath.replaceAll('.heic', '.jpg');
  //   try {
  //     await HeifConverter.convert(
  //       heicPath,
  //       output: jpegPath,
  //     );
  //     return jpegPath;
  //   } catch (e) {
  //     print('Error converting HEIC to JPEG: $e');
  //     throw e;
  //   }
  // }

  // Future<File?> processAndValidateImage(File file) async {
  //   try {
  //     // Compress the image
  //     final result = await FlutterImageCompress.compressAndGetFile(
  //       file.absolute.path,
  //       file.absolute.path.replaceAll(RegExp(r'\.[^\.]*$'), '_compressed.jpg'),
  //       quality: 88,
  //     );

  //     if (result == null) {
  //       print('Compression failed');
  //       return null;
  //     }

  //     // Validate the compressed image
  //     final Uint8List bytes = await result.readAsBytes();
  //     final ui.Codec codec = await ui.instantiateImageCodec(bytes);
  //     final ui.FrameInfo frameInfo = await codec.getNextFrame();

  //     if (frameInfo.image.width > 0 && frameInfo.image.height > 0) {
  //       return File(result.path);
  //     } else {
  //       print('Invalid image dimensions');
  //       return null;
  //     }
  //   } catch (e) {
  //     print('Error processing and validating image: $e');
  //     return null;
  //   }
  // }