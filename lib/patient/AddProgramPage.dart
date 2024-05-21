import 'package:flutter/material.dart';
import 'package:flutter_application_1/shared/background.dart';
import 'AddActivityPage.dart'; 
import 'package:intl/intl.dart';

class AddProgramPage extends StatefulWidget {
  final String pid;
  const AddProgramPage({super.key, required this.pid});

  @override
  _AddProgramPageState createState() => _AddProgramPageState();
}

class _AddProgramPageState extends State<AddProgramPage> {
  bool isNumeric = true;
  int numberOfActivities = 1;
  DateTime? startDate;
  DateTime? endDate;
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  final _formKey = GlobalKey<FormState>(); // Add form key
  bool endDateBeforeStartDate = false;
  
  Future<void> _pickDate(BuildContext context, {required bool isStart}) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: isStart ? startDate ?? DateTime.now() : endDate ?? DateTime.now(),
    firstDate: DateTime.now(), // Set first date to today
    lastDate: DateTime(2101),
  );

  if (picked != null) {
    setState(() {
      if (isStart) {
        startDate = picked;
      } else {
        endDate = picked;
        if (startDate != null && endDate!.isBefore(startDate!)) {
          endDateBeforeStartDate = true;
        } else {
          endDateBeforeStartDate = false;
        }
      }
    });

    if (!isStart && endDateBeforeStartDate) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Choose appropriate end date'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}


  void _goToHomePage(BuildContext context) {
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Background(),
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
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height / 2,
              color: const Color(0xFF186257),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: 0.80,
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
                  child: Form(
                    key: _formKey, // Assign form key
                    autovalidateMode: AutovalidateMode
                        .onUserInteraction, // Auto validate on user interaction
                    child: Column(
                      children: [
                        const Text(
                          'Add program',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'We are here to help you!',
                          style: TextStyle(
                              fontSize: 18, fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        Container(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Start Date',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                                borderSide:
                                    BorderSide(color: Color(0xFF186257)),
                              ),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            readOnly: true,
                            controller: TextEditingController(
                              text: startDate != null
                                  ? dateFormat.format(startDate!)
                                  : '',
                            ),
                            onTap: () => _pickDate(context, isStart: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Start Date is required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'End Date',
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              borderSide: BorderSide(color: Color(0xFF186257)),
                            ),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          controller: TextEditingController(
                              text: endDate != null
                                  ? dateFormat.format(endDate!)
                                  : ''),
                          onTap: () => _pickDate(context, isStart: false),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'End Date is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        DropdownButtonFormField<int>(
                          decoration: const InputDecoration(
                            labelText: 'Number of Activities',
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              borderSide: BorderSide(color: Color(0xFF186257)),
                            ),
                          ),
                          value: numberOfActivities,
                          items: List.generate(7, (index) => index + 1)
                              .map<DropdownMenuItem<int>>((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(value.toString()),
                            );
                          }).toList(),
                          onChanged: (int? newValue) {
                            setState(() {
                              numberOfActivities = newValue ?? 1;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Number of Activities is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton(
                          onPressed: () {
                            if (!endDateBeforeStartDate) {
                              // Proceed to the next step
                              if (_formKey.currentState!.validate()) {
                                if (startDate != null && endDate != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddActivitiesPage(
                                        pid: widget.pid,
                                        startDate: startDate!,
                                        endDate: endDate!,
                                        numberOfActivities: numberOfActivities,
                                      ),
                                    ),
                                  ).then((value) {
                                    _goToHomePage(context);
                                  });
                                }
                              }
                            } else {
                              // Show snackbar for choosing appropriate end date
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Choose appropriate end date'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                const Color(0xFF186257)),
                            foregroundColor: MaterialStateProperty.all(
                                const Color.fromARGB(255, 255, 255, 255)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          ),
                          child: Text('Next'),
// Disable the button if end date is before start date
                          // enabled: !endDateBeforeStartDate,
                        ),
                      ],
                    ),
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
