import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';



class TimeSelectionProvider extends ChangeNotifier {
  final List<String> _availableTimes = ['9:00 AM', '9:30 AM', '10:00 AM', '12:30 PM', '3:00 PM'];
  Set<String> _selectedTimes = {};

  List<String> get availableTimes => _availableTimes;
  Set<String> get selectedTimes => _selectedTimes;

  List<DateTime> get nextThreeDays {
    DateTime now = DateTime.now();
    return [
      now,
      now.add(const Duration(days: 1)),
       now.add( const Duration(days: 2)),
    ];
  }

  void toggleTimeSelection(String time) {
    if (_selectedTimes.contains(time)) {
      _selectedTimes.remove(time);
    } else {
      _selectedTimes.add(time);
    }
    notifyListeners();
  }

  void addAvailableTime(String time) {
    if (!_availableTimes.contains(time)) {
      _availableTimes.add(time);
      _availableTimes.sort((a, b) => _compareTimeOfDay(_parseTime(a), _parseTime(b)));
      notifyListeners();
    }
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(' ');
    final timeParts = parts[0].split(':');
    int hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    if (parts[1] == 'PM' && hour != 12) hour += 12;
    if (parts[1] == 'AM' && hour == 12) hour = 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  int _compareTimeOfDay(TimeOfDay time1, TimeOfDay time2) {
    if (time1.hour != time2.hour) {
      return time1.hour - time2.hour;
    }
    return time1.minute - time2.minute;
  }

  Future<void> saveToFirebase(String movieId, String screenId, String ownerId) async {
    try {
      final screenRef = FirebaseFirestore.instance
          .collection('owners')
          .doc(ownerId)
          .collection('screens')
          .doc(screenId);

      final movieScheduleRef = screenRef.collection('movie_schedules').doc(movieId);

      Map<String, dynamic> scheduleData = {};
      for (var date in nextThreeDays) {
        scheduleData[date.toIso8601String()] = _selectedTimes.toList();
      }

      await movieScheduleRef.set({
        'movie_id': movieId,
        'schedules': scheduleData,
      }, SetOptions(merge: true));

    } catch (e) {
      print('Error saving to Firebase: $e');
      throw e;
    }
  }

  Future<void> loadFromFirebase(String movieId, String screenId, String ownerId) async {
    try {
      final screenRef = FirebaseFirestore.instance
          .collection('owners')
          .doc(ownerId)
          .collection('screens')
          .doc(screenId);

      final movieScheduleRef = screenRef.collection('movie_schedules').doc(movieId);

      final docSnapshot = await movieScheduleRef.get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final schedules = data['schedules'] as Map<String, dynamic>;

        // Find the most recent date in the schedules
        final sortedDates = schedules.keys.map((e) => DateTime.parse(e)).toList()..sort();
        final mostRecentDate = sortedDates.last;
        final today = DateTime.now();
        final dateToUse = mostRecentDate.isBefore(today) ? today : mostRecentDate;

        final relevantSchedule = schedules[dateToUse.toIso8601String()] as List<dynamic>;
        _selectedTimes = Set.from(relevantSchedule.cast<String>());

        notifyListeners();
      }
    } catch (e) {
      print('Error loading from Firebase: $e');
      throw e;
    }
  }

  
}