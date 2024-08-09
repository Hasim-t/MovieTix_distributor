import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movietix_distributor/presentation/constants/colors.dart'; // Adjust the import path as needed

class SelectTime extends StatefulWidget {
  final String movieId;
  final String screenId;
  final String ownerId;

  const SelectTime({
    Key? key, 
    required this.movieId, 
    required this.screenId, 
    required this.ownerId
  }) : super(key: key);

  @override
  _SelectTimeState createState() => _SelectTimeState();
}

class _SelectTimeState extends State<SelectTime> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<String>> _selectedDateTimes = {};
  List<String> _availableTimes = ['9:00 AM', '9:30 AM', '10:00 AM', '12:30 PM', '3:00 PM'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Dates & Times', style: TextStyle(color: MyColor().white)),
        backgroundColor: MyColor().darkblue,
        iconTheme: IconThemeData(color: MyColor().white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: MyColor().darkblue,
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(Duration(days: 365)),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return _selectedDateTimes.containsKey(_normalizeDate(day));
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              calendarStyle: CalendarStyle(
                defaultTextStyle: TextStyle(color: MyColor().darkblue),
                weekendTextStyle: TextStyle(color: MyColor().darkblue.withOpacity(0.7)),
                selectedDecoration: BoxDecoration(
                  color: MyColor().darkblue,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: TextStyle(color: Colors.white),
                todayDecoration: BoxDecoration(
                  color: MyColor().darkblue.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(color: Colors.white),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(color: MyColor().darkblue, fontSize: 18),
                leftChevronIcon: Icon(Icons.chevron_left, color: MyColor().darkblue),
                rightChevronIcon: Icon(Icons.chevron_right, color: MyColor().darkblue),
              ),
            ),
          ),
          Expanded(
            child: _selectedDay == null
                ? Center(child: Text('Please select a date', style: TextStyle(color: Colors.white)))
                : GridView.builder(
                    padding: EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 2.5,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _availableTimes.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _availableTimes.length) {
                        return ElevatedButton(
                          child: Text('Add Time', style: TextStyle(color: MyColor().darkblue)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          onPressed: () {
                            _showAddTimeDialog(context);
                          },
                        );
                      }
                      final time = _availableTimes[index];
                      final isSelected = _selectedDateTimes[_normalizeDate(_selectedDay!)]?.contains(time) ?? false;
                      return ElevatedButton(
                        child: Text(time, style: TextStyle(color: isSelected ? MyColor().darkblue : Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected ? Colors.white : MyColor().darkblue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          side: BorderSide(color: Colors.white),
                        ),
                        onPressed: () {
                          setState(() {
                            final normalizedDate = _normalizeDate(_selectedDay!);
                            if (_selectedDateTimes.containsKey(normalizedDate)) {
                              if (isSelected) {
                                _selectedDateTimes[normalizedDate]!.remove(time);
                                if (_selectedDateTimes[normalizedDate]!.isEmpty) {
                                  _selectedDateTimes.remove(normalizedDate);
                                }
                              } else {
                                _selectedDateTimes[normalizedDate]!.add(time);
                              }
                            } else {
                              _selectedDateTimes[normalizedDate] = [time];
                            }
                          });
                        },
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              child: Text('Save', style: TextStyle(color: MyColor().darkblue)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _selectedDateTimes.isNotEmpty
                  ? () async {
                      await _saveToFirebase();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Saved successfully!')),
                      );
                      Navigator.of(context).pop();
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveToFirebase() async {
    try {
      final screenRef = FirebaseFirestore.instance
          .collection('owners')
          .doc(widget.ownerId)
          .collection('screens')
          .doc(widget.screenId);

      final movieScheduleRef = screenRef.collection('movie_schedules').doc(widget.movieId);

      Map<String, dynamic> scheduleData = {};
      _selectedDateTimes.forEach((date, times) {
        scheduleData[date.toIso8601String()] = times;
      });

      print('Saving data for movieId: ${widget.movieId}, screenId: ${widget.screenId}, ownerId: ${widget.ownerId}');
      print('Data being saved: $scheduleData');

      await movieScheduleRef.set({
        'movie_id': widget.movieId,
        'schedules': scheduleData,
      }, SetOptions(merge: true));

      print('Data saved successfully');

    } catch (e) {
      print('Error saving to Firebase: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving data. Please try again.')),
      );
    }
  }

  Future<void> _showAddTimeDialog(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        final newTime = pickedTime.format(context);
        _availableTimes.add(newTime);
      });
    }
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
