import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/ReportDetails.dart';
import 'package:flutter_application_1/home/loadingpage.dart';
import 'package:flutter_application_1/services/firestore.dart';
import 'package:flutter_application_1/services/models.dart';
import 'package:flutter_application_1/shared/nav_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SelectedProgram extends ChangeNotifier {
  Program? _selectedProgram;

  Program? get selectedProgram => _selectedProgram;

  void setSelectedProgram(Program? program) {
    _selectedProgram = program;
    notifyListeners();
  }
}

class pickProgram extends StatefulWidget {
  final String pid;

  const pickProgram({Key? key, required this.pid}) : super(key: key);

  @override
  _pickProgramState createState() => _pickProgramState();
}

class _pickProgramState extends State<pickProgram> {
  Future<void> _AddPatientNumber(String pid) async {
    // // Check if at least one activity is selected
    // if (_selectedActivities.contains(null)) {
    //   setState(() {
    //     _showError = true; // Set showError flag to true
    //   });
    //   return;
    // }
    // // Reset showError flag if no error
    // setState(() {
    //   _showError = false;
    // });
    // try {
    //   // Get the current user
    //   User? user = FirebaseAuth.instance.currentUser;

    //   if (user != null) {
    //     // Use the user's UID as the therapist ID
    //     String therapistId = user.uid;

    //     // Fetch current counter value for the therapist
    //     DocumentSnapshot therapistDocSnapshot = await FirebaseFirestore.instance
    //         .collection('Therapist')
    //         .doc(therapistId)
    //         .get();

    //     int currentCounter = therapistDocSnapshot.exists
    //         ? (therapistDocSnapshot.data() as Map<String, dynamic>?) != null
    //             ? (therapistDocSnapshot.data()
    //                     as Map<String, dynamic>?)!['programCounter'] ??
    //                 0
    //             : 0
    //         : 0;

    //     // Use the current counter value as the program ID
    //     String programId = (currentCounter + 1).toString();

    // Retrieve the document with the specified Program ID
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Report')
        .where('Program ID', isEqualTo: pid)
        .get();

// Check if any documents match the query
    if (querySnapshot.docs.isNotEmpty) {
      // Get the first document (assuming there's only one document with the specified Program ID)
      DocumentSnapshot documentSnapshot = querySnapshot.docs.first;

      // Add the 'Patient Number' field to the document
      await documentSnapshot.reference.update({'Patient Number': widget.pid});
    } else {
      // Handle the case where no documents match the query
      print('No documents found with Program ID: $pid');
    }

    //     // Proceed with adding the program using the programId
    //     List<Map<String, dynamic>> activitiesList = [];

    //     for (int i = 0; i < widget.numberOfActivities; i++) {
    //       String? selectedActivity = _selectedActivities[i];
    //       int frequency = _frequencies[i] ?? 1;

    //       // Check if the activity is selected before adding it to the list
    //       if (selectedActivity != null) {
    //         activitiesList.add({
    //           'Activity Name': selectedActivity,
    //           'Frequency': frequency,
    //         });
    //       }
    //     }

    //     Map<String, dynamic> dataToSave = {
    //       'Therapist ID': therapistId,
    //       'Patient Number':
    //           pid, // Add patient ID to associate program with patient
    //       'Program ID': programId,
    //       'Start Date': widget.startDate,
    //       'End Date': widget.endDate,
    //       'NumberOfActivities': widget.numberOfActivities,
    //       'Activities': activitiesList,
    //     };

    //     // Add the program using the therapist's ID
    //     await FirebaseFirestore.instance
    //         .collection('Program')
    //         .doc(programId)
    //         .set(dataToSave);

    //     Navigator.of(context).pushNamed('homepage');

    //     QuickAlert.show(
    //       context: context,
    //       text: "The Program is in your list now!",
    //       type: QuickAlertType.success,
    //     );
    //   } else {
    //     print('User is not authenticated');
    //   }
    // } catch (e) {
    //   print('Error adding to Firestore: $e');
    // }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SelectedProgram(),
      child: Scaffold(
        backgroundColor: const Color(0xFF186257),
      //  bottomNavigationBar: const NavBar(),
        body: SafeArea(
          child: StreamBuilder<List<Report>>(
              stream: FirestoreService().streamPatientReports(widget.pid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingPage();
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                List<Report> reports = snapshot.data!;

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          size: 25,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(25, 40, 25, 0),
                      ),
                      StreamBuilder<List<Program>>(
                        stream: FirestoreService()
                            .streamPatientPrograms(widget.pid),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const LoadingPage();
                          }
                          if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          }

                          List<Program> programs = snapshot.data!;
                          List<int> pWithReport = [];
                          List<Program> programsWithReport = [];

                          for (int i = 0; i < programs.length; i++) {
                            bool have_report = false;
                            for (int j = 0; j < reports.length; j++) {
                              if (programs[i].pid == reports[j].ProgramID) {
                                have_report = true;
                              }
                            }
                            if (have_report) {
                              pWithReport.add(i);
                              programsWithReport.add(programs[i]);
                            }
                          }
                          programs
                              .sort((a, b) => b.endDate.compareTo(a.endDate));
                          if (programs.isEmpty) {
                            return Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Container(
                                  padding: const EdgeInsets.all(30),
                                  height: 4000,
                                  color: Colors.grey[100],
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Select program to generate report',
                                        style: TextStyle(
                                          fontFamily: 'Merriweather',
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 25),
                                      Text('No program is found')
                                    ],
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Container(
                                  padding: const EdgeInsets.all(30),
                                  height: 4000,
                                  color: Colors.grey[100],
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Select program to generate report',
                                        style: TextStyle(
                                          fontFamily: 'Merriweather',
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 25),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.5,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: programs.length,
                                          itemBuilder: (context, index) {
                                            Program program = programs[index];

                                            final selectedProgram =
                                                Provider.of<SelectedProgram>(
                                                    context);

                                            bool isSelected = selectedProgram
                                                    .selectedProgram ==
                                                program;

                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8),
                                              child: GestureDetector(
                                                onTap: () {
                                                  if (isSelected &
                                                      !programsWithReport
                                                          .contains(program)) {
                                                    selectedProgram
                                                        .setSelectedProgram(
                                                            null);
                                                    print(
                                                        'isSelected: $isSelected');
                                                  } else {
                                                    selectedProgram
                                                        .setSelectedProgram(
                                                            program);
                                                    print(
                                                        'isSelected: $isSelected');
                                                  }
                                                },
                                                child: Material(
                                                  elevation:
                                                      5, // Set elevation to 5
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  color: pWithReport
                                                          .contains(index)
                                                      ? Colors.grey[400]
                                                      : Colors.white,
                                                  borderOnForeground:
                                                      true, // Add this line
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                      border: Border.all(
                                                        color: isSelected &
                                                                !pWithReport
                                                                    .contains(
                                                                        index)
                                                            ? Colors.blue
                                                            : Colors
                                                                .transparent, // Black border when isSelected is true
                                                        width: isSelected &
                                                                !pWithReport
                                                                    .contains(
                                                                        index)
                                                            ? 1.5
                                                            : 0, // Border width when isSelected is true
                                                      ),
                                                    ),
                                                    child: ListTile(
                                                      leading: Image.asset(
                                                        'images/currentProgram.png',
                                                        height: 40,
                                                        width: 40,
                                                      ),
                                                      title: Text(
                                                        'Program  ${index + 1}',
                                                      ),
                                                      subtitle: Text(
                                                          'Ends on ${DateFormat('yyyy-MM-dd').format(program.endDate.toDate())}'),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          final selectedProgram =
                                              Provider.of<SelectedProgram>(
                                                  context,
                                                  listen: false);
                                          if (selectedProgram
                                                      ._selectedProgram !=
                                                  null &&
                                              !programsWithReport.contains(
                                                  selectedProgram
                                                      ._selectedProgram)) {
                                             Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ReportDetails(
                                                      pid: selectedProgram
                                                          ._selectedProgram!
                                                          .pid,
                                                    ),
                                                  ),
                                                );
                                                _AddPatientNumber(
                                                    selectedProgram
                                                        ._selectedProgram!.pid);
                                            }
                                            // Navigation code
                                            // print(
                                            //     'Navigating to ReportDetails page');
                                           else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'You need to select a program or Report data is not ready'),
                                              ),
                                            );
                                          }
                                        },
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(top: 16),
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF186257),
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            border: Border.all(
                                              color: Colors
                                                  .black, // Add black border
                                              width: 1, // Set border width
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                                spreadRadius: 5,
                                                blurRadius: 7,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'Generate report',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Merriweather',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                );
              }),
        ),
      ),
    );
  }
}
