import 'package:flutter/material.dart';
import 'package:movietix_distributor/business_logis/provider/adding_provider.dart';
import 'package:movietix_distributor/presentation/constants/colors.dart';
import 'package:movietix_distributor/presentation/widgets/adding_movie_functions.dart';
import 'package:movietix_distributor/presentation/widgets/dropdown_widget.dart';
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
                        CustomTextFormField(controller: movieProvider.movienamecontroller, hintText: 'Movie Name',label: 'Movie Name',),
                        const SizedBox(height: 20),
                       
                dropdownwidget(
                          movieProvider: movieProvider,
                          names: 'Select language',
                          value: movieProvider.languages,
                          type: 'languages',
                          set: movieProvider.setLanguage,
                        ),
                        const SizedBox(height: 20),
                        dropdownwidget(
                          movieProvider: movieProvider,
                          names: 'Select category',
                          value: movieProvider.categories,
                          type: 'categories',
                          set: movieProvider.setCategory,
                        ),
                        const SizedBox(height: 20),
                        CustomTextFormField(controller: movieProvider.certificationcontroller, hintText: 'Certification', label: 'Certification',),
                        const SizedBox(height: 20),
                        CustomTextFormField(controller: movieProvider.descriptioncontroller, hintText: 'Description', maxlines: 6, label: 'Description',),
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
                    child: const  Center(
                      child:  CircularProgressIndicator(
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