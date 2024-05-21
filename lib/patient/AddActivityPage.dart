import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/shared/background.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddActivitiesPage extends StatefulWidget {
  final String pid;
  final int numberOfActivities;
  final DateTime startDate;
  final DateTime endDate;

  const AddActivitiesPage({
    Key? key,
    required this.numberOfActivities,
    required this.startDate,
    required this.endDate,
    required this.pid,
  }) : super(key: key);

  @override
  State<AddActivitiesPage> createState() => _AddActivitiesPageState();
}

class _AddActivitiesPageState extends State<AddActivitiesPage> {
  List<String?> _selectedActivities = [];
  List<int?> _frequencies = [];
  List<String?> _selectedTimesPerWeek = [];
  List<String> TimesPerWeek = [
    'Daily',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
  ];
  String? _selectedFrequency; // Variable to store selected frequency
  bool _showError = false; // Flag to indicate whether to show error

  @override
  void initState() {
    super.initState();
    _selectedActivities =
        List<String?>.generate(widget.numberOfActivities, (index) => null);
    _frequencies = List<int?>.generate(widget.numberOfActivities, (index) => 1);
    _selectedTimesPerWeek = List<String?>.generate(widget.numberOfActivities,
        (index) => TimesPerWeek[0]); // Initialize with the first option
  }

  void _onFrequencyChanged(String? newValue) {
    setState(() {
      _selectedFrequency = newValue;
    });
  }

  void _onTimesPerWeekChanged(String? newValue, int index) {
    setState(() {
      _selectedTimesPerWeek[index] = newValue;
    });
  }

  void _onActivityChanged(String? newValue, int index) {
    setState(() {
      _selectedActivities[index] = newValue;

      // Remove the selected activity from other dropdown lists
      for (int i = 0; i < widget.numberOfActivities; i++) {
        if (i != index && _selectedActivities[i] == newValue) {
          _selectedActivities[i] = null;
        }
      }
    });
  }

