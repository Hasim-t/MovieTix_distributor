import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movietix_distributor/presentation/constants/colors.dart';
import 'package:movietix_distributor/business_logis/provider/movielist_provider.dart';
import 'package:movietix_distributor/presentation/screens/select_time.dart';
import 'package:movietix_distributor/presentation/widgets/movies_card.dart';
import 'package:provider/provider.dart';

class Selectingmovie extends StatefulWidget {
  final String screenId;
  final String ownerId;

  const Selectingmovie({
    Key? key,
    required this.screenId,
    required this.ownerId,
  }) : super(key: key);

  @override
  _SelectingmovieState createState() => _SelectingmovieState();
}

class _SelectingmovieState extends State<Selectingmovie> {
  String? selectedMovieId;

  void selectMovie(String movieId) {
    setState(() {
      selectedMovieId = movieId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Movie", style: TextStyle(color: MyColor().white)),
        backgroundColor: MyColor().darkblue,
        foregroundColor: MyColor().white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: MyColor().darkblue,
      body: Consumer<MovieListProvider>(
        builder: (context, movieListProvider, child) {
          return StreamBuilder<QuerySnapshot>(
            stream: movieListProvider.moviesStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}',
                      style: TextStyle(color: MyColor().white)),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: MyColor().white),
                );
              }

              List<DocumentSnapshot> documents = snapshot.data!.docs;

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot document = documents[index];
                        String movieId = document.id;
                        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                        return MovieCard(
                          data: data,
                          isSelected: selectedMovieId == movieId,
                          onSelect: () => selectMovie(movieId),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      child: Text("Select Movie"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                      onPressed: selectedMovieId != null
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SelectTime(
                                    movieId: selectedMovieId!,
                                    screenId: widget.screenId,
                                    ownerId: widget.ownerId,
                                  ),
                                ),
                              );
                            }
                          : null,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}