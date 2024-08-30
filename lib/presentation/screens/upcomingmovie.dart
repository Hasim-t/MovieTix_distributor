import 'package:flutter/material.dart';
import 'package:movietix_distributor/business_logis/provider/fetchupcomgprovider.dart';
import 'package:movietix_distributor/presentation/constants/colors.dart';
import 'package:movietix_distributor/presentation/screens/upcoming/adding_upcoming.dart';
import 'package:provider/provider.dart';

class Upcomingmovie extends StatefulWidget {
  const Upcomingmovie({super.key});

  @override
  _UpcomingmovieState createState() => _UpcomingmovieState();
}

class _UpcomingmovieState extends State<Upcomingmovie> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UpcomingMoviesProvider>(context, listen: false).fetchUpcomingMovies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColor().darkblue,
        title: Text(
          'Upcoming Movies',
          style: TextStyle(color: MyColor().white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return AddingUpcoming();
          }));
        },
        backgroundColor: MyColor().darkblue,
        child: Icon(Icons.add, color: MyColor().white),
      ),
      backgroundColor: MyColor().darkblue,
      body: Consumer<UpcomingMoviesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator(color: MyColor().white));
          }
          if (provider.movies.isEmpty) {
            return Center(
              child: Text(
                'No upcoming movies available.',
                style: TextStyle(color: MyColor().white, fontSize: 18),
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(8.0),
            itemCount: provider.movies.length,
            itemBuilder: (context, index) {
              final movie = provider.movies[index];
              return Card(
                color: MyColor().darkblue.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  contentPadding: EdgeInsets.all(10.0),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      movie['imageUrl'],
                      width: 60,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    movie['name'],
                    style: TextStyle(
                      color: MyColor().white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),
                      Text(
                        '${movie['language']} | ${movie['category']}',
                        style: TextStyle(
                          color: MyColor().white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Delete Movie'),
                          content: Text('Are you sure you want to delete this movie?'),
                          actions: [
                            TextButton(
                              child: Text('Cancel', style: TextStyle(color: MyColor().darkblue)),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            TextButton(
                              child: Text('Delete', style: TextStyle(color: Colors.red)),
                              onPressed: () {
                                provider.deleteMovie(movie.id);
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
