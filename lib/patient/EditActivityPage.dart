import 'package:flutter/material.dart';

class EditActivityPage extends StatefulWidget {
  final String currentActivityName;
  final int currentFrequency;

  const EditActivityPage({
    Key? key,
    required this.currentActivityName,
    required this.currentFrequency,
  }) : super(key: key);

  @override
  _EditActivityPageState createState() => _EditActivityPageState();
}

class _EditActivityPageState extends State<EditActivityPage> {
  TextEditingController activityNameController = TextEditingController();
  int frequency = 1;

  @override
  void initState() {
    super.initState();
    activityNameController.text = widget.currentActivityName;
    frequency = widget.currentFrequency;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Activity'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: activityNameController,
              decoration: const InputDecoration(labelText: 'Activity Name'),
            ),
            const SizedBox(height: 20),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  frequency = int.tryParse(value) ?? 1;
                });
              },
              decoration: const InputDecoration(labelText: 'Frequency'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
            onPressed: () {
              // Save the updated activity name and frequency
              String updatedActivityName = activityNameController.text;
              // Handle saving or updating the data as needed
              // You can navigate back to the previous page with the updated data
              Navigator.pop(context, {
                'activityName': updatedActivityName,
                'frequency': frequency,
              });
            },
            child: const Text('Save'),
          ),

          ],
        ),
      ),
    );
  }
}
