import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:movietix_distributor/presentation/constants/colors.dart';
import 'package:movietix_distributor/presentation/widgets/textformfield.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../../business_logis/provider/editing_provider.dart';

class Editingscreen extends StatelessWidget {
  final String documentId;
  final Map<String, dynamic> movieData;

  const Editingscreen({Key? key, required this.documentId, required this.movieData}) : super(key: key);

  Future<void> showAddCastDialog(BuildContext context, [Map<String, dynamic>? existingCast]) async {
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
        if (existingCast != null) {
          int index = Provider.of<MovieEditProvider>(context, listen: false).castList.indexOf(existingCast);
          if (index != -1) {
            Provider.of<MovieEditProvider>(context, listen: false).addOrUpdateCast(value, index);
          }
        } else {
          Provider.of<MovieEditProvider>(context, listen: false).addOrUpdateCast(value);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MovieEditProvider(movieData),
      child: Consumer<MovieEditProvider>(
        builder: (context, movieEditProvider, child) {
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
                          onTap: movieEditProvider.pickImage,
                          child: movieEditProvider.image != null
                              ? Image.file(movieEditProvider.image!, height: 150, width: 150, fit: BoxFit.cover)
                              : (movieEditProvider.imageUrl != null
                                  ? Image.network(movieEditProvider.imageUrl!, height: 150, width: 150, fit: BoxFit.cover)
                                  : Image.asset('asset/phot_icons.png', height: 200, width: 200)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      CustomTextFormField(controller: movieEditProvider.movienamecontroller, hintText: 'Movie Name'),
                      const SizedBox(height: 20),
                      CustomTextFormField(controller: movieEditProvider.languagecontroller, hintText: 'Language'),
                      const SizedBox(height: 20),
                      CustomTextFormField(controller: movieEditProvider.categorycontroller, hintText: 'Category'),
                      const SizedBox(height: 20),
                      CustomTextFormField(controller: movieEditProvider.certificationcontroller, hintText: 'Certification'),
                      const SizedBox(height: 20),
                      CustomTextFormField(controller: movieEditProvider.descriptioncontroller, hintText: 'Description', maxlines: 6),
                      const SizedBox(height: 20),
                      Text('Cast', style: TextStyle(color: MyColor().white, fontSize: 18)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          ...movieEditProvider.castList.asMap().entries.map((entry) {
                            final index = entry.key;
                            final cast = entry.value;
                            return Stack(
                              children: [
                                GestureDetector(
                                  onTap: () => showAddCastDialog(context, cast),
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
                                    onTap: () => movieEditProvider.deleteCast(index),
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
                        onPressed: () => movieEditProvider.updateMovieData(documentId, context),
                        child: const Text('Update Movie'),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}