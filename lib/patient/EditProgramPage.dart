import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/patient/programDetails.dart';
import 'package:flutter_application_1/services/models.dart';
import 'package:flutter_application_1/shared/background.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditPage extends StatefulWidget {
  final Program program;

  EditPage({
    required this.program,
  });

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late DateTime _startDate;
  late DateTime _endDate;
  late List<Map<String, dynamic>> _activities;
  late List<int?> _frequencies;
  late List<String> _timesPerWeekava; // Updated to String list

  final List<String> _availableActivities = [
    'Abduction',
    'Elbow-Extension',
    'Elbow-Flexion',
    'External-Rotation',
    'Internal-Rotation',
    'Shoulder-Extension',
    'Shoulder-Flexion',
  ];

  // Updated the TimesPerWeek list to String
  List<String> _timesPerWeek = [
    'Daily', '1', '2', '3', '4', '5', '6', '7'
  ];

  @override
  void initState() {
    super.initState();
    _startDate = widget.program.startDate.toDate();
    _endDate = widget.program.endDate.toDate();

    _activities = widget.program.activities.map((activity) => {
      'Activity Name': activity.activityName,
      'Frequency': activity.frequency,
      'TimesPerWeek' : activity.TimesPerWeek,
    }).toList();

    _frequencies =
        List<int?>.generate(_activities.length, (index) => _activities[index]['Frequency']);

    // Updated to fetch from String list
    _timesPerWeekava = List<String>.generate(_activities.length, (index) => _activities[index]['TimesPerWeek'] ?? 'Daily');
  }

  Future<void> _updateProgram(String pid) async {
    try {
      // Get the current user
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // After updating all activities, update the program in Firestore
        List<Map<String, dynamic>> updatedActivities = _activities.map((activity) {
          return {
            'Activity Name': activity['Activity Name'],
            'Frequency':_frequencies[_activities.indexOf(activity)],
            'TimesPerWeek': _timesPerWeekava[_activities.indexOf(activity)],
          };
        }).toList();

        Map<String, dynamic> dataToUpdate = {
          'Start Date': _startDate,
          'End Date': _endDate,
          'Activities': updatedActivities,
        };

        await FirebaseFirestore.instance.collection('Program').doc(pid).update(dataToUpdate);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProgramDetails(pid: widget.program.pid),
          ),
        );

        QuickAlert.show(
          context: context,
          text: "The Program has been updated!",
          type: QuickAlertType.success,
        );
      } else {
        print('User is not authenticated');
      }
    } catch (e) {
      print('Error updating Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        'Edit Program',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text('Note: The report will be generated based on the new date!'),
                      Text('Start Date: ${DateFormat('yyyy-MM-dd').format(_startDate)}'),
                      ElevatedButton(
                        onPressed: () => _selectStartDate(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF186257), // Same color as the update button
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Select Start Date'),
                      ),
                      const SizedBox(height: 20),
                      Text('End Date: ${DateFormat('yyyy-MM-dd').format(_endDate)}'),
                      ElevatedButton(
                        onPressed: () => _selectEndDate(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF186257), // Same color as the update button
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Select End Date'),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Text(
                            'Number of activites:',
                            style: TextStyle(
                              fontSize: 15,
                              // fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                          SizedBox(height: 5),
                          DropdownButton<int>(
                            value: _activities.length,
                            onChanged: (value) {
                              setState(() {
                                _activities = List.generate(value!, (index) {
                                  if (index < _activities.length) {
                                    return _activities[index];
                                  } else {
                                    return {
                                      'Activity Name': _availableActivities[0],
                                      'Frequency': _activities[index]['Frequency'],
                                      'TimesPerWeek': _activities[index]['TimesPerWeek'],

                                    };
                                  }
                                });
                                _frequencies = List<int?>.generate(value, (index) {
                                  if (index < _frequencies.length) {
                                    return _frequencies[index];
                                  } else {
                                    return 1;
                                  }
                                });
                              });
                            },
                            items: List.generate(7, (index) => index + 1)
                                .map((value) => DropdownMenuItem<int>(
                              value: value,
                              child: Text(value.toString()),
                            ))
                                .toList(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ...List.generate(
                        _activities.length,
                            (index) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: 10,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _activities[index]['Activity Name'],
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _activities[index]['Activity Name'] = newValue!;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Select Activity',
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: _activities[index]['Activity Name'] == null
                                            ? Colors.red
                                            : Color(0xFF186257),
                                      ),
                                      borderRadius: BorderRadius.all(Radius.circular(15)),
                                    ),
                                    errorText: _activities.any((activity) =>
                                    activity['Activity Name'] == _activities[index]['Activity Name'] &&
                                        activity != _activities[index])
                                        ? 'Please select another activity'
                                        : null,
                                  ),
                                  items: _availableActivities.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ),
                              SizedBox(width: 10),
                              Row(
                                children: [
                                  const Text(
                                    'Days/week:',
                                    style: TextStyle(
                                      // fontSize: 12,
                                      //fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),

                                  ),
                                  DropdownButton<String>(
                                    value: _timesPerWeekava[index],
                                    onChanged: (String? value) {
                                      if (value != null) {
                                        setState(() {
                                          _timesPerWeekava[index] = value;
                                        });
                                      }
                                    },
                                    items: _timesPerWeek
                                        .map((value) => DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    ))
                                        .toList(),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _frequencies[index] = _frequencies[index]! + 1;
                                        });
                                      },
                                      icon: const Icon(Icons.add),
                                      iconSize: 20, // Adjusting icon size
                                    ),
                                    Text('Repetitions/day:${_frequencies[index]} '),

                                    IconButton(
                                      onPressed: () {
                                        if (_frequencies[index]! > 1) {
                                          setState(() {
                                            _frequencies[index] = _frequencies[index]! - 1;
                                          });
                                        }
                                      },
                                      icon: const Icon(Icons.remove),
                                      iconSize: 20, // Adjusting icon size
                                    ),

                                    Align(
                                        alignment: Alignment.centerLeft,
                                        child: IconButton(
                                          onPressed: () => _confirmDeleteActivity(index),
                                          icon: const Icon(Icons.delete_forever, color: Colors.red),
                                          iconSize: 25, // Adjusting icon size
                                        )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _updateProgram(widget.program.pid),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF186257),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Update Program'),
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

  _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  // Function to confirm activity deletion
  _confirmDeleteActivity(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this activity?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _activities.removeAt(index);
                  _frequencies.removeAt(index);
                });
                Navigator.of(context).pop();
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
