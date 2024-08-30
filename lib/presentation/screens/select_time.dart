
import 'package:flutter/material.dart';
import 'package:movietix_distributor/business_logis/provider/timercontroller.dart';
import 'package:movietix_distributor/presentation/constants/colors.dart';
import 'package:provider/provider.dart';


class SelectTime extends StatelessWidget {
  final String movieId;
  final String screenId;
  final String ownerId;

  const SelectTime({
    super.key, 
    required this.movieId, 
    required this.screenId, 
    required this.ownerId
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TimeSelectionProvider(),
      child: _SelectTimeContent(movieId: movieId, screenId: screenId, ownerId: ownerId),
    );
  }
}

class _SelectTimeContent extends StatelessWidget {
  final String movieId;
  final String screenId;
  final String ownerId;

  const _SelectTimeContent({
    Key? key,
    required this.movieId,
    required this.screenId,
    required this.ownerId
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TimeSelectionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Show Times', style: TextStyle(color: MyColor().white)),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Selected times will apply for the next 3 days:',
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              provider.nextThreeDays.map((date) => '${date.day}/${date.month}').join(', '),
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: provider.availableTimes.length + 1,
              itemBuilder: (context, index) {
                if (index == provider.availableTimes.length) {
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
                final time = provider.availableTimes[index];
                final isSelected = provider.selectedTimes.contains(time);
                return ElevatedButton(
                  child: Text(time, style: TextStyle(color: isSelected ? MyColor().darkblue : Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? Colors.white : MyColor().darkblue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    side: BorderSide(color: Colors.white),
                  ),
                  onPressed: () {
                    provider.toggleTimeSelection(time);
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
              onPressed: provider.selectedTimes.isNotEmpty
                  ? () async {
                      try {
                        await provider.saveToFirebase(movieId, screenId, ownerId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Saved successfully!')),
                        );
                        Navigator.of(context).pop();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error saving data. Please try again.')),
                        );
                      }
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddTimeDialog(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      final provider = Provider.of<TimeSelectionProvider>(context, listen: false);
      provider.addAvailableTime(pickedTime.format(context));
    }
  }
}