  Future<void> _submitActivities(String pid) async {
    bool isValid = true;
// Check if every activity is selected and frequency is set
    for (int i = 0; i < _selectedActivities.length; i++) {
      if (_selectedActivities[i] == null || _frequencies[i] == null) {
        isValid = false;
        break;
      }
    }
    if (!isValid) {
      setState(() {
        _showError = true;
      });

      return; // Exit the method if validation fails
    }
    // Reset showError flag if no error
    setState(() {
      _showError = false;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String therapistId = user.uid;

        DocumentSnapshot therapistDocSnapshot = await FirebaseFirestore.instance
            .collection('Therapist')
            .doc(therapistId)
            .get();

        int currentCounter = therapistDocSnapshot.exists
            ? (therapistDocSnapshot.data() as Map<String, dynamic>?) != null
                ? (therapistDocSnapshot.data()
                        as Map<String, dynamic>?)!['programCounter'] ??
                    0
                : 0
            : 0;

        String programId = (currentCounter + 1).toString();

        await FirebaseFirestore.instance
            .collection('Therapist')
            .doc(therapistId)
            .set({'programCounter': currentCounter + 1},
                SetOptions(merge: true));

        List<Map<String, dynamic>> activitiesList = [];

        for (int i = 0; i < widget.numberOfActivities; i++) {
          String? selectedActivity = _selectedActivities[i];
          int frequency = _frequencies[i] ?? 1;
          String? timesPerWeek = _selectedTimesPerWeek[i];

          if (selectedActivity != null) {
            // Retrieve frequency based on the selected times per week
            int frequencyNumber =
                timesPerWeek == 'Daily' ? 7 : int.parse(timesPerWeek!);

            activitiesList.add({
              'Activity Name': selectedActivity,
              'Frequency': frequency,
              'TimesPerWeek': frequencyNumber,
            });
          }
        }

        Map<String, dynamic> dataToSave = {
          'Therapist ID': therapistId,
          'Patient Number': pid,
          'Program ID': programId,
          'Start Date': widget.startDate,
          'End Date': widget.endDate,
          'NumberOfActivities': widget.numberOfActivities,
          'Activities': activitiesList,
        };

        await FirebaseFirestore.instance
            .collection('Program')
            .doc(programId)
            .set(dataToSave);

        // ignore: use_build_context_synchronously
        Navigator.of(context).pushNamed('homepage');

        QuickAlert.show(
          // ignore: use_build_context_synchronously
          context: context,
          text: "the program is added successfully!",
          type: QuickAlertType.success,
        );
      } else {
        print('User is not authenticated');
      }
    } catch (e) {
      print('Error adding to Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  //    bottomNavigationBar: const NavBar(),
      body: Stack(
        children: [
          Background(),
          SizedBox(
            height: 60,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Positioned(
                top: 20,
                left: 10,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 25,
                    color: Color(0xFFFFFFFF),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: 0.8,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      const Text(
                        'Add Activities',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ...List.generate(
                        widget.numberOfActivities,
                        (index) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: 10,
                          ),
                          child: ActivityForm(
                            activityNumber: index + 1,
                            selectedActivity: _selectedActivities[index],
                            frequency: _frequencies[index] ?? 1,
                            onActivityChanged: (newValue) =>
                                _onActivityChanged(newValue, index),
                            onFrequencyChanged: (newValue) {
                              setState(() {
                                _frequencies[index] = newValue;
                              });
                            },
                            showError: _showError,
                            TimesPerWeek: TimesPerWeek,
                            selectedTimesPerWeek: _selectedTimesPerWeek[
                                index], // Pass selectedTimesPerWeek for each activity
                            onTimesPerWeekChanged: (newValue) {
                              _onTimesPerWeekChanged(newValue,
                                  index); // Update the selectedTimesPerWeek for this activity
                            },
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _submitActivities(widget.pid),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF186257),
                          // background
                          foregroundColor: Colors.white,
                          // foreground
                        ),
                        child: const Text('Submit Activities'),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityForm extends StatefulWidget {
  final int activityNumber;
  final String? selectedActivity;
  final int frequency;
  final Function(String?) onActivityChanged;
  final Function(int) onFrequencyChanged;
  final bool showError;
  final List<String> TimesPerWeek;
  final String? selectedTimesPerWeek;
  final Function(String?) onTimesPerWeekChanged;

  const ActivityForm({
    Key? key,
    required this.activityNumber,
    required this.selectedActivity,
    required this.frequency,
    required this.onActivityChanged,
    required this.onFrequencyChanged,
    required this.showError,
    required this.TimesPerWeek,
    required this.selectedTimesPerWeek,
    required this.onTimesPerWeekChanged,
  }) : super(key: key);

  @override
  _ActivityFormState createState() => _ActivityFormState();
}

class _ActivityFormState extends State<ActivityForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Text(
              'Activity ${widget.activityNumber}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: widget.selectedActivity,
            decoration: InputDecoration(
              labelText: 'Select Activity',
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: widget.showError && widget.selectedActivity == null
                      ? Colors.red
                      : Color(0xFF186257),
                ),
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              errorText: widget.showError && widget.selectedActivity == null
                  ? 'Please select another activity'
                  : null,
            ),
            onChanged: widget.onActivityChanged,
            items:
                [
              'Abduction',
              'Elbow-Extension',
              'Elbow-Flexion',
              'External-Rotation',
              'Internal-Rotation',
              'Shoulder-Extension',
              'Shoulder-Flexion'
                ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),

              );
            }).toList(),
          ),
            
          
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: widget.selectedTimesPerWeek,
            decoration: InputDecoration(
              labelText: 'Days Per Week',
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: widget.showError && widget.selectedTimesPerWeek == null
                      ? Colors.red
                      : Color(0xFF186257),
                ),
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              errorText: widget.showError && widget.selectedTimesPerWeek == null
                  ? 'Please select frequency'
                  : null,
            ),
            onChanged: widget.onTimesPerWeekChanged,
            items: widget.TimesPerWeek.map<DropdownMenuItem<String>>(
                (String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  widget.onFrequencyChanged(widget.frequency + 1);
                },
                icon: const Icon(Icons.add),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(
                  ' Reptitions per day: ${widget.frequency}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              IconButton(
                onPressed: () {
                  if (widget.frequency > 1) {
                    widget.onFrequencyChanged(widget.frequency - 1);
                  }
                },
                icon: const Icon(Icons.remove),
              ),
              
            ],
          ),
        ],
      ),
    );
  }
}