import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movietix_distributor/presentation/constants/colors.dart';
import 'package:intl/intl.dart';

class ScreenDeatials extends StatelessWidget {
  final String screenName;
  final int rows;
  final int cols;
  final String ownerId;
  final String screenId;

  const ScreenDeatials({
    Key? key,
    required this.screenName,
    required this.rows,
    required this.cols,
    required this.ownerId,
    required this.screenId,
  }) : super(key: key);

  Future<void> deleteMovieSchedule(String movieScheduleId) async {
    try {
      await FirebaseFirestore.instance
          .collection('owners')
          .doc(ownerId)
          .collection('screens')
          .doc(screenId)
          .collection('movie_schedules')
          .doc(movieScheduleId)
          .delete();
    } catch (e) {
      print('Error deleting movie schedule: $e');
    }
  }
Future<void> extendMovieSchedule(String movieScheduleId, DateTime newDate, List<String> newShowtimes) async {
  try {
    // Fetch current schedule
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('owners')
        .doc(ownerId)
        .collection('screens')
        .doc(screenId)
        .collection('movie_schedules')
        .doc(movieScheduleId)
        .get();

    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Map<String, dynamic> schedules = data['schedules'] as Map<String, dynamic>;

   
    String newDateString = DateFormat('yyyy-MM-dd').format(newDate);
    
  
    schedules[newDateString] = newShowtimes;

    // Update Firestore document
    await FirebaseFirestore.instance
        .collection('owners')
        .doc(ownerId)
        .collection('screens')
        .doc(screenId)
        .collection('movie_schedules')
        .doc(movieScheduleId)
        .update({'schedules': schedules});

  } catch (e) {
    print('Error extending movie schedule: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Screen: $screenName',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [MyColor().darkblue, MyColor().darkblue.withOpacity(0.7)],
                  ),
                ),
                child: Center(
                  child: Icon(Icons.movie, size: 80, color: Colors.white70),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard('Screen Information', [
                    'Rows: $rows',
                    'Columns: $cols',
                    'Total Seats: ${rows * cols}',
                  ]),
                  SizedBox(height: 16),
                  Text(
                    'Movie Schedules',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('owners')
                .doc(ownerId)
                .collection('screens')
                .doc(screenId)
                .collection('movie_schedules')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: Colors.white)),
                );
              }

              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white))),
                );
              }

              var movieSchedules = snapshot.data?.docs ?? [];

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    var movieSchedule = movieSchedules[index];
                    var movieScheduleId = movieSchedule.id;
                    var movieScheduleData = movieSchedule.data() as Map<String, dynamic>;
                    var movieId = movieScheduleData['movie_id'] as String;
                    var schedules = movieScheduleData['schedules'] as Map<String, dynamic>;

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('movies').doc(movieId).get(),
                      builder: (context, movieSnapshot) {
                        if (movieSnapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator(color: Colors.white));
                        }

                        var movieData = movieSnapshot.data?.data() as Map<String, dynamic>?;
                        var movieName = movieData?['name'] ?? 'Unknown Movie';
                        var imageUrl = movieData?['imageUrl'] ?? "asset/phot_icons.png";

                        return Card(
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          color: MyColor().gray.withOpacity(0.1),
                          child: ExpansionTile(
                            leading: Hero(
                              tag: 'movie_$movieId',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageUrl,
                                  width: 60,
                                  height: 90,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            title: Text(
                              movieName,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
  icon: Icon(Icons.calendar_today, color: Colors.blue),
  onPressed: () async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      List<String> newShowtimes = await showDialog(
        context: context,
        builder: (BuildContext context) {
          List<String> tempShowtimes = [];
          return AlertDialog(
            title: Text("Add Showtimes"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Enter showtimes for ${DateFormat('yyyy-MM-dd').format(picked)}"),
                ElevatedButton(
                  child: Text("Add Showtime"),
                  onPressed: () async {
                    TimeOfDay? time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      tempShowtimes.add("${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}");
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text("Cancel"),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text("Confirm"),
                onPressed: () => Navigator.of(context).pop(tempShowtimes),
              ),
            ],
          );
        },
      );
      
      if (  newShowtimes.isNotEmpty) {
        await extendMovieSchedule(movieScheduleId, picked, newShowtimes);
      }
    }
  },
),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Delete Movie Schedule"),
                                          content: Text("Are you sure you want to delete this movie schedule?"),
                                          actions: [
                                            TextButton(
                                              child: Text("Cancel"),
                                              onPressed: () => Navigator.of(context).pop(),
                                            ),
                                            TextButton(
                                              child: Text("Delete"),
                                              onPressed: () {
                                                deleteMovieSchedule(movieScheduleId);
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                            children: schedules.entries.map((entry) {
                              var date = DateTime.parse(entry.key);
                              var times = entry.value as List<dynamic>;
                              return Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      DateFormat('EEEE, MMMM d, y').format(date),
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: times.map((time) => Chip(
                                        label: Text(time, style: TextStyle(color: MyColor().darkblue, fontWeight: FontWeight.bold)),
                                        backgroundColor: Colors.white,
                                        elevation: 2,
                                      )).toList(),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    );
                  },
                  childCount: movieSchedules.length,
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: MyColor().darkblue,
    );
  }

  Widget _buildInfoCard(String title, List<String> details) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ...details.map((detail) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(detail, style: TextStyle(color: Colors.white70, fontSize: 16)),
            )),
          ],
        ),
      ),
    );
  }
